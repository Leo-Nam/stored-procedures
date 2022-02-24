CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_service_instruction_id_of_site`(
	IN IN_SITE_ID						BIGINT,			/*사이트의 고유등록번호(COMP_SITE.ID)*/
    OUT OUT_SERVICE_INSTRUCTION_ID		BIGINT			/*사이트가 사용하는 작업지시서의 고유등록번호(SITE_WORK_ORDER.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_req_service_instruction_id_of_site
Input param 	: 1개
Output param 	: 1개
Job 			: 사이트가 사용할 작업지시서의 고유등록번호(SITE_WORK_ORDER.ID)를 반환한다.
Update 			: 2022.01.19
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT IF(MAX(ID) IS NULL, NULL, MAX(ID)) INTO OUT_SERVICE_INSTRUCTION_ID
    FROM SITE_WORK_ORDER
    WHERE 
		SITE_ID = IN_SITE_ID AND
        ACTIVE = TRUE;
END