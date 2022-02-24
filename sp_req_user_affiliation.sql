CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_affiliation`(
	IN IN_USER_REG_ID		VARCHAR(50),		/* user id who wants to know where it belongs */
    OUT OUT_BELONG_TO		BIGINT				/* return value : where the user belongs */
)
BEGIN

/*
Procedure Name 	: sp_req_user_affiliation
Input param 	: 1개
Output param 	: 1개(0 - 개인 사용자, 0 이외의 값 - 소속된 사업자 고유등록번호)
Job 			: 사용자의 소속을 리턴함
Update 			: 2022.01.07
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT BELONG_TO INTO OUT_BELONG_TO FROM USERS WHERE USER_ID = IN_USER_REG_ID;	
END