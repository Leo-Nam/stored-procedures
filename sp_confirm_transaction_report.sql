CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_confirm_transaction_report`(
	IN IN_USER_ID					BIGINT,
	IN IN_REPORT_ID					BIGINT,
	IN IN_RESPONSE					BIGINT
)
BEGIN

/*
Procedure Name 	: sp_confirm_transaction_report
Input param 	: 3개
Job 			: 수거자가 제출한 보고서를 승인 또는 거절한다.
Update 			: 2022.04.01
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
	
    CALL sp_req_current_time(@REG_DT);
    
	CALL sp_req_user_exists_by_id(
    /*DISPOSER가 존재하면서 활성화된 상태인지 검사한다.*/
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
    /*사용자가 유효한 경우에는 정상처리한다.*/
		SELECT DISPOSER_SITE_ID INTO @DISPOSER_SITE_ID
        FROM TRANSACTION_REPORT A
        WHERE ID = IN_REPORT_ID;
        
        SELECT AFFILIATED_SITE INTO @USER_SITE_ID
        FROM USERS
        WHERE ID = IN_USER_ID;
		IF @DISPOSER_SITE_ID = @USER_SITE_ID THEN
		/*사용자가 정보변경 대상이 되는 사이트에 소속한 관리자인 경우*/
			CALL sp_req_user_class_by_user_reg_id(
			/*사용자의 권한을 구한다.*/
			IN_USER_ID,
			@USER_CLASS
			);
			IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
			/*관리자가 정보를 변경할 권한이 있는 경우*/
				CALL sp_check_if_transaction_report_exists(
				/*리포트가 존재하는지 검사한다.*/
					IN_REPORT_ID,
					@rtn_val,
					@msg_txt
				);
				IF @rtn_val = 0 THEN
				/*리포트가 존재하는 경우 정상처리한다.*/
					SELECT REPORTED_AT, TRANSACTION_ID 
                    INTO @REPORTED_AT, @TRANSACTION_ID
                    FROM TRANSACTION_REPORT 
                    WHERE ID = IN_REPORT_ID;
					/*수거자가 리포트를 제출할 준비가 되었는지 검사하여 @REPORTED_AT에 반환한다.*/
					
					IF @REPORTED_AT IS NOT NULL THEN
					/*수거자가 리포트를 제출한 경우*/
						UPDATE TRANSACTION_REPORT 
						SET 
							CONFIRMED 					= IN_RESPONSE, 
							UPDATED_AT 					= @REG_DT,
                            TRANSACTION_COMPLETED_AT	= IF(IN_RESPONSE = TRUE, @REG_DT, NULL),
							DISPOSER_MANAGER_ID 		= IN_USER_ID
						WHERE ID = IN_REPORT_ID;
						IF ROW_COUNT() = 1 THEN
						/*정보가 성공적으로 변경되었다면*/
							IF IN_RESPONSE = TRUE THEN
								UPDATE WSTE_CLCT_TRMT_TRANSACTION
                                SET 
									IN_PROGRESS 		= FALSE,
                                    UPDATED_AT 			= @REG_DT,
                                    CONFIRMER_ID		= IN_USER_ID,
                                    CONFIRMED_AT		= @REG_DT,
                                    UPDATED_AT			= @REG_DT,
                                    CONFIRMED			= IN_RESPONSE
								WHERE ID = @TRANSACTION_ID;
								IF ROW_COUNT() = 1 THEN
									SET @rtn_val = 0;
									SET @msg_txt = 'success';
                                ELSE
									SET @rtn_val = 36005;
									SET @msg_txt = 'Transaction Closing Failed';
									SIGNAL SQLSTATE '23000';
                                END IF;
                            END IF;
						ELSE
						/*정보변경에 실패했다면 예외처리한다.*/
							SET @rtn_val = 36004;
							SET @msg_txt = 'Report approval failure';
							SIGNAL SQLSTATE '23000';
						END IF;
					ELSE
					/*수거자가 리포트를 제출하지 경우*/
						SET @rtn_val = 36003;
						SET @msg_txt = 'Report not submitted by the collector';
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*리포트가 존재하지 않는 경우 예외처리한다.*/
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*관리자가 정보를 변경할 권한이 없는 경우*/
				SET @rtn_val = 36002;
				SET @msg_txt = 'User does not have permission to change information';
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
		/*사용자가 정보변경 대상이 되는 사이트에 소속한 관리자가 아닌 경우 예외처리한다.*/
			SET @rtn_val = 36001;
			SET @msg_txt = 'The user is not an administrator of the site';
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
    /*사용자가 유효하지 않은 경우에는 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END