CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_make_decision_at`(
	IN IN_COLLECTOR_BIDDING_ID		BIGINT
)
BEGIN
    
    CALL sp_req_current_time(@REG_DT);
	CALL sp_req_policy_direction(
	/*수거자가 배출자의 최종입찰선정에 응답을 할 수 있는 최대의 시간으로서 배출자의 최종낙찰자선정일로부터의 기간을 반환받는다(단위:시간)*/
		'max_selection_duration',
		@max_selection_duration
	);

	SELECT B.BIDDING_END_AT INTO @BIDDING_END_AT 
    FROM COLLECTOR_BIDDING A 
    INNER JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID 
    WHERE A.ID = IN_COLLECTOR_BIDDING_ID;
    
	SET @MAX_DECISION_AT = ADDTIME(@BIDDING_END_AT, CONCAT(CAST(@max_selection_duration AS UNSIGNED), ':00:00'));
    
	UPDATE COLLECTOR_BIDDING 
    SET 
		MAX_DECISION_AT = @MAX_DECISION_AT,
        UPDATED_AT		= @REG_DT
    WHERE ID = IN_COLLECTOR_BIDDING_ID;
    
END