CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_toggle_push`(
	IN IN_USER_ID				BIGINT,
    IN IN_PUSH					TINYINT
)
BEGIN

/*
Procedure Name 	: sp_update_push
Input param 	: 2개
Job 			: PUSH 알림 토글
Update 			: 2022.03.14
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    CALL sp_req_current_time(@REG_DT);
    CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
        @rtn_val,
        @msg_txt
    );
    IF @rtn_val = 0 THEN
		CALL sp_req_current_time(@REG_DT);
		UPDATE USERS SET PUSH_ENABLED = IN_PUSH, UPDATED_AT = @REG_DT WHERE ID = IN_USER_ID;
		IF ROW_COUNT() = 1 THEN
			SELECT JSON_ARRAYAGG(JSON_OBJECT(
				'ID'			, IN_USER_ID,
				'PUSH_ENABLED'	, IN_PUSH
			)) INTO @json_data;
			SET @rtn_val 		= 0;
			SET @msg_txt 		= 'success';
		ELSE
			SELECT JSON_ARRAYAGG(JSON_OBJECT(
				'ID'			, ID, 
				'PUSH_ENABLED'	, PUSH_ENABLED
			)) 
			INTO @json_data 
			FROM USERS
			WHERE ID = IN_USER_ID;
			SET @rtn_val 		= 33401;
			SET @msg_txt 		= 'Push status update failed';
			SIGNAL SQLSTATE '23000';
		END IF;
    END IF;
    
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END