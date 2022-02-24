CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_cs_manager_id_of_company`(
	IN IN_SITE_ID				BIGINT,								/*사이트 고유등록번호*/
	OUT MANAGER_ID				BIGINT								/*CS 담당 매니저 고유등록번호*/
)
BEGIN

/*
Procedure Name 	: sp_req_cs_manager_id_of_company
Input param 	: 0개
Output param 	: 1개
Job 			: 사이트가 소속한 사업자의 CS_MANAGER_ID를 반환한다.
Update 			: 2022.01.16
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	SELECT B.CS_MANAGER_ID INTO MANAGER_ID 
    FROM COMP_SITE A 
    LEFT JOIN COMPANY B
    ON A.COMP_ID = B.ID
    WHERE A.ID = IN_SITE_ID;

END