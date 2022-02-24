CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_disposal_order_prev_transaction`(
	IN IN_DISPOSER_ORDER_ID				BIGINT,			/*입력값 : SITE_WSTE_DISPOSAL_ORDER.ID*/
    OUT OUT_WHOSE_TRANSACTION			BIGINT			/*출력값 : 이 배출오더가 기존거래인 경우에는 배출자가 지정한 COLLECTOR_ID가 반환되고 그렇지 않으면 NULL이 반환됨*/
)
BEGIN

/*
Procedure Name 	: sp_req_is_disposal_order_prev_transaction
Input param 	: 1개
Output param 	: 1개
Job 			: 이 배출오더가 기존거래인 경우에는 배출자가 지정한 COLLECTOR_ID가 반환되고 그렇지 않으면 NULL이 반환됨
Update 			: 2022.01.23
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COLLECTOR_ID INTO @COLLECTOR_ID FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = IN_DISPOSAL_ORDER_ID;
    
    IF @COLLECTOR_ID IS NULL THEN
		SET OUT_WHOSE_TRANSACTION = NULL;
    ELSE
		SET OUT_WHOSE_TRANSACTION = @COLLECTOR_ID;
    END IF;
END