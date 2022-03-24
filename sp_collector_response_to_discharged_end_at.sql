CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_collector_response_to_discharged_end_at`(
	IN IN_USER_ID						BIGINT,			/*입력값: 수거업체 관리자 아이디(USERS.ID)*/
	IN IN_TRANSACTION_ID				BIGINT,			/*입력값: 폐기물 수거단위작업 코드(WSTE_CLCT_TRMT_TRANSACTION.ID)*/
	IN IN_RESPONSE						TINYINT			/*입력값: 배출업체의 최종처리일 요청에 대한 수거업체의 응답으로서 수락인 경우에는 TRUE, 거절인 경우에는 FALSE*/
)
BEGIN

/*
Procedure Name 	: sp_collector_response_to_discharged_end_at
Input param 	: 3개
Job 			: 폐기물 수거업체가 배출업체가 결정한 폐기물 최종처리일자까지 폐기물을 수거할지의 여부를 결정 통보한다.
Update 			: 2022.03.24
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/		

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
	CALL sp_req_user_exists_by_id(
    /*DISPOSER가 존재하면서 활성화된 상태인지 검사한다.*/
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );	
    
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우 정상처리한다*/
		CALL sp_req_collector_id_of_transaction(
			IN_TRANSACTION_ID,
            @COLLECTOR_SITE_ID,
			@rtn_val,
			@msg_txt
        );
		IF @rtn_val = 0 THEN
		/*트랜잭션의 수집업자 아이디를 성공적으로 반환받은 경우 정상처리한다*/
			SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
            IF @COLLECTOR_SITE_ID = @USER_SITE_ID THEN
            /*사용자가 수집업체에 소속된 경우 정상처리한다.*/
				CALL sp_req_current_time(@REG_DT);
				UPDATE WSTE_CLCT_TRMT_TRANSACTION 
                SET 
					ACCEPT_ASK_END = IN_RESPONSE,
                    ACCEPT_ASK_END_AT = @REG_DT,
                    UPDATED_AT = @REG_DT
				WHERE ID = IN_TRANSACTION_ID;
                IF ROW_COUNT() = 1 THEN
					SET @rtn_val 		= 0;
					SET @msg_txt 		= 'success';
                ELSE
					SET @rtn_val 		= 34802;
					SET @msg_txt 		= 'failed to update record';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사용자가 수집업체에 소속되지 않은 경우 예외처리한다.*/
				SET @rtn_val 		= 34801;
				SET @msg_txt 		= 'user does not belong to the site';
				SIGNAL SQLSTATE '23000';
            END IF;
		ELSE
			SIGNAL SQLSTATE '23000';
		END IF;
	ELSE
		SIGNAL SQLSTATE '23000';
    END IF;   
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);

	
END