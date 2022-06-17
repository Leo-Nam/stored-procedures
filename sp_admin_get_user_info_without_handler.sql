CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_get_user_info_without_handler`(
	IN IN_PARAMS			JSON,
	OUT USER_INFO			JSON
)
BEGIN

/*
Procedure Name 	: sp_admin_get_user_info_without_handler
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
    
	SELECT JSON_OBJECT(
		'ID', 							ID, 
		'USER_ID', 						USER_ID, 
		'PWD', 							PWD, 
		'USER_NAME', 					USER_NAME, 
		'TRMT_BIZ_CODE', 				TRMT_BIZ_CODE, 
		'SITE_ID', 						AFFILIATED_SITE, 
		'COMP_ID', 						BELONG_TO, 
		'FCM', 							FCM, 
		'CLASS', 						CLASS, 
		'PHONE', 						PHONE,			/*0.0.4에서 추가 PHONE추가*/
		'USER_TYPE', 					USER_TYPE,
		'USER_CURRENT_TYPE', 			USER_CURRENT_TYPE_NM,
		'PUSH_ENABLED', 				PUSH_ENABLED,
		'NOTICE_ENABLED', 				NOTICE_ENABLED,
		'AVATAR_PATH', 					AVATAR_PATH
	) 
	INTO USER_INFO 
	FROM V_USERS 
	WHERE 
		USER_ID 		= @ID AND 
		ACTIVE 			= TRUE;
END