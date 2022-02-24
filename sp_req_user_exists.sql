CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_exists`(
	IN IN_USER_REG_ID			VARCHAR(50),
    IN IN_ACTIVE			TINYINT,
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_exists
Input param 	: 2개
Output param 	: 2개
Job 			: 입력 param의 IN_USER_REG_ID를 사용자 아이디로 사용하는 사용자가 존재하는지 여부 반환
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	IF IN_ACTIVE IS NULL THEN
		SELECT COUNT(ID) INTO @CHK_COUNT FROM USERS WHERE USER_ID = IN_USER_REG_ID;
    ELSE
		SELECT COUNT(ID) INTO @CHK_COUNT FROM USERS WHERE USER_ID = IN_USER_REG_ID AND ACTIVE = IN_ACTIVE;
    END IF;
    
    IF @CHK_COUNT = 1 THEN
    /*사용자가 존재하는 경우*/
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SET rtn_val = 27601;
		SET msg_txt = 'user does not exist';
    END IF;
END