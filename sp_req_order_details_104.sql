CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_order_details_104`(
	IN IN_ORDER_ID				BIGINT,
    OUT OUT_DETAILS				JSON
)
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS ORDER_DETAILS_104_TEMP (
		ORDER_ID							BIGINT,
		ORDER_CODE							VARCHAR(10),
        COLLECTOR_SITE_ID					BIGINT,
        COLLECTOR_SITE_NAME					VARCHAR(255),
		COLLECTOR_TRMT_BIZ_CODE				VARCHAR(4),    
		COLLECTOR_TRMT_BIZ_NAME				VARCHAR(255),  
        AVATAR_PATH							VARCHAR(255),
		DISPOSER_WSTE_LIST					JSON,
        STATE_CODE							INT,
        STATE								VARCHAR(20),
        STATE_CATEGORY_ID					INT,
        STATE_CATEGORY						VARCHAR(20)
        
	);        
    
    INSERT INTO ORDER_DETAILS_104_TEMP(
		ORDER_ID, 
        ORDER_CODE, 
        COLLECTOR_SITE_ID, 
        COLLECTOR_SITE_NAME, 
        COLLECTOR_TRMT_BIZ_CODE, 
        COLLECTOR_TRMT_BIZ_NAME, 
        AVATAR_PATH,
        STATE_CODE,
        STATE,
        STATE_CATEGORY_ID,
        STATE_CATEGORY
    )
    SELECT 
		A.ID,
        A.ORDER_CODE,
        B.COLLECTOR_SITE_ID,
        C.SITE_NAME,
        C.TRMT_BIZ_CODE,
        D.NAME,
        E.AVATAR_PATH,
        F.STATE_CODE,
        F.STATE,
        F.STATE_CATEGORY_ID,
        F.STATE_CATEGORY
    FROM SITE_WSTE_DISPOSAL_ORDER A
    LEFT JOIN WSTE_CLCT_TRMT_TRANSACTION B ON A.ID = B.DISPOSAL_ORDER_ID
    LEFT JOIN COMP_SITE C ON B.COLLECTOR_SITE_ID = C.ID
    LEFT JOIN WSTE_TRMT_BIZ D ON C.TRMT_BIZ_CODE = D.CODE
    LEFT JOIN USERS E ON C.ID = E.AFFILIATED_SITE
    LEFT JOIN V_BIDDING_STATE_NAME F ON C.ID = F.COLLECTOR_ID
    WHERE 
		A.ID = IN_ORDER_ID AND
        E.CLASS = 201 AND
        E.ACTIVE = TRUE AND
        F.DISPOSER_ORDER_ID = IN_ORDER_ID;  
	
    CALL sp_get_disposal_wste_lists(
		IN_ORDER_ID,
        @DISPOSER_WSTE_LIST
    );
    
    UPDATE ORDER_DETAILS_104_TEMP 
    SET 
		DISPOSER_WSTE_LIST = @DISPOSER_WSTE_LIST
    WHERE ORDER_ID = IN_ORDER_ID;
    
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'ORDER_ID'					, ORDER_ID, 
        'ORDER_CODE'				, ORDER_CODE, 
        'COLLECTOR_SITE_ID'			, COLLECTOR_SITE_ID, 
        'COLLECTOR_SITE_NAME'		, COLLECTOR_SITE_NAME, 
        'COLLECTOR_TRMT_BIZ_CODE'	, COLLECTOR_TRMT_BIZ_CODE, 
        'COLLECTOR_TRMT_BIZ_NAME'	, COLLECTOR_TRMT_BIZ_NAME, 
        'AVATAR_PATH'				, AVATAR_PATH, 
        'DISPOSER_WSTE_LIST'		, DISPOSER_WSTE_LIST, 
		'STATE'						, STATE, 
		'STATE_CODE'				, STATE_CODE, 
		'STATE_CATEGORY_ID'			, STATE_CATEGORY_ID, 
		'STATE_CATEGORY'			, STATE_CATEGORY
	)) 
    INTO OUT_DETAILS 
    FROM ORDER_DETAILS_104_TEMP;
	DROP TABLE IF EXISTS ORDER_DETAILS_104_TEMP;
END