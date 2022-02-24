CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_comp_site_addresses`(
	IN IN_COMP_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_comp_site_addresses
Input param 	: 1개
Output param 	: 0개
Job 			: 입력받은 사업자 고유등록번호에 속하는 모든 사이트의 주소를 반환한다.
Update 			: 2022.01.20
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT * FROM V_COMP_SITE_ADDRESS WHERE COMP_ID = IN_COMP_ID AND ACTIVE = TRUE;
END