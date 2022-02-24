CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_find_user`(
	IN IN_USER_REG_ID		VARCHAR(50),		/*입력값 : 사용자 아이디*/
	IN IN_USER_NAME			VARCHAR(20),		/*입력값 : 사용자 고유번호*/
	IN IN_PHONE				VARCHAR(20),		/*입력값 : 사용자 등록 전화번호*/
	OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
	OUT msg_txt 			VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_find_user
Input param 	: 3개
Output param 	: 2개
Job 			: 사용자찾기기능으로서 사용자의 아이디와 이름, 전화번호로 해당사용자가 존재하는지 여부를 반환
Update 			: 2022.01.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) 
	INTO @CHK_COUNT 
	FROM USERS 
	WHERE 
		USER_ID = IN_USER_REG_ID AND 
		USER_NAME = IN_USER_NAME AND 
		PHONE = IN_PHONE;
	IF @CHK_COUNT = 0 THEN
		SET rtn_val = 25701;
		SET msg_txt = 'user does not exist';
	ELSE
		SELECT COUNT(ID) 
		INTO @CHK_COUNT 
		FROM USERS 
		WHERE 
			USER_ID = IN_USER_REG_ID AND 
			USER_NAME = IN_USER_NAME AND 
			PHONE = IN_PHONE AND 
            ACTIVE = TRUE;
		IF @CHK_COUNT = 0 THEN
			SET rtn_val = 25702;
			SET msg_txt = 'user is disabled';
		ELSE
			SET rtn_val = 0;
			SET msg_txt = 'user found';
		END IF;
	END IF;
END