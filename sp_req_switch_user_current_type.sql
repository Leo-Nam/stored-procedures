CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_switch_user_current_type`(
	IN IN_USER_ID			BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_switch_user_current_type
Input param 	: 1개
Job 			: 사용자의 현재상태를 변경함
Update 			: 2022.02.19
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

	SELECT USER_TYPE, USER_CURRENT_TYPE_NM INTO @USER_TYPE, @USER_CURRENT_TYPE_NM FROM V_USERS WHERE ID = IN_USER_ID;
	IF @USER_TYPE = 'collector' THEN
		IF @USER_CURRENT_TYPE_NM = 'collector' OR @USER_CURRENT_TYPE_NM IS NULL THEN
			UPDATE USERS SET USER_CURRENT_TYPE = 2 WHERE ID = IN_USER_ID;
        ELSE
			UPDATE USERS SET USER_CURRENT_TYPE = 3 WHERE ID = IN_USER_ID;
        END IF;
        IF ROW_COUNT() = 1 THEN            
			SELECT JSON_OBJECT(
				'USER_ID', 						ID, 
				'USER_PREVIOUS_TYPE', 			@USER_CURRENT_TYPE_NM,
				'USER_CURRENT_TYPE', 			USER_CURRENT_TYPE_NM
			) 
			INTO @json_data 
			FROM V_USERS 
			WHERE 
				ID 		= IN_USER_ID;
			SET @rtn_val = 0;
			SET @msg_txt = 'success';
        ELSE
			SET @json_data 		= NULL;
			SET @rtn_val = 31001;
			SET @msg_txt = 'Failed to change user current type';
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
		SET @json_data 		= NULL;
		SET @rtn_val = 31002;
		SET @msg_txt = 'Cannot change user current type';
		SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END