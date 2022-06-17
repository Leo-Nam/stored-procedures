CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_user_login`(
	IN IN_PARAMS			JSON
)
BEGIN

/*
Procedure Name 	: sp_admin_user_login
Input param 	: 1개
Job 			: 사용자 로그인기능으로서 사용자의 아이디와 암호로 해당사용자가 존재하는지 여부를 반환
Update 			: 2022.05.03
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
	SELECT 
		ID COLLATE utf8mb4_unicode_ci, 
		PW COLLATE utf8mb4_unicode_ci
    INTO @ID, @PW
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		ID		 				VARCHAR(255)		PATH "$.ID",
		PW		 				VARCHAR(255)		PATH "$.PW"
	)) AS PARAMS;
    
	SELECT COUNT(ID) INTO @USER_COUNT
    FROM USERS
    WHERE USER_ID = @ID AND CLASS < 200;
    
    IF @USER_COUNT = 1 THEN
		CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_USER_LOGIN_TEMP (
			INPUT_PARAM				JSON,
			USER_INFO				JSON
		);
		CALL sp_admin_get_user_info_without_handler(
			IN_PARAMS,
			@USER_INFO
		);	
		
		INSERT INTO 
		ADMIN_USER_LOGIN_TEMP(
			USER_INFO,
			INPUT_PARAM
		)
		VALUES(
			@USER_INFO,
			IN_PARAMS
		);
		
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'USER_INFO'				, @USER_INFO,
			'INPUT_PARAM'			, IN_PARAMS
		)) 
		INTO @json_data FROM ADMIN_USER_LOGIN_TEMP;
		
		DROP TABLE IF EXISTS ADMIN_USER_LOGIN_TEMP;
    
		SET @rtn_val = 0;
		SET @msg_txt = 'success';
		CALL sp_return_results(@json_data, @msg_txt, @json_data);
    ELSE
		SET @rtn_val = 88101;
		SET @msg_txt = 'No user found';
		SET @json_data = NULL;
		CALL sp_return_results(@json_data, @msg_txt, @json_data);
    END IF;
END