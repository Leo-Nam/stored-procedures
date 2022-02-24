CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_users`()
BEGIN

/*
Procedure Name 	: sp_retrieve_users
Job 			: 회원리스트 반환
Update 			: 2022.02.01
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/	  
    
	SELECT JSON_ARRAYAGG(JSON_OBJECT('ID', ID, 'USER_ID', USER_ID, 'USER_NAME', USER_NAME, 'PHONE', PHONE, 'ACTIVE', ACTIVE)) INTO @json_data FROM USERS;
    
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END