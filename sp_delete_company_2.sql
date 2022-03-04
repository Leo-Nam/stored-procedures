CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_company_2`(
	IN IN_DELETER_ID					BIGINT,
    IN IN_TARGET_COMP_ID				BIGINT,
    IN IN_TARGET_SITE_ID				BIGINT,
    IN IN_COUNT_SITE_USERS				INT
)
BEGIN
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data = NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    CALL sp_check_auth_to_delete_company(
		IN_DELETER_ID,
		IN_TARGET_COMP_ID,
		@TARGET_COMP_ID,
		@TARGET_SITE_ID,
		@COUNT_SITE_USERS,
		@rtn_val,
		@msg_txt
	);
    
    IF @rtn_val = 0 THEN
    /*사업자 삭제가 가능한 경우 정상처리한다.*/
		UPDATE USERS 
		SET ACTIVE = FALSE 
		WHERE AFFILIATED_SITE = IN_TARGET_SITE_ID;
		
		IF ROW_COUNT() = IN_COUNT_SITE_USERS THEN
        /*사용자에 대한 deactivated가 성공한 경우 정상처리한다.*/
			UPDATE COMP_SITE 
			SET ACTIVE = FALSE 
			WHERE ID = IN_TARGET_SITE_ID;
			
			IF ROW_COUNT() = 1 THEN
			/*SITE에 대한 deactivated가 성공한 경우 정상처리한다.*/
				UPDATE COMPANY 
				SET ACTIVE = FALSE 
				WHERE ID = TARGET_COMP_ID;
				
				IF ROW_COUNT() = 1 THEN
				/*COMPANY에 대한 deactivated가 성공한 경우 정상처리한다.*/
					SET @rtn_val = 0;
					SET @msg_txt = 'Success';
				ELSE
				/*COMPANY에 대한 deactivated가 실패한 경우 예외처리한다.*/
					SET @rtn_val = 32203;
					SET @msg_txt = 'Company deactivation failed';
				END IF;
			ELSE
			/*SITE에 대한 deactivated가 실패한 경우 예외처리한다.*/
				SET @rtn_val = 32202;
				SET @msg_txt = 'Site deactivation failed';
			END IF;
		ELSE
        /*사용자에 대한 deactivated가 실패한 경우 예외처리한다.*/
			SET @rtn_val = 32201;
			SET @msg_txt = 'Users deactivation failed';
		END IF;
    ELSE
    /*사업자 삭제가 불가능한 경우 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
    
	SET @json_data = NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END