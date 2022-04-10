CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_userid_duplicate`(
	IN IN_USER_REG_ID		VARCHAR(50)
)
BEGIN

/*
Procedure Name 	: sp_req_is_userid_duplicate
Input param 	: 1개
Job 			: INPUT PARAM으로 들어온 사용자 아이디가 중복되었는지 확인한 후 중복되었으면 0, 그렇지 않으면 예외처리코드를 반환함1
Update 			: 2022.01.30
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/
	SET @USER_REG_ID = IN_USER_REG_ID;
	SELECT COUNT(ID) INTO @CHK_COUNT FROM USERS WHERE USER_ID = @USER_REG_ID;
    
    IF @CHK_COUNT > 0 THEN
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'UID'			, ID
		)) 
		INTO @json_data FROM USERS
		WHERE USER_ID = @USER_REG_ID;
		SET @rtn_val 		= 29401;
		SET @msg_txt 		= 'User ID already exists';
    ELSE
		SET @json_data 			= NULL;
		SET @rtn_val 		= 0;
		SET @msg_txt 		= 'Success';
    END IF;
    
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END