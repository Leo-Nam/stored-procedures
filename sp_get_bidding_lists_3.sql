CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_bidding_lists_3`(
	IN IN_COLLECTOR_SITE_ID			BIGINT,
    OUT OUT_BIDDING_LIST			JSON
)
BEGIN
		
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'COLLECTOR_BIDDING_ID'			, A.ID, 
				'COLLECTOR_SITE_ID'				, A.COLLECTOR_ID, 
                'COLLECTOR_SI_DO'				, C.SI_DO, 
                'COLLECTOR_SI_GUN_GU'			, C.SI_GUN_GU, 
                'COLLECTOR_STATE'				, D.STATE, 
                'COLLECTOR_STATE_CODE'			, D.STATE_CODE, 
                'COLLECTOR_LAT'					, B.LAT, 
                'COLLECTOR_LNG'					, B.LNG, 
                'COLLECTOR_SITE_NAME'			, B.SITE_NAME, 
                'COLLECTOR_TRMT_BIZ_CODE'		, B.TRMT_BIZ_CODE, 
                'COLLECTOR_TRMT_BIZ_NM'			, E.NAME, 
                'COLLECTOR_BID_AMOUNT'			, A.BID_AMOUNT, 
                'COLLECTOR_GREENHOUSE_GAS'		, A.GREENHOUSE_GAS, 
                'COLLECTOR_WINNER'				, A.WINNER, 
                'COLLECTOR_ACTIVE'				, A.ACTIVE, 
                'COLLECTOR_CANCEL_VISIT'		, A.CANCEL_VISIT, 
                'COLLECTOR_CANCEL_BIDDING'		, A.CANCEL_BIDDING, 
                'COLLECTOR_DATE_OF_VISIT'		, A.DATE_OF_VISIT, 
                'COLLECTOR_DATE_OF_BIDDING'		, A.DATE_OF_BIDDING, 
                'COLLECTOR_SELECTED'			, A.SELECTED, 
                'COLLECTOR_SELECTED_AT'			, A.SELECTED_AT, 
                'COLLECTOR_MAKE_DECISION'		, A.MAKE_DECISION, 
                'COLLECTOR_MAKE_DECISION_AT'	, A.MAKE_DECISION_AT,
                'DISPOSER_RESPONSE_VISIT'		, A.RESPONSE_VISIT, 
                'DISPOSER_RESPONSE_VISIT_AT'	, A.RESPONSE_VISIT_AT,
                'DISPOSER_REJECT_BIDDING'		, A.REJECT_BIDDING, 
                'DISPOSER_REJECT_BIDDING_AT'	, A.REJECT_BIDDING_AT, 
                'COLLECTOR_STATE_CATEGORY_ID'	, D.STATE_CATEGORY_ID, 
                'COLLECTOR_STATE_CATEGORY'		, D.STATE_CATEGORY
			)
		) 
        INTO OUT_BIDDING_LIST
        FROM COLLECTOR_BIDDING A 
        LEFT JOIN COMP_SITE B 				ON A.COLLECTOR_ID 	= B.ID
        LEFT JOIN KIKCD_B C 				ON B.KIKCD_B_CODE 	= C.B_CODE
        LEFT JOIN V_BIDDING_STATE_NAME D 	ON A.ID 			= D.COLLECTOR_BIDDING_ID
        LEFT JOIN WSTE_TRMT_BIZ E 			ON B.TRMT_BIZ_CODE 	= E.CODE
        WHERE A.COLLECTOR_ID		 		= IN_COLLECTOR_SITE_ID;
END