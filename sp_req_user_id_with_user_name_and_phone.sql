CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_id_with_user_name_and_phone`(
	IN IN_USER_NAME						VARCHAR(50),		/*입력값 : 사용자 이름*/
	IN IN_PHONE							VARCHAR(20),		/*입력값 : 사용자 등록 전화번호*/
	IN IN_ACTIVE						TINYINT,			/*입력값 : 사용자 뢀성화상태*/
	OUT OUT_USER_REG_ID					VARCHAR(50)			/*출력값 : 사용자 아이디*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_id_with_user_name_and_phone
Input param 	: 3개
Output param 	: 1개
Job 			: 사용자 이름과 전화번호로 사용자가 아이디를 반환
Update 			: 2022.01.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT USER_ID
    INTO OUT_USER_REG_ID
	FROM USERS 
	WHERE 
		USER_NAME 	= IN_USER_NAME AND 
		PHONE 		= IN_PHONE AND 
		ACTIVE 		= IN_ACTIVE;
END