CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_site_head_office`(
	IN IN_SITE_ID		BIGINT,
    OUT OUT_PARAM		TINYINT
)
BEGIN

/*
Procedure Name 	: sp_req_is_site_head_office
Input param 	: 1개
Output param 	: 1개
Job 			: 입력 param의 IN_SITE_ID를 사이트 고유등록번호로 사용하는 사이트가 존재하는지 여부 반환
Update 			: 2022.01.15
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT HEAD_OFFICE
	INTO OUT_PARAM 
	FROM COMP_SITE 
	WHERE ID 	= IN_SITE_ID;
END