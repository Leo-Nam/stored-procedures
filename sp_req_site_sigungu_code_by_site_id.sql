CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_site_sigungu_code_by_site_id`(
	IN IN_SITE_ID				BIGINT					/*사이트의 고유등록번호(COMP_SITE.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_req_site_sigungu_code_by_site_id
Input param 	: 1개
Job 			: 사이트의 고유등록번호로 사이트가 소재하는 시군구의 코드(KIKCD_B_CODE) 앞 5자리를 반환함
Update 			: 2022.01.22
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT LEFT(KIKCD_B_CODE, 5) FROM BUSINESS_AREA WHERE SITE_ID = IN_SITE_ID;
END