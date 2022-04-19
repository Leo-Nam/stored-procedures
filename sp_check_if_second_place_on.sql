CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_if_second_place_on`(
	IN IN_ORDER_ID				BIGINT,
	IN IN_BIDDING_ID			BIGINT,
    OUT OUT_SECOND_PLACE_ON		TINYINT
)
BEGIN
	SELECT COUNT(ID) INTO OUT_SECOND_PLACE_ON
    FROM SITE_WSTE_DISPOSAL_ORDER
    WHERE 
		ID = IN_ORDER_ID AND
        BIDDERS > 1 AND
        SECOND_PLACE = IN_BIDDING_ID AND
        (
			COLLECTOR_SELECTION_CONFIRMED = FALSE OR 
            (
				COLLECTOR_SELECTION_CONFIRMED IS NULL AND 
                COLLECTOR_MAX_DECISION_AT <= NOW()
            )
        ) AND 
        COLLECTOR_MAX_DECISION2_AT > NOW() AND
        COLLECTOR_SELECTION_CONFIRMED2 IS NULL;
END