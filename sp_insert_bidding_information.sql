CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_bidding_information`(
	IN IN_SITE_ID					BIGINT,				/*입력값 : 폐기물 수거자등의 폐기물 처리업체의 사시트 고유등록번호(COMP_SITE.ID)*/
	IN IN_DISPOSER_ORDER_ID			BIGINT,				/*입력값 : 배출자가 입력한 폐기물 배출정보(SITE_WSTE_DISPOSAL_ORDER.ID)*/
    IN IN_BIDDING_DETAILS			JSON,				/*입력값 : 폐기물 수집운반 및 처리에 대한 입찰내역서*/
    OUT rtn_val						INT,				/*출력값 : 처리결과 반환값*/   
    OUT msg_txt 					VARCHAR(200)		/*출력값 : 처리결과 문자열*/ 
)
BEGIN

/*
Procedure Name 	: sp_insert_bidding_information
Input param 	: 1개
Output param 	: 2개
Job 			: 수집업자 등의 입찰정보를 등록한다.
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.21
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: STATUS_HISTORY에 입력하는 기능 추가(0.0.2)
*/

    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
	CALL sp_req_bidding_end_date_expired(
	/*입찰마감일이 종료되었는지 검사한다. 종료되었으면 TRUE, 그렇지 않으면 FALSE반환*/
		IN_DISPOSER_ORDER_ID,
		@IS_BIDDING_END_DATE_EXPIRED
	);
	IF @IS_BIDDING_END_DATE_EXPIRED = FALSE THEN
	/*입찰마감일이 종료되지 않은 경우*/
		CALL sp_req_collect_bidding_max_id(
			@COLLECTOR_BIDDING_ID
        );
        
        SELECT COUNT(ID) 
        INTO @CHK_COUNT 
        FROM COLLECTOR_BIDDING 
        WHERE 
			COLLECTOR_ID = @COLLECTOR_BIDDING_ID AND
            DISPOSAL_ORDER_ID = IN_SITE_ID AND
            ACTIVE = TRUE;
		/*PK 검사 실행*/
		IF @CHK_COUNT = 0 THEN
        /*PK 위반하지 않은 경우*/
			INSERT INTO COLLECTOR_BIDDING (
				ID,
				COLLECTOR_ID,
				DISPOSAL_ORDER_ID,
				ACTIVE,
				CREATED_AT,
				UPDATED_AT
			) VALUES (
				@COLLECTOR_BIDDING_ID,
				IN_SITE_ID,
				IN_DISPOSER_ORDER_ID,
				TRUE,
				@REG_DT,
				@REG_DT
			);
			
			IF ROW_COUNT() = 1 THEN
			/*데이타베이스에 레코드가 성공적으로 입력된 경우*/
				CALL sp_insert_collector_wste_lists(
				/*수거자 등이 입력한 입찰정보를 데이타베이스에 저장한다.*/
					@COLLECTOR_BIDDING_ID,
					IN_DISPOSER_ORDER_ID,
					@REG_DT,
					IN_BIDDING_DETAILS,
					@rtn_val,
					@msg_txt
				);
				IF @rtn_val = 0 THEN
				/*데이타베이스 입력에 성공한 경우*/
					INSERT INTO STATUS_HISTORY (
						DISPOSAL_ORDER_ID, 
						COLLECTOR_ID, 
						STATUS_CODE, 
						CREATED_AT, 
						UPDATED_AT
					) 
					VALUES (
						IN_DISPOSER_ORDER_ID, 
						IN_SITE_ID, 
						2, 
						@REG_DT, 
						@REG_DT
					);
					IF ROW_COUNT() = 1 THEN
					/*데이타 입력에 성공하였다면*/
						SET rtn_val = 0;
						SET msg_txt = 'The waste bidding process has been completed';
					ELSE
					/*데이타 입력에 실패하였다면 예외처리한다.*/
						SET rtn_val = 23501;
						SET msg_txt = 'Failed to write history';
					END IF;
				ELSE
				/*데이타베이스 입력에 실패한 경우*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
				END IF;
			ELSE
			/*데이타베이스에 레코드 입력이 실패한 경우*/
				SET rtn_val = 23502;
				SET msg_txt = 'Failed to create database record';
			END IF;
        ELSE
        /*PK 위반인 경우에는 예외처리한다.*/
			SET rtn_val = 23503;
			SET msg_txt = 'violation of PK rules';
        END IF;
	ELSE
	/*입찰마감일이 종료된 경우 예외처리한다.*/
		SET rtn_val = 23504;
		SET msg_txt = 'Bidding deadline has ended';
	END IF;
	
END