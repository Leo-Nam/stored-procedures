CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_id`(
	IN IN_USER_NAME				VARCHAR(50),							/*입력값 : 사용자 이름*/
	IN IN_PHONE					VARCHAR(20),							/*입력값 : 사용자 등록 전화번호*/
    IN IN_ACTIVE				TINYINT,								/*입력값 : 사용자 활성화 상태*/
	IN IN_USER_TYPE				ENUM('person','company','system'),		/*입력값 : 사용자 타입*/
    OUT OUT_USER_REG_ID			VARCHAR(50),							/*입력값 : 사용자 아이디*/
    OUT rtn_val 				INT,									/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)							/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_id
Input param 	: 4개
Output param 	: 3개
Job 			: 입력 param의 IN_USER_NAME의 이름과 IN_PHONE의 전화번호를 사용하는 사용자의 USER_ID를 OUT_USER_REG_ID를 통하여 반환함
Update 			: 2022.01.12
Version			: 0.0.1
AUTHOR 			: Leo Nam

처리결과 / 메시지	: 0 - User ID Found
				: 21201 - User ID does not exist
				: 21202 - No user ID as a business administrator
				: 21203 - User ID as system administrator does not exist
				: 21204 - User type exception error
*/
	
	SET rtn_val = 0;
	SET msg_txt = 'User ID Found';
    
    IF IN_USER_TYPE = 'person' THEN
		IF IN_ACTIVE IS NULL THEN
			SELECT USER_ID INTO OUT_USER_REG_ID FROM USERS WHERE USER_NAME = IN_USER_NAME AND PHONE = IN_PHONE AND BELONG_TO = 0 AND CLASS >= 200;
		ELSE
			SELECT USER_ID INTO OUT_USER_REG_ID FROM USERS WHERE USER_NAME = IN_USER_NAME AND PHONE = IN_PHONE AND BELONG_TO = 0 AND CLASS >= 200 AND ACTIVE = IN_ACTIVE;
		END IF;
		
		IF USER_ID IS NULL THEN
			SET OUT_USER_REG_ID = NULL;
			SET rtn_val = 21201;
			SET msg_txt = 'Personal user ID does not exist';
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
		IF IN_USER_TYPE = 'company' THEN
			IF IN_ACTIVE IS NULL THEN
				SELECT USER_ID INTO OUT_USER_REG_ID FROM USERS WHERE USER_NAME = IN_USER_NAME AND PHONE = IN_PHONE AND BELONG_TO > 0 AND CLASS >= 200;
			ELSE
				SELECT USER_ID INTO OUT_USER_REG_ID FROM USERS WHERE USER_NAME = IN_USER_NAME AND PHONE = IN_PHONE AND BELONG_TO > 0 AND CLASS >= 200 AND ACTIVE = IN_ACTIVE;
			END IF;
			
			IF USER_ID IS NULL THEN
				SET OUT_USER_REG_ID = NULL;
				SET rtn_val = 21202;
				SET msg_txt = 'No user ID as a business administrator';
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
			IF IN_USER_TYPE = 'system' THEN
				IF IN_ACTIVE IS NULL THEN
					SELECT USER_ID INTO OUT_USER_REG_ID FROM USERS WHERE USER_NAME = IN_USER_NAME AND PHONE = IN_PHONE AND BELONG_TO = 0 AND CLASS < 200;
				ELSE
					SELECT USER_ID INTO OUT_USER_REG_ID FROM USERS WHERE USER_NAME = IN_USER_NAME AND PHONE = IN_PHONE AND BELONG_TO = 0 AND CLASS < 200 AND ACTIVE = IN_ACTIVE;
				END IF;
				
				IF USER_ID IS NULL THEN
					SET OUT_USER_REG_ID = NULL;
					SET rtn_val = 21203;
					SET msg_txt = 'User ID as system administrator does not exist';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
				SET rtn_val = 21204;
				SET msg_txt = 'User type exception error';
				SIGNAL SQLSTATE '23000';
			END IF;
		END IF;		
    END IF;
END