CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_my_disposal_lists_with_json_20220523`(
	IN IN_USER_ID							BIGINT,
    IN IN_USER_TYPE							VARCHAR(20),
    OUT rtn_val								INT,
    OUT msg_txt								VARCHAR(200),
    OUT json_data							JSON
)
BEGIN

/*
Procedure Name 	: sp_retrieve_my_disposal_lists_with_json_20220523
Input param 	: 2개
Output param 	: 3개
Job 			: 배출자 메인 페이지 로딩시 필요한 자료 반환.
Update 			: 2022.02.17
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 								INT DEFAULT 0;
    DECLARE endOfRow 								TINYINT DEFAULT FALSE;    
    DECLARE CUR_DISPOSER_ORDER_ID					BIGINT;
    DECLARE CUR_DISPOSER_ORDER_CODE					VARCHAR(10);  
    DECLARE CUR_DISPOSER_SITE_ID					BIGINT;    
    DECLARE CUR_DISPOSER_ID							BIGINT;    
    DECLARE CUR_DISPOSER_VISIT_START_AT				DATETIME;
    DECLARE CUR_DISPOSER_VISIT_END_AT				DATETIME;
    DECLARE CUR_DISPOSER_BIDDING_END_AT				DATETIME;
    DECLARE CUR_DISPOSER_OPEN_AT					DATETIME;
    DECLARE CUR_DISPOSER_CLOSE_AT					DATETIME;
    DECLARE CUR_DISPOSER_VISIT_EARLY_CLOSING		TINYINT;
    DECLARE CUR_DISPOSER_VISIT_EARLY_CLOSED_AT		DATETIME;
    DECLARE CUR_DISPOSER_BIDDING_EARLY_CLOSING		TINYINT;
    DECLARE CUR_DISPOSER_BIDDING_EARLY_CLOSED_AT	DATETIME;
    DECLARE CUR_DISPOSER_CREATED_AT					DATETIME;
    DECLARE CUR_DISPOSER_UPDATED_AT					DATETIME;    
    DECLARE CUR_STATE								VARCHAR(20);
    DECLARE CUR_STATE_CODE							INT;
    DECLARE CUR_STATE_CATEGORY_ID					INT;
    DECLARE CUR_STATE_CATEGORY						VARCHAR(45);
    DECLARE CUR_PROSPECTIVE_VISITORS				INT;
    DECLARE CUR_BIDDERS								INT;
    DECLARE CUR_TRANSACTION_ID						BIGINT;
    DECLARE CUR_TRANSACTION_STATE_CODE				INT;
    DECLARE CUR_EXISTING_TRANSACTION				TINYINT;
	DECLARE VAR_IMG_PATH 							VARCHAR(45) DEFAULT NULL;
	DECLARE VAR_WSTE_LIST 							JSON DEFAULT NULL;
	DECLARE VAR_DISPLAY_DATE 						DATETIME DEFAULT NULL;
	DECLARE VAR_CHECK_STATE			 				TINYINT DEFAULT FALSE;
	DECLARE VAR_EXISTING_TRANSACTION 				TINYINT DEFAULT FALSE;
	DECLARE VAR_DETAILS		 						JSON DEFAULT NULL;
	DECLARE VAR_STATE_CODE			 				INT DEFAULT FALSE;
	DECLARE VAR_MIN_DISPOSAL_DURATION 				INT DEFAULT FALSE;
    DECLARE TEMP_CURSOR		 						CURSOR FOR 
	SELECT 
		A.ID, 
        A.ORDER_CODE, 
        A.SITE_ID,      
        A.DISPOSER_ID,        
        A.VISIT_START_AT,
        A.VISIT_END_AT,
        A.BIDDING_END_AT,
        A.OPEN_AT,
        A.CLOSE_AT,
        A.VISIT_EARLY_CLOSING,
        A.VISIT_EARLY_CLOSED_AT,
        A.BIDDING_EARLY_CLOSING,
        A.BIDDING_EARLY_CLOSED_AT,
        A.CREATED_AT,
        A.UPDATED_AT,
        B.STATE, 
        B.STATE_CODE, 
        B.STATE_CATEGORY_ID, 
        B.STATE_CATEGORY, 
        A.PROSPECTIVE_VISITORS, 
        A.BIDDERS, 
        A.TRANSACTION_ID, 
        E.TRANSACTION_STATE_CODE,
        IF(E.DISPOSAL_ORDER_ID = A.ID AND 
            A.COLLECTOR_ID IS NOT NULL,
            1,
            0
		)
    FROM SITE_WSTE_DISPOSAL_ORDER A
    LEFT JOIN V_ORDER_STATE_NAME B 	ON A.ID 		= B.DISPOSER_ORDER_ID
    LEFT JOIN COMP_SITE C 			ON A.SITE_ID 	= C.ID
    LEFT JOIN COMPANY D 			ON C.COMP_ID 	= D.ID
    LEFT JOIN V_TRANSACTION_STATE E ON A.ID = E.DISPOSAL_ORDER_ID
	WHERE 
		B.STATE 			IS NOT NULL AND 
        A.IS_DELETED 		= FALSE AND
		B.STATE_CODE 		<> 105 AND 
        IF (IN_USER_TYPE	= 'Person', 
            A.DISPOSER_ID 	= IN_USER_ID, 
            C.ACTIVE 		= TRUE AND 
            D.ACTIVE 		= TRUE AND 
            A.SITE_ID 		IS NOT NULL AND 
            A.SITE_ID 		IN (
				SELECT AFFILIATED_SITE 
                FROM USERS 
                WHERE 
					ID 		= IN_USER_ID AND 
                    ACTIVE 	= TRUE
			)
		)/* AND
		(
			(
				B.DISPOSER_ORDER_ID = A.ID AND
				A.COLLECTOR_ID IS NULL 
			) OR
			(
				E.DISPOSAL_ORDER_ID = A.ID AND 
				E.TRANSACTION_STATE_CODE IN (250, 251, 252) AND
				A.COLLECTOR_ID IS NOT NULL
			)
		)*/; 
            
            
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
	CREATE TEMPORARY TABLE IF NOT EXISTS RETRIEVE_MY_DISPOSAL_LISTS_WITH_JSON_20220523 (
		DISPOSER_ORDER_ID					BIGINT,
		DISPOSER_ORDER_CODE					VARCHAR(10),
		DISPOSER_SITE_ID					BIGINT,    
		DISPOSER_ID							BIGINT,    
		DISPOSER_VISIT_START_AT				DATETIME,
		DISPOSER_VISIT_END_AT				DATETIME,
		DISPOSER_BIDDING_END_AT				DATETIME,
		DISPOSER_OPEN_AT					DATETIME,
		DISPOSER_CLOSE_AT					DATETIME,
		DISPOSER_VISIT_EARLY_CLOSING		TINYINT,
		DISPOSER_VISIT_EARLY_CLOSED_AT		DATETIME,
		DISPOSER_BIDDING_EARLY_CLOSING		TINYINT,
		DISPOSER_BIDDING_EARLY_CLOSED_AT	DATETIME,
		DISPOSER_CREATED_AT					DATETIME,
		DISPOSER_UPDATED_AT					DATETIME,    
		STATE								VARCHAR(20),
		STATE_CODE							INT,
		STATE_CATEGORY_ID					INT,
		STATE_CATEGORY						VARCHAR(45),
		PROSPECTIVE_VISITORS				INT,
		BIDDERS								INT,
		TRANSACTION_ID						BIGINT,
        DISPLAY_DATE						DATETIME,
        MIN_DISPOSAL_DURATION				INT,
		IMG_PATH							JSON,
		WSTE_LIST							JSON,
        CHECK_STATE							TINYINT,
        TRANSACTION_TYPE					VARCHAR(20),
        DETAILS								JSON
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP        
		FETCH TEMP_CURSOR 
		INTO 
			CUR_DISPOSER_ORDER_ID,
			CUR_DISPOSER_ORDER_CODE,
			CUR_DISPOSER_SITE_ID,    
			CUR_DISPOSER_ID,    
			CUR_DISPOSER_VISIT_START_AT,
			CUR_DISPOSER_VISIT_END_AT,
			CUR_DISPOSER_BIDDING_END_AT,
			CUR_DISPOSER_OPEN_AT,
			CUR_DISPOSER_CLOSE_AT,
			CUR_DISPOSER_VISIT_EARLY_CLOSING,
			CUR_DISPOSER_VISIT_EARLY_CLOSED_AT,
			CUR_DISPOSER_BIDDING_EARLY_CLOSING,
			CUR_DISPOSER_BIDDING_EARLY_CLOSED_AT,
			CUR_DISPOSER_CREATED_AT,
			CUR_DISPOSER_UPDATED_AT,    
			CUR_STATE,
			CUR_STATE_CODE,   
			CUR_STATE_CATEGORY_ID,
			CUR_STATE_CATEGORY,
			CUR_PROSPECTIVE_VISITORS,
			CUR_BIDDERS,
			CUR_TRANSACTION_ID,
			CUR_TRANSACTION_STATE_CODE,
			CUR_EXISTING_TRANSACTION;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		RETRIEVE_MY_DISPOSAL_LISTS_WITH_JSON_20220523(
			DISPOSER_ORDER_ID, 
			DISPOSER_ORDER_CODE, 
			DISPOSER_SITE_ID,     
			DISPOSER_ID,     
			DISPOSER_VISIT_START_AT,
			DISPOSER_VISIT_END_AT,
			DISPOSER_BIDDING_END_AT,
			DISPOSER_OPEN_AT,
			DISPOSER_CLOSE_AT,
			DISPOSER_VISIT_EARLY_CLOSING,
			DISPOSER_VISIT_EARLY_CLOSED_AT,
			DISPOSER_BIDDING_EARLY_CLOSING,
			DISPOSER_BIDDING_EARLY_CLOSED_AT,
			DISPOSER_CREATED_AT,
			DISPOSER_UPDATED_AT,        
			STATE, 
			STATE_CODE, 
			STATE_CATEGORY_ID, 
			STATE_CATEGORY, 
			PROSPECTIVE_VISITORS, 
			BIDDERS, 
			TRANSACTION_ID
		)
		VALUES(
			CUR_DISPOSER_ORDER_ID, 
			CUR_DISPOSER_ORDER_CODE, 
			CUR_DISPOSER_SITE_ID,     
			CUR_DISPOSER_ID,     
			CUR_DISPOSER_VISIT_START_AT,
			CUR_DISPOSER_VISIT_END_AT,
			CUR_DISPOSER_BIDDING_END_AT,
			CUR_DISPOSER_OPEN_AT,
			CUR_DISPOSER_CLOSE_AT,
			CUR_DISPOSER_VISIT_EARLY_CLOSING,
			CUR_DISPOSER_VISIT_EARLY_CLOSED_AT,
			CUR_DISPOSER_BIDDING_EARLY_CLOSING,
			CUR_DISPOSER_BIDDING_EARLY_CLOSED_AT,
			CUR_DISPOSER_CREATED_AT,
			CUR_DISPOSER_UPDATED_AT,            
			CUR_STATE, 
			CUR_STATE_CODE, 
			CUR_STATE_CATEGORY_ID, 
			CUR_STATE_CATEGORY, 
			CUR_PROSPECTIVE_VISITORS, 
			CUR_BIDDERS, 
			CUR_TRANSACTION_ID
		); 
		CALL sp_get_disposal_wste_lists_2(
			CUR_DISPOSER_ORDER_ID,
			VAR_WSTE_LIST 
		);
           
        CALL sp_retrieve_my_disposal_details_20220523(
			CUR_DISPOSER_ORDER_ID,
			CUR_STATE_CODE,
			CUR_TRANSACTION_STATE_CODE,
			CUR_EXISTING_TRANSACTION,
            VAR_DETAILS
        );
        SET VAR_EXISTING_TRANSACTION = CUR_EXISTING_TRANSACTION;
        SET VAR_STATE_CODE = IF(CUR_EXISTING_TRANSACTION = 0, CUR_STATE_CODE, CUR_TRANSACTION_STATE_CODE);
        
		CALL sp_req_policy_direction(
			'min_disposal_duration',
			VAR_MIN_DISPOSAL_DURATION
		);      
        
        IF VAR_EXISTING_TRANSACTION = 1 THEN
			CALL sp_set_display_time_for_transaction(
				CUR_TRANSACTION_ID,
				VAR_STATE_CODE,
				VAR_DISPLAY_DATE
			);
        ELSE
			CALL sp_set_display_time(
				CUR_DISPOSER_ORDER_ID,
				CUR_STATE_CATEGORY_ID,
				VAR_DISPLAY_DATE
			);
        END IF;
        
        CALL sp_get_order_bell_state(
			CUR_DISPOSER_ORDER_ID,
			VAR_CHECK_STATE
		);
        
		UPDATE RETRIEVE_MY_DISPOSAL_LISTS_WITH_JSON_20220523 
        SET 
			IMG_PATH 				= VAR_IMG_PATH, 
            WSTE_LIST 				= VAR_WSTE_LIST, 
            DISPLAY_DATE			= VAR_DISPLAY_DATE,
            CHECK_STATE				= VAR_CHECK_STATE,
            TRANSACTION_TYPE		= IF(VAR_EXISTING_TRANSACTION = 1, '기존거래', '입찰거래'),
            MIN_DISPOSAL_DURATION	= VAR_MIN_DISPOSAL_DURATION,
            DETAILS					= VAR_DETAILS
		WHERE DISPOSER_ORDER_ID 	= CUR_DISPOSER_ORDER_ID;		
        
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'DISPOSER_ORDER_ID'					, DISPOSER_ORDER_ID, 
            'DISPOSER_ORDER_CODE'				, DISPOSER_ORDER_CODE, 
            'DISPOSER_SITE_ID'					, DISPOSER_SITE_ID,       
            'DISPOSER_ID'					, DISPOSER_ID,             
            'DISPOSER_VISIT_START_AT'			, DISPOSER_VISIT_START_AT, 
            'DISPOSER_VISIT_END_AT'				, DISPOSER_VISIT_END_AT, 
            'DISPOSER_BIDDING_END_AT'			, DISPOSER_BIDDING_END_AT, 
            'DISPOSER_OPEN_AT'					, DISPOSER_OPEN_AT, 
            'DISPOSER_CLOSE_AT'					, DISPOSER_CLOSE_AT, 
            'DISPOSER_VISIT_EARLY_CLOSING'		, DISPOSER_VISIT_EARLY_CLOSING, 
            'DISPOSER_VISIT_EARLY_CLOSED_AT'	, DISPOSER_VISIT_EARLY_CLOSED_AT, 
            'DISPOSER_BIDDING_EARLY_CLOSING'	, DISPOSER_BIDDING_EARLY_CLOSING, 
            'DISPOSER_BIDDING_EARLY_CLOSED_AT'	, DISPOSER_BIDDING_EARLY_CLOSED_AT, 
            'DISPOSER_CREATED_AT'				, DISPOSER_CREATED_AT, 
            'DISPOSER_UPDATED_AT'				, DISPOSER_UPDATED_AT,             
            'STATE'								, STATE, 
            'STATE_CODE'						, STATE_CODE, 
            'STATE_CATEGORY_ID'					, STATE_CATEGORY_ID, 
            'STATE_CATEGORY'					, STATE_CATEGORY, 
            'PROSPECTIVE_VISITORS'				, PROSPECTIVE_VISITORS, 
            'BIDDERS'							, BIDDERS, 
            'DISPLAY_DATE'						, DISPLAY_DATE, 
            'MIN_DISPOSAL_DURATION'				, MIN_DISPOSAL_DURATION, 
            'WSTE_LIST'							, WSTE_LIST, 
            'CHECK_STATE'						, CHECK_STATE, 
            'TRANSACTION_TYPE'					, TRANSACTION_TYPE, 
            'DETAILS'							, DETAILS
		)
	) 
    INTO json_data 
    FROM RETRIEVE_MY_DISPOSAL_LISTS_WITH_JSON_20220523;
        
	SET rtn_val 				= 0;
	SET msg_txt 				= 'Success';
	DROP TABLE IF EXISTS RETRIEVE_MY_DISPOSAL_LISTS_WITH_JSON_20220523;
END