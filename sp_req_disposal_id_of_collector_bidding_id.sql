CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_disposal_id_of_collector_bidding_id`(
	IN IN_COLLECTOR_BIDDING_ID		BIGINT,
    OUT OUT_DISPOSER_ORDER_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_disposal_id_of_collector_bidding_id
Input param 	: 1개
Output param 	: 1개
Job 			: COLLECTOR_BIDDING.ID로 해당 폐기물 처리 신청을 한 disposal_order_id(SITE_WSTE_DISPOSAL_ORDER.ID)를 반환한다.
Update 			: 2022.01.20
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT DISPOSAL_ORDER_ID INTO OUT_DISPOSER_ORDER_ID FROM COLLECTOR_BIDDING WHERE ID = IN_COLLECTOR_BIDDING_ID;
END