CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_find_user_id`(
	IN IN_USER_NAME			VARCHAR(50),		/*입력값 : 사용자 이름*/
	IN IN_PHONE				VARCHAR(20)			/*입력값 : 사용자 등록 전화번호*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_login
Input param 	: 2개
Job 			: 사용자 로그인기능으로서 사용자의 아이디와 암호로 해당사용자의 아이디를 반환함
Update 			: 2022.02.05
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(USER_ID)
    INTO @CHK_COUNT
	FROM USERS 
	WHERE 
		USER_NAME 				= IN_USER_NAME AND 
		PHONE 					= IN_PHONE;
        
	IF @CHK_COUNT = 1 THEN
		SELECT COUNT(USER_ID)				/*0.0.2에서 수정함 SELECT USER_ID => SELECT COUNT(USER_ID)*/
		INTO @CHK_COUNT
		FROM USERS 
		WHERE 
			USER_NAME 			= IN_USER_NAME AND 
			PHONE 				= IN_PHONE AND 
			ACTIVE 				= TRUE;
            
		IF @CHK_COUNT = 1 THEN
			SET @rtn_val 		= 0;
            SET @msg_txt 		= 'user account found';
            
            SELECT JSON_OBJECT(
                'USER_ID', 		USER_ID
			) 
            INTO @json_data 
            FROM USERS 
            WHERE 
				USER_NAME 		= IN_USER_NAME AND 
				PHONE 			= IN_PHONE AND 
				ACTIVE 			= TRUE;
		ELSE
			SET @rtn_val 		= 22201;
            SET @msg_txt 		= 'user account is disabled';
			SET @json_data 		= NULL;
        END IF;
    ELSE
		SET @rtn_val 			= 22202;
		SET @msg_txt 			= 'user account does not exist';
		SET @json_data 			= NULL;
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END