CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_change_generic_user_pwd`(
	IN IN_USER_PHONE				VARCHAR(20),			/*입력값 : 사용자 전화번호*/
	IN IN_PWD						VARCHAR(50),			/*입력값 : 사용자 변경할 암호*/
    OUT rtn_val 					INT,					/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)			/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_change_generic_user_pwd
Input param 	: 3개
Output param 	: 2개
Job 			: 입력받은 암호를 해당사용자의 새로운 암호로 업데이트를 한다. 성공인면 0, 그렇지 않으면 예외코드를 반환한다.
Update 			: 2022.01.13
Version			: 0.0.1
AUTHOR 			: Leo Nam

처리결과 / 메시지	: 0 	- Password change successful
				: 21301 - Failed to change password for any other reason
				: 21302 - Phone number not found
*/

	SELECT ID INTO @USER_REG_ID FROM USERS WHERE ACTIVE = TRUE AND PHONE = IN_USER_PHONE AND BELONG_TO = 0 AND CLASS >= 200;
    /*
    WHERE 조건문
    1. ACTIVE = TRUE : 활성화 되어 있는 아이디만 수정 등이 가능하므로 활성화되어 있는 아이디를 가진 사용자
    2. PHONE = IN_USER_PHONE : 입력된 전화번호를 자신의 전화번호로 등록한 사용자
    3. BELONG_TO = 0 : 사업자에 소속된 관리자가 아닌 사용자(개인 또는 sys.admin)
    4. CLASS >= 200 : sys.admin이 아닌 사용자
    */
    
    IF @USER_REG_ID IS NOT NULL THEN
		SET rtn_val = 0;
		SET msg_txt = 'Password changed successfully';
    ELSE
		CALL sp_req_use_same_phone(
			IN_USER_PHONE, 
            0, 
            TRUE, 
			@rtn_val, 
			@msg_txt
		);
        IF @rtn_val = TRUE THEN
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt;
			SIGNAL SQLSTATE '23000';
        ELSE
			SET rtn_val = 21302;
			SET msg_txt = 'Phone number not found';
			SIGNAL SQLSTATE '23000';
        END IF;
    END IF;
END