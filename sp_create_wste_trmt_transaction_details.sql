CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_wste_trmt_transaction_details`(
	IN IN_USER_ID					BIGINT,						/*입렦값 : 폐기물 수거 및 처리업체 관리자의 고유등록번호(USERS.ID)*/
	IN IN_COLLECT_BIDDING_ID		BIGINT,						/*입렦값 : 폐기물 처리용역 고유등록번호(COLLECTOR_BIDDING.ID)*/
	IN IN_TRMT_END_AT				DATETIME,					/*입렦값 : 폐기물 최종 처리일자*/
	IN IN_WSTE_LISTS				JSON,						/*입렦값 : 폐기물 배출지에서 배출되는 폐기물의 종류 리스트*/
	IN IN_PHOTO_LISTS				JSON,						/*입렦값 : 폐기물 배출지에서 배출되는 폐기물의 사진 리스트*/
    OUT rtn_val 					INT,						/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_create_wste_trmt_transaction_details
Input param 	: 10개
Output param 	: 2개
Job 			: 폐기물 배출 작업 ORDER를 작성(SITE_WSTE_DISPOSAL_ORDER)한다.
Update 			: 2022.01.23
Version			: 0.0.5
AUTHOR 			: Leo Nam
Change			: 폐기물 배출 사이트의 고유등록번호도 저장하게 됨으로써 입력값으로 IN_SITE_ID 받아서 sp_insert_site_wste_discharge_order_without_handler에 전달해준다.
				: 폐기물 배출자의 타입을 프론트에서 입력받는 방식을 삭제하고 DB에서 구분을 하는 방식으로 전환(0.0.4)
				: 기존거래업체와의 재거래를 위한 컬럼 추가로 인한 로직 변경(0.0.5)
*/

	DECLARE REGISTRATION_JOB_CAN_GO TINYINT DEFAULT FALSE;
    
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
	CALL sp_req_user_exists_by_id(
    /*사용자가 존재하면서 활성화된 상태인지 검사한다.*/
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
    /*사용자가 유효한 경우에는 정상처리한다.*/
		CALL sp_req_user_affiliation_by_user_id(
        /*수거자가 개인회원인지 사업자 회원인지 구분한다. 개인이면 0, 사업자의 관리자이면 사이트의 고유등록번호를 반환한다.*/
			IN_USER_ID,
            @BELONG_TO
        );
		IF @BELONG_TO > 0 THEN
        /*수거자의 지위가 사업자(사이트)인 경우*/
            CALL sp_req_site_exists(
            /*사이트가 유효한지 검사한다.*/
				@BELONG_TO,
                TRUE,
				@rtn_val,
				@msg_txt
            );
            IF @rtn_val = 0 THEN
            /*사이트가 유효한 경우*/
				CALL sp_insert_wste_transaction_without_handler(
					IN_USER_ID,
					IN_COLLECT_BIDDING_ID,
					IN_TRMT_END_AT,
					IN_WSTE_LISTS,
					IN_PHOTO_LISTS,
					@REG_DT,
					@rtn_val,
					@msg_txt
                );
                IF @rtn_val = 0 THEN
                /*프로시저 실행에 성공한 경우*/
					SET rtn_val = 0;
					SET msg_txt = 'Completed registration of waste discharge operation';
                ELSE
                /*프로시저 실행에 실패한 경우*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사이트가 유효하지 않은 경우 예외처리 한다.*/
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*수거자의 지위가 개인인 경우에는 예외처리한다.*/
			SET rtn_val = 0;
			SET msg_txt = 'Individual members cannot dispose of waste';
        END IF;
    ELSE
    /*CREATOR가 유효하지 않은 경우에는 예외처리한다.*/
		SET rtn_val = @rtn_val;
		SET msg_txt = @msg_txt;
		SIGNAL SQLSTATE '23000';
    END IF;
END