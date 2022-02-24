CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_manager_exists_in_site`(
	IN IN_SITE_ID		BIGINT,
	IN IN_CLASS			INT,
    OUT OUT_PARAM		INT
)
BEGIN

/*
Procedure Name 	: sp_req_manager_exists_in_site
Input param 	: 1개
Output param 	: 1개
Job 			: IN_SITE_ID의 등록번호를 가진 사이트를 관리하는 magager.admin:201이 존재하는지 체크한후 존재한다면 1, 그렇지 않으면 0을 반환함
Update 			: 2022.01.15
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) INTO OUT_PARAM FROM USERS WHERE AFFILIATED_SITE = IN_SITE_ID AND CLASS = IN_CLASS;
END