CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_regid_by_user_id`(
	IN IN_USER_REG_ID		VARCHAR(50),
    OUT OUT_PARAM			BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_user_regid_by_user_id
Input param 	: 개
Output param 	: 1개
Job 			: 사용자 아이디로 사용자 고유등록번호를 반환한다
Update 			: 2022.01.15
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT ID INTO OUT_PARAM 
	FROM USERS 
	WHERE 
		USER_ID = IN_USER_REG_ID;
END