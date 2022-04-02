CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_transaction_info`(
	IN IN_DISPOSER_ORDER_ID				BIGINT,
    OUT OUT_TRANSACTION_INFO			JSON
)
BEGIN   
    
	CREATE TEMPORARY TABLE IF NOT EXISTS TRANSACTION_INFO_TEMP (
		TRANSACTION_ID					BIGINT,
		DISPOSAL_ORDER_ID				BIGINT,
		COLLECT_ASK_END_AT				DATETIME,
		COLLECTING_TRUCK_ID				BIGINT,
		TRUCK_DRIVER_ID					BIGINT,
		TRUCK_START_AT					DATETIME,
		COLLECT_END_AT					DATETIME,
		QCC_IMG_PATH					VARCHAR(255),
        CONTRACT_ID						BIGINT,
        DATE_OF_VISIT					DATETIME,
        VISIT_START_AT					DATETIME,
        VISIT_END_AT					DATETIME,
        COLLECTOR_REPORTED				TINYINT,
        COLLECTOR_REPORTED_AT			DATETIME,
        CONFIRMED						TINYINT,
        CONFIRMED_AT					DATETIME,
        IN_PROGRESS						TINYINT,
        TRANSACTION_TYPE				VARCHAR(20),
        STATE_INFO						JSON,
        WSTE_INFO						JSON,
        IMG_INFO						JSON
	);     
    
    
	INSERT INTO 
	TRANSACTION_INFO_TEMP(
		TRANSACTION_ID,
		DISPOSAL_ORDER_ID,
		COLLECT_ASK_END_AT,
		COLLECTING_TRUCK_ID,
		TRUCK_DRIVER_ID,
		TRUCK_START_AT,
		COLLECT_END_AT,
		QCC_IMG_PATH,
		CONTRACT_ID,
		DATE_OF_VISIT,
		VISIT_START_AT,
		VISIT_END_AT,
        COLLECTOR_REPORTED,
        COLLECTOR_REPORTED_AT,
        CONFIRMED,
        CONFIRMED_AT,
        IN_PROGRESS,
        TRANSACTION_TYPE
	)
	SELECT 
		ID,
		DISPOSAL_ORDER_ID,
		COLLECT_ASK_END_AT,
		COLLECTING_TRUCK_ID,
		TRUCK_DRIVER_ID,
		TRUCK_START_AT,
		COLLECT_END_AT,
		QCC_IMG_PATH,
		CONTRACT_ID,
		DATE_OF_VISIT,
		VISIT_START_AT,
		VISIT_END_AT,
		COLLECTOR_REPORTED,
		COLLECTOR_REPORTED_AT,
		CONFIRMED,
		CONFIRMED_AT,
        IN_PROGRESS,
        IF(COLLECTOR_SITE_ID IS NULL, '입찰거래', '기존거래')
	FROM WSTE_CLCT_TRMT_TRANSACTION
    WHERE 
		DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND
        IN_PROGRESS = TRUE; 
        
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'STATE'						, STATE, 
		'STATE_CODE'				, TRANSACTION_STATE_CODE, 
		'STATE_CATEGORY'			, STATE_CATEGORY, 
		'STATE_CATEGORY_ID'			, STATE_CATEGORY_ID
	)) 
	INTO @STATE_INFO
	FROM V_TRANSACTION_STATE_NAME
    WHERE  
		DISPOSER_ORDER_ID = IN_DISPOSER_ORDER_ID AND
        IN_PROGRESS = TRUE; 
        
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'WSTE_CODE'					, A.WSTE_CODE,
		'WSTE_NM'					, B.NAME,
		'WSTE_QUANTITY'				, A.WSTE_QUANTITY,
		'WSTE_UNIT'					, A.WSTE_UNIT,
		'TRMT_METHOD_CODE'			, A.TRMT_METHOD_CODE,
		'TRMT_METHOD_NM'			, C.NAME
	)) 
	INTO @WSTE_INFO
	FROM WSTE_CLCT_TRMT_TRANSACTION A
    LEFT JOIN WSTE_CODE B ON A.WSTE_CODE = B.CODE
    LEFT JOIN WSTE_TRMT_METHOD C ON A.TRMT_METHOD_CODE = C.CODE
    WHERE  
		DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND
        IN_PROGRESS = TRUE; 
    
    UPDATE TRANSACTION_INFO_TEMP
    SET 
		STATE_INFO 	= @STATE_INFO,
		WSTE_INFO 	= @WSTE_INFO
    WHERE DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID;
    
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'TRANSACTION_ID'			, TRANSACTION_ID, 
		'DISPOSAL_ORDER_ID'			, DISPOSAL_ORDER_ID, 
		'COLLECT_ASK_END_AT'		, COLLECT_ASK_END_AT, 
		'COLLECTING_TRUCK_ID'		, COLLECTING_TRUCK_ID, 
		'TRUCK_DRIVER_ID'			, TRUCK_DRIVER_ID, 
		'TRUCK_START_AT'			, TRUCK_START_AT, 
		'COLLECT_END_AT'			, COLLECT_END_AT, 
		'QCC_IMG_PATH'				, QCC_IMG_PATH, 
		'CONTRACT_ID'				, CONTRACT_ID, 
		'DATE_OF_VISIT'				, DATE_OF_VISIT, 
		'VISIT_START_AT'			, VISIT_START_AT, 
		'VISIT_END_AT'				, VISIT_END_AT, 
		'COLLECTOR_REPORTED'		, COLLECTOR_REPORTED, 
		'COLLECTOR_REPORTED_AT'		, COLLECTOR_REPORTED_AT, 
		'CONFIRMED'					, CONFIRMED, 
		'CONFIRMED_AT'				, CONFIRMED_AT, 
		'IN_PROGRESS'				, IN_PROGRESS, 
		'TRANSACTION_TYPE'			, TRANSACTION_TYPE, 
		'STATE_INFO'				, STATE_INFO, 
		'WSTE_INFO'					, WSTE_INFO, 
		'IMG_INFO'					, IMG_INFO
	)) 
	INTO OUT_TRANSACTION_INFO
	FROM TRANSACTION_INFO_TEMP
	WHERE DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID;
	DROP TABLE IF EXISTS TRANSACTION_INFO_TEMP;

END