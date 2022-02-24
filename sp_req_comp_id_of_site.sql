CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_comp_id_of_site`(
	IN IN_SITE_ID		BIGINT,
    OUT OUT_COMP_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_comp_id_of_site
Input param 	: 1개
Output param 	: 1개
Job 			: 입력 IN_SITE_ID의 사이트가 속하는 사업자 고유등록번호 반환
Update 			: 2022.01.15
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	SELECT COMP_ID INTO OUT_COMP_ID FROM COMP_SITE WHERE ID = IN_SITE_ID;
END