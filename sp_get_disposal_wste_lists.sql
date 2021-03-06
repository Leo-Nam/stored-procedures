CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_disposal_wste_lists`(
	IN IN_DISPOSER_ORDER_ID				BIGINT,
    OUT OUT_DISPOSER_WSTE_LIST			JSON
)
BEGIN			
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'WSTE_REG_ID'			, WSTE_REG_ID, 
			'DISPOSAL_ORDER_ID'		, DISPOSAL_ORDER_ID, 
			'WSTE_CLASS'			, WSTE_CLASS, 
			'WSTE_CLASS_NM'			, WSTE_CLASS_NM, 
			'WSTE_APPEARANCE_NM'	, WSTE_APPEARANCE_NM, 
			'WSTE_QUANTITY'			, WSTE_QUANTITY, 
			'WSTE_UNIT'				, WSTE_UNIT
		)
	) 
	INTO OUT_DISPOSER_WSTE_LIST
	FROM V_WSTE_DISCHARGED_FROM_SITE
	WHERE DISPOSAL_ORDER_ID 		= IN_DISPOSER_ORDER_ID;

END