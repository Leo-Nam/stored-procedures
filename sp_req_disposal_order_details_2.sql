CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_disposal_order_details_2`(
	IN IN_DISPOSER_ORDER_ID							BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_disposal_order_details_2
Input param 	: 1개
Job 			: 배출자의 배출신청에 대한 입찰 상세정보
Update 			: 2022.02.15
Version			: 0.0.4
AUTHOR 			: Leo Nam
*/
    

    CALL sp_req_disposal_order_details(
		IN_DISPOSER_ORDER_ID
    );
END