CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_comp_name_by_site_id`(
	IN IN_SITE_ID			BIGINT,
    OUT OUT_COMP_NAME		VARCHAR(100)
)
BEGIN

/*
Procedure Name 	: sp_req_comp_name_by_site_id
Input param 	: 1개
Output param 	: 1개
Job 			: 사이트 아이디(COMP_SITE.ID)로 사이트가 소속하고 있는 사업자의 이름을 반환한다.
Update 			: 2022.01.17
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT A.COMP_NAME 
    INTO OUT_COMP_NAME 
    FROM COMPANY A 
    LEFT JOIN 
		COMP_SITE B ON A.ID = B.COMP_ID 
    WHERE B.ID = IN_SITE_ID;
END