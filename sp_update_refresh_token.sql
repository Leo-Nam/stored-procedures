CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_refresh_token`(
	IN IN_USER_REG_ID		VARCHAR(50),		/*입력값 : 사용자 아이디*/
	IN IN_PWD				VARCHAR(20),		/*입력값 : 사용자 등록 전화번호*/
	IN IN_JWT				VARCHAR(200),		/*입력값 : Refresh Token*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN
    CALL sp_req_current_time(@REG_DT);
	UPDATE USERS 
    SET JWT = IN_JWT, UPDATED_AT = @REG_DT
    WHERE 
		USER_ID = IN_USER_REG_ID AND
        PWD = IN_PWD AND 
        ACTIVE = TRUE;
	IF ROW_COUNT() = 1 THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 29801;
		SET msg_txt = 'Failed to change refresh token information';
    END IF;
END