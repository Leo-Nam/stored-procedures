CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_site_addresses_by_site_id`(
	IN IN_SITE_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_site_addresses_by_site_id
Input param 	: 1개
Output param 	: 0개
Job 			: 사이트 고유등록번호로 사이트의 주소를 반환한다.
Update 			: 2022.01.20
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT * FROM V_COMP_SITE_ADDRESS WHERE SITE_ID = IN_SITE_ID AND ACTIVE = TRUE;
END