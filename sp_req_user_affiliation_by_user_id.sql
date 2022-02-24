CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_affiliation_by_user_id`(
	IN IN_USER_ID		BIGINT,				/* user id who wants to know where it belongs */
    OUT OUT_SITE_ID		BIGINT				/* return value : where the user belongs */
)
BEGIN

/*
Procedure Name 	: sp_req_user_affiliation_by_user_id
Input param 	: 1개
Output param 	: 1개(0 - 개인 사용자, 0 이외의 값 - 소속된 사업자 고유등록번호)
Job 			: 사용자의 소속을 리턴함
Update 			: 2022.02.17
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	SELECT AFFILIATED_SITE INTO OUT_SITE_ID FROM USERS WHERE ID = IN_USER_ID;	
END