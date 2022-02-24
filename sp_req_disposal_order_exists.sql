CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_disposal_order_exists`(
	IN IN_DISPOSER_ORDER_ID				BIGINT,				/*SITE_WSTE_DISPOSAL_ORDER.ID*/
    OUT OUT_PARAM						INT					/*폐기물 배출 요청 내역이 존재하면 1, 그렇지 않으면 0 반환*/
)
BEGIN

/*
Procedure Name 	: sp_req_disposal_order_exists
Input param 	: 1개
Output param 	: 1개
Job 			: 폐기물 배출 요청 내역이 존재하는지 검사
Update 			: 2022.01.19
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) INTO OUT_PARAM FROM SITE_WSTE_DISPOSAL_ORDER WHERE ACTIVE = TRUE AND ID = IN_DISPOSER_ORDER_ID;
END