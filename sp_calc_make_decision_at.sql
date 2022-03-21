CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_make_decision_at`(
	IN IN_COLLECTOR_BIDDING_ID		BIGINT
)
BEGIN

	SELECT B.BIDDING_END_AT INTO @BIDDING_END_AT FROM COLLECTOR_BIDDING A INNER JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID WHERE A.ID = IN_COLLECTOR_BIDDING_ID;
	SET @MAX_DECISION_AT = ADDTIME(@BIDDING_END_AT, CONCAT(CAST(@max_selection_duration AS UNSIGNED), ':00:00'));
	UPDATE COLLECTOR_BIDDING SET MAX_DECISION_AT = @MAX_DECISION_AT WHERE ID = IN_COLLECTOR_BIDDING_ID;
    
END