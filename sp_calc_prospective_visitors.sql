CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_prospective_visitors`(
	IN IN_DISPOSER_ORDER_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_calc_prospective_visitors
Input param 	: 1개
Job 			: 방문예정자수를 계산하여 PROSPECTIVE_VISITORS에 저장한다.
Update 			: 2022.03.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) INTO @PROSPECTIVE_VISITORS 
	FROM COLLECTOR_BIDDING 
	WHERE 
		DISPOSAL_ORDER_ID 	= IN_DISPOSER_ORDER_ID AND 
		DATE_OF_VISIT 		IS NOT NULL AND
		CANCEL_VISIT 		= FALSE AND
		RESPONSE_VISIT 		= TRUE;
        
	UPDATE SITE_WSTE_DISPOSAL_ORDER SET PROSPECTIVE_VISITORS = @PROSPECTIVE_VISITORS WHERE ID = IN_DISPOSER_ORDER_ID;
END