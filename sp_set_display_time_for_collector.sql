CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_set_display_time_for_collector`(
	IN IN_DISPOSER_ORDER_ID			BIGINT,
	IN IN_COLLECTOR_BIDDING_ID		BIGINT,
	IN IN_COLLECTOR_CATEGORY_ID		INT,
    OUT OUT_DISPLAY_TIME			DATETIME
)
BEGIN
	SELECT 
	CASE
		WHEN IN_COLLECTOR_CATEGORY_ID = 1
			THEN (
				SELECT A.VISIT_END_AT
				FROM SITE_WSTE_DISPOSAL_ORDER A
                LEFT JOIN COLLECTOR_BIDDING B ON A.ID = B.DISPOSAL_ORDER_ID
				WHERE 
					A.ID = IN_DISPOSER_ORDER_ID AND
                    B.ID = IN_COLLECTOR_BIDDING_ID
			)
		WHEN IN_COLLECTOR_CATEGORY_ID = 2
			THEN (
				SELECT A.VISIT_END_AT
				FROM SITE_WSTE_DISPOSAL_ORDER A
                LEFT JOIN COLLECTOR_BIDDING B ON A.ID = B.DISPOSAL_ORDER_ID
				WHERE 
					A.ID = IN_DISPOSER_ORDER_ID AND
                    B.ID = IN_COLLECTOR_BIDDING_ID
			)
		WHEN IN_COLLECTOR_CATEGORY_ID = 3
			THEN (
				SELECT A.BIDDING_END_AT
				FROM SITE_WSTE_DISPOSAL_ORDER A
                LEFT JOIN COLLECTOR_BIDDING B ON A.ID = B.DISPOSAL_ORDER_ID
				WHERE 
					A.ID = IN_DISPOSER_ORDER_ID AND
                    B.ID = IN_COLLECTOR_BIDDING_ID
			)
		WHEN IN_COLLECTOR_CATEGORY_ID = 4
			THEN (
				SELECT A.BIDDING_END_AT
				FROM SITE_WSTE_DISPOSAL_ORDER A
                LEFT JOIN COLLECTOR_BIDDING B ON A.ID = B.DISPOSAL_ORDER_ID
				WHERE 
					A.ID = IN_DISPOSER_ORDER_ID AND
                    B.ID = IN_COLLECTOR_BIDDING_ID
			)
		WHEN IN_COLLECTOR_CATEGORY_ID = 5
			THEN (
				SELECT IF(B.BIDDING_RANK = 1, 
					A.MAX_DECISION_AT,
                    IF(A.COLLECTOR_SELECTION_CONFIRMED IS NOT NULL,
						IF(A.COLLECTOR_SELECTION_CONFIRMED = TRUE,
							A.COLLECTOR_SELECTION_CONFIRMED_AT,
                            A.MAX_DECISION2_AT
                        ),
						IF(A.MAX_DECISION_AT <= NOW(),
							A.MAX_DECISION2_AT,
                            A.MAX_DECISION_AT
                        )
					)
                )
				FROM SITE_WSTE_DISPOSAL_ORDER A
                LEFT JOIN COLLECTOR_BIDDING B ON A.ID = B.DISPOSAL_ORDER_ID
				WHERE 
					A.ID = IN_DISPOSER_ORDER_ID AND
                    B.ID = IN_COLLECTOR_BIDDING_ID
			)
		WHEN IN_COLLECTOR_CATEGORY_ID = 6
			THEN (
				SELECT IF(B.BIDDING_RANK = 1, 
					A.MAX_DECISION_AT,
                    IF(A.COLLECTOR_SELECTION_CONFIRMED IS NOT NULL,
						IF(A.COLLECTOR_SELECTION_CONFIRMED = TRUE,
							A.COLLECTOR_SELECTION_CONFIRMED_AT,
                            A.MAX_DECISION2_AT
                        ),
						IF(A.MAX_DECISION_AT <= NOW(),
							A.MAX_DECISION2_AT,
                            A.MAX_DECISION_AT
                        )
					)
                )
				FROM SITE_WSTE_DISPOSAL_ORDER A
                LEFT JOIN COLLECTOR_BIDDING B ON A.ID = B.DISPOSAL_ORDER_ID
				WHERE 
					A.ID = IN_DISPOSER_ORDER_ID AND
                    B.ID = IN_COLLECTOR_BIDDING_ID
			)
		WHEN IN_COLLECTOR_CATEGORY_ID = 7
			THEN (
				SELECT A.CLOSE_AT
				FROM SITE_WSTE_DISPOSAL_ORDER A
                LEFT JOIN COLLECTOR_BIDDING B ON A.ID = B.DISPOSAL_ORDER_ID
				WHERE 
					A.ID = IN_DISPOSER_ORDER_ID AND
                    B.ID = IN_COLLECTOR_BIDDING_ID
			)
		ELSE NULL
	END INTO OUT_DISPLAY_TIME;
END