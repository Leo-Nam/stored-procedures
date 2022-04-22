CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_site_wste_discharge_order`(
	IN IN_USER_ID					BIGINT,						/*입렦값 : 폐기물 배출 주체의 고유등록번호(USERS.ID)*/
	IN IN_COLLECTOR_SITE_ID			BIGINT,						/*입렦값 : 기존거래로 등록할 때 등록할 기존 업체 사이트의 고유등록번호(COMP_SITE.ID), 기존업체와의 거래가 아닌 경우에는 NULL 사용*/
	IN IN_KIKCD_B_CODE				VARCHAR(10),				/*입렦값 : 폐기물 배출지가 소재하는 소재지의 시군구코드(KIKCD_B.B_CODE)*/
	IN IN_ADDR						VARCHAR(200),				/*입렦값 : 폐기물 배출지가 소재하는 소재지의 시군구 이하 상세주소*/
	IN IN_LAT						DECIMAL(12,9),				/*입렦값 : 폐기물 발생지 위도값*/
	IN IN_LNG						DECIMAL(12,9),				/*입렦값 : 폐기물 발생지 경도값*/
	IN IN_VISIT_START_AT			DATETIME,					/*입렦값 : 폐기물 배출지에서 요구하는 방문시작일로서 NULL인 경우에는 방문 불필요*/
	IN IN_VISIT_END_AT				DATETIME,					/*입렦값 : 폐기물 배출지에서 요구하는 방문종료일로서 NULL인 경우에는 방문 불필요*/
	IN IN_BIDDING_END_AT			DATETIME,					/*입렦값 : 폐기물 처리 용역 입찰 종료일*/
	IN IN_OPEN_AT					DATETIME,					/*입렦값 : 폐기물 배출 시작일*/
	IN IN_CLOSE_AT					DATETIME,					/*입렦값 : 폐기물 배출 종료일*/
	IN IN_WSTE_CLASS				JSON,						/*입렦값 : 폐기물 배출지에서 배출되는 폐기물의 종류 리스트*/
	IN IN_PHOTO_LIST				JSON,						/*입렦값 : 폐기물 배출지에서 배출되는 폐기물의 사진 리스트*/
	IN IN_NOTE						VARCHAR(255)				/*입력값 : 폐기물 배출시 요청사항*/
)
BEGIN

/*
Procedure Name 	: sp_create_site_wste_discharge_order
Input param 	: 11개
Job 			: 폐기물 배출 작업 ORDER를 작성(SITE_WSTE_DISPOSAL_ORDER)한다.
Update 			: 2022.03.17
Version			: 0.0.9
AUTHOR 			: Leo Nam
Change			: 폐기물 배출 사이트의 고유등록번호도 저장하게 됨으로써 입력값으로 IN_SITE_ID 받아서 sp_insert_site_wste_discharge_order_without_handler에 전달해준다.
				: 폐기물 배출자의 타입을 프론트에서 입력받는 방식을 삭제하고 DB에서 구분을 하는 방식으로 전환(0.0.4)
				: 기존거래업체와의 재거래를 위한 컬럼 추가로 인한 로직 변경(0.0.5)
				: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.6)
				: VISIT_START_AT 칼럼 추가(0.0.7)
				: IN_VISIT_END_AT이 시간이 없이 날짜만 존재하는 경우에는 IN_VISIT_END_AT에 1일을 추가해준다.(0.0.9)
				: 사용자의 현재 타입에 따른 배출권한 제한(0.0.8)
*/
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;				
    /*트랜잭션 시작*/  
    
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
	CALL sp_req_user_exists_by_id(
    /*DISPOSER가 존재하면서 활성화된 상태인지 검사한다.*/
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
    /*DISPOSER가 유효한 경우에는 정상처리한다.*/
		IF IN_VISIT_END_AT IS NOT NULL THEN
			SET @VISIT_END_AT = CAST(CONCAT(DATE(IN_VISIT_END_AT), ' ', '23:59:55') AS DATETIME);
			SET @REF_DATE = @VISIT_END_AT;
		ELSE
			SET @VISIT_END_AT = NULL;
			SET @REF_DATE = @REG_DT;
        END IF;
        
		IF IN_BIDDING_END_AT IS NOT NULL THEN
			SET @BIDDING_END_AT = CAST(CONCAT(DATE(IN_BIDDING_END_AT), ' ', '23:59:59') AS DATETIME);
		ELSE
			CALL sp_req_policy_direction(
			/*입찰종료일을 자동결정하기 위하여 방문종료일로부터의 기간을 반환받는다. 입찰종료일일은 방문종료일 + bidding_end_date_after_the_visit_early_closing으로 한다.1*/
				'bidding_end_date_after_the_visit_closing',
				@bidding_end_date_after_the_visit_closing
			);
			SET @BIDDING_END_AT = ADDTIME(
				@REF_DATE, 
				CONCAT(
					CAST(@bidding_end_date_after_the_visit_early_closing AS UNSIGNED), 
					':00:00'
				)
			);
        END IF;
        
		IF IN_CLOSE_AT IS NOT NULL THEN
			SET @CLOSE_AT = CAST(CONCAT(DATE(IN_CLOSE_AT), ' ', '23:59:59') AS DATETIME);
		ELSE
			CALL sp_req_policy_direction(
			/*입찰마감일로부터 배출종료일까지의 최소 소요기간(단위: day)을 반환받는다. 입찰종료일일은 방문종료일 + bidding_end_date_after_the_visit_early_closing으로 한다.*/
				'max_disposal_duration',
				@max_disposal_duration
			);
			SET @CLOSE_AT = DATE_ADD(@BIDDING_END_AT, INTERVAL @max_disposal_duration DAY);
        END IF;
        
        IF IN_OPEN_AT IS NOT NULL THEN
			SET @OPEN_AT = IN_OPEN_AT;
        ELSE
			SET @OPEN_AT = @REG_DT;
        END IF;
        
        SELECT USER_CURRENT_TYPE INTO @USER_CURRENT_TYPE_CODE
		FROM USERS WHERE ID = IN_USER_ID;
        
        IF @USER_CURRENT_TYPE_CODE = 2 THEN
        /*사용자의 현재 타입정보가 배출자인 경우에는 정상처리한다.*/
			SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;	
			IF @USER_SITE_ID = 0 THEN
			/*배출자의 지위가 개인인 경우*/
				SET @DISPOSER_TYPE 	= 'person';
				CALL sp_insert_site_wste_discharge_order_without_handler(
					IN_USER_ID,
					IN_COLLECTOR_SITE_ID,
					@USER_SITE_ID,
					@DISPOSER_TYPE,
					IN_KIKCD_B_CODE,
					IN_ADDR,
					IN_VISIT_START_AT,
					@VISIT_END_AT,
					@BIDDING_END_AT,
					@OPEN_AT,
					@CLOSE_AT,
					IN_WSTE_CLASS,
					IN_PHOTO_LIST,
					IN_NOTE,
					IN_LAT,
					IN_LNG,
					@REG_DT,
					@PUSH_INFO,
					@rtn_val,
					@msg_txt
				);
				IF @rtn_val = 0 THEN
				/*프로시저 실행에 성공한 경우*/
					SET @json_data = @PUSH_INFO;
					SET @rtn_val = 0;
					SET @msg_txt = 'Success';
				ELSE
				/*프로시저 실행에 실패한 경우*/
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*배출자의 지위가 사업자(사이트)인 경우*/
				SET @DISPOSER_TYPE = 'company';
				CALL sp_req_site_exists(
				/*사이트가 유효한지 검사한다.*/
					@USER_SITE_ID,
					TRUE,
					@rtn_val,
					@msg_txt
				);
				IF @rtn_val = 0 THEN
				/*사이트가 유효한 경우*/
					CALL sp_insert_site_wste_discharge_order_without_handler(
						IN_USER_ID,
						IN_COLLECTOR_SITE_ID,
						@USER_SITE_ID,
						@DISPOSER_TYPE,
						IN_KIKCD_B_CODE,
						IN_ADDR,
						IN_VISIT_START_AT,
						@VISIT_END_AT,
						@BIDDING_END_AT,
						@OPEN_AT,
						@CLOSE_AT,
						IN_WSTE_CLASS,
						IN_PHOTO_LIST,
						IN_NOTE,
						IN_LAT,
						IN_LNG,
						@REG_DT,
						@PUSH_INFO,
						@rtn_val,
						@msg_txt
					);
					IF @rtn_val = 0 THEN
					/*프로시저 실행에 성공한 경우*/
						SET @json_data = @PUSH_INFO;
						SET @rtn_val = 0;
						SET @msg_txt = 'Success';
					ELSE
					/*프로시저 실행에 실패한 경우*/
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*사이트가 유효하지 않은 경우 예외처리 한다.*/
					SIGNAL SQLSTATE '23000';
				END IF;
			END IF;
        ELSE
        /*사용자의 현재 타입정보가 배출자가 아닌 경우에는 예외처리한다.*/
			SET @rtn_val = 31001;
			SET @msg_txt = 'Discharge is not possible with the current user type';
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*CREATOR가 유효하지 않은 경우에는 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;   
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END