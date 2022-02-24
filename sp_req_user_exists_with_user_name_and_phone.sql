CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_exists_with_user_name_and_phone`(
	IN IN_USER_NAME			VARCHAR(50),		/*입력값 : 사용자 이름*/
	IN IN_PHONE				VARCHAR(20),		/*입력값 : 사용자 등록 전화번호*/
	IN IN_ACTIVE			TINYINT,			/*입력값 : 사용자 뢀성화상태*/
	OUT OUT_PARAM 			INT					/*출력값 : 처리결과 반환값*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_exists_with_user_name_and_phone
Input param 	: 3개
Output param 	: 1개
Job 			: 사용자 이름과 전화번호로 사용자가 존재하는 여부 반환
Update 			: 2022.01.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	IF IN_ACTIVE IS NULL THEN
		SELECT COUNT(ID) 
        INTO OUT_PARAM 
        FROM USERS 
        WHERE 
			USER_NAME	 = IN_USER_NAME AND 
            PHONE		 = IN_PHONE;
    ELSE
		SELECT COUNT(ID) 
        INTO OUT_PARAM 
        FROM USERS 
        WHERE 
			USER_NAME	 = IN_USER_NAME AND 
            PHONE		 = IN_PHONE AND 
            ACTIVE		 = IN_ACTIVE;
    END IF;
END