CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_get_user_info`(
	IN IN_PARAMS			JSON
)
BEGIN

/*
Procedure Name 	: sp_admin_get_user_info
Input param 	: 1개
Job 			: 사용자 로그인기능으로서 사용자의 아이디와 암호로 해당사용자가 존재하는지 여부를 반환
Update 			: 2022.05.03
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
	SELECT ID COLLATE utf8mb4_unicode_ci
    INTO @ID
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		ID		 				VARCHAR(255)		PATH "$.ID",
		PW		 				VARCHAR(255)		PATH "$.PW"
	)) AS PARAMS;
    
	SELECT COUNT(ID) INTO @USER_COUNT
    FROM CHIUM_MEMBERS
    WHERE UID = @ID;
    
    IF @USER_COUNT = 1 THEN
		SELECT JSON_OBJECT(
			'ID', 							ID, 
			'USER_ID', 						UID, 
			'PWD', 							PWD, 
			'CLASS', 						CLASS
		) 
		INTO @json_data 
		FROM CHIUM_MEMBERS 
		WHERE 
			UID 			= @ID AND 
			ACTIVE 			= TRUE;
		SET @rtn_val = 0;
		SET @msg_txt = 'success';
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
    ELSE
		SET @rtn_val = 100001;
		SET @msg_txt = 'No user found';
		SET @json_data = NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
    END IF;
         
END