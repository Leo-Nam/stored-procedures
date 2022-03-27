CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_bidders`(
	IN IN_DISPOSER_ORDER_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_calc_bidders
Input param 	: 1개
Job 			: 투찰자수를 계산하여 BIDDERS에 저장한다.
Update 			: 2022.03.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    CALL sp_req_current_time(@REG_DT);
    
	SELECT COUNT(ID) INTO @BIDDERS 
	FROM COLLECTOR_BIDDING 
	WHERE 
		DISPOSAL_ORDER_ID 		= IN_DISPOSER_ORDER_ID AND 
		DATE_OF_BIDDING			IS NOT NULL AND
		CANCEL_BIDDING 			= FALSE AND
		REJECT_BIDDING 			<> TRUE AND
        REJECT_BIDDING_APPLY	<> TRUE AND
        ACTIVE					= TRUE;
        
	UPDATE SITE_WSTE_DISPOSAL_ORDER 
    SET 
		BIDDERS 		= @BIDDERS,
        UPDATED_AT 		= @REG_DT
    WHERE ID = IN_DISPOSER_ORDER_ID;
END