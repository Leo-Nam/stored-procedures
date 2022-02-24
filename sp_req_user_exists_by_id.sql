CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_exists_by_id`(
	IN IN_USER_ID		BIGINT,
    IN IN_ACTIVE			TINYINT,
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_exists
Input param 	: 2개
Output param 	: 2개
Job 			: 입력 param의 IN_USER_ID를 사용자 고유등록번호로 사용하는 사용자가 존재하는지 여부 반환
Update 			: 2022.01.28
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.2)
*/

	IF IN_ACTIVE IS NULL THEN
		SELECT COUNT(ID) INTO @CHK_COUNT 
        FROM USERS 
        WHERE 
			ID = IN_USER_ID;
            
		IF @CHK_COUNT = 0 THEN
			SET rtn_val = 26201;
			SET msg_txt = 'user not fouund';
        ELSE
			SET rtn_val = 0;
			SET msg_txt = 'Success7777';
        END IF;
    ELSE
		SELECT COUNT(ID) INTO @CHK_COUNT 
        FROM USERS 
        WHERE 
			ID = IN_USER_ID 
            AND ACTIVE = IN_ACTIVE;
            
		IF @CHK_COUNT = 0 THEN
			SET rtn_val = 26202;
			SET msg_txt = 'user not fouund';
        ELSE
			SET rtn_val = 0;
			SET msg_txt = 'Success6666';
        END IF;
    END IF;
END