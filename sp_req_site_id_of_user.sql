CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_site_id_of_user`(
	IN IN_USER_REG_ID	VARCHAR(50),
    OUT OUT_SITE_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_site_id_of_user
Input param 	: 1개
Output param 	: 1개
Job 			: 사용자가 속한 사이트의 고유등록번호를 반환한다.
Update 			: 2022.01.15
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT AFFILIATED_SITE INTO OUT_SITE_ID FROM USERS WHERE USER_ID = IN_USER_REG_ID;
END