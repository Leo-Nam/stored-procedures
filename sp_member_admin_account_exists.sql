CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_member_admin_account_exists`(
	IN IN_USER_REG_ID		VARCHAR(50),			/*입력값: 사업자의 admin인지 체크할 계정 아이디*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_member_admin_account_exists
Input param 	: 1개
Output param 	: 2개
Job 			: 사용자가 관리자인지 체크한 후 관리자이면 0, 그렇지 않으면 예외처리코드를 반환한다.
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) 
    INTO @CHK_COUNT 
    FROM V_USERS 
    WHERE 
		USER_ID = IN_USER_REG_ID AND 
        CLASS = 201 AND 
        AFFILIATED_SITE IS NOT NULL;
    
    IF @CHK_COUNT = 1 THEN
		SET rtn_val = 0;
		SET msg_txt = 0;
    ELSE
		SET rtn_val = 27401;
		SET msg_txt = 'User does not have business administrator(201) privileges';
    END IF;
END