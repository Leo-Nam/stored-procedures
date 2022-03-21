CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_avatar`(
	IN IN_USER_ID				BIGINT,
    IN IN_AVATAR_PATH			VARCHAR(255)
)
BEGIN

/*
Procedure Name 	: sp_create_avatar
Input param 	: 2개
Job 			: AVATAR 변경하기
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
    
    CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
        @rtn_val,
        @msg_txt
    );
    IF @rtn_val = 0 THEN
		CALL sp_req_current_time(@REG_DT);
		UPDATE USERS 
        SET 
			AVATAR_PATH = IN_AVATAR_PATH, 
			UPDATED_AT = @REG_DT 
		WHERE ID = IN_USER_ID;
		IF ROW_COUNT() = 1 THEN    
			SET @rtn_val 		= 0;
			SET @msg_txt 		= 'success';
			SET @json_data 		= NULL;
		ELSE
			SET @rtn_val 		= 33301;
			SET @msg_txt 		= 'Avatar update failure';
			SET @json_data 		= NULL;
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
		SIGNAL SQLSTATE '23000';
    END IF;
    
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END