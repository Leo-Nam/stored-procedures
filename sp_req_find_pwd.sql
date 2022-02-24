CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_find_pwd`(
	IN IN_USER_ID			VARCHAR(50),		/*입력값 : 사용자 아이디*/
	IN IN_USER_NAME			VARCHAR(20),		/*입력값 : 사용자 고유번호*/
	IN IN_PHONE				VARCHAR(20)			/*입력값 : 사용자 등록 전화번호*/
)
BEGIN

/*
Procedure Name 	: sp_req_find_pwd
Input param 	: 3개
Job 			: 사용자찾기기능으로서 사용자의 아이디와 이름, 전화번호로 해당사용자가 존재하는지 여부를 반환
Update 			: 2022.01.30
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) 
	INTO @CHK_COUNT 
	FROM USERS 
	WHERE 
		USER_ID 				= IN_USER_ID AND 
		USER_NAME 				= IN_USER_NAME AND 
		PHONE 					= IN_PHONE;
	IF @CHK_COUNT 				= 0 THEN
		SET @rtn_val 			= 22001;
		SET @msg_txt 			= 'user does not exist';
		SET @json_data 			= NULL;
	ELSE
		SELECT COUNT(ID) 
		INTO @CHK_COUNT 
		FROM USERS 
		WHERE 
			USER_ID 			= IN_USER_ID AND 
			USER_NAME 			= IN_USER_NAME AND 
			PHONE 				= IN_PHONE AND 
            ACTIVE 				= TRUE;
            
		IF @CHK_COUNT = 0 THEN
			SET @rtn_val 		= 22002;
			SET @msg_txt 		= 'user is disabled';
            SET @json_data 		= NULL;
		ELSE
			SET @rtn_val 		= 0;
			SET @msg_txt 		= 'user found';
            SELECT JSON_OBJECT(
				'ID', 			ID, 
                'USER_ID', 		USER_ID, 
                'USER_NAME', 	USER_NAME, 
                'PHONE', 		PHONE
			) 
            INTO @json_data 
            FROM USERS 
            WHERE 
				USER_ID 		= IN_USER_ID AND 
				USER_NAME 		= IN_USER_NAME AND 
				PHONE 			= IN_PHONE AND 
				ACTIVE 			= TRUE;
		END IF;
	END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END