CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_disposer_order_list`(
	IN IN_SITE_ID						BIGINT,
	IN IN_DISPOSER_ID					BIGINT,
    OUT OUT_ORDER_LIST					JSON
)
BEGIN

    DECLARE vRowCount 								INT DEFAULT 0;
    DECLARE endOfRow 								TINYINT DEFAULT FALSE;   
	DECLARE CUR_ORDER_ID							BIGINT;
	DECLARE CUR_DISPOSER_ID							BIGINT;
	DECLARE CUR_COLLECTOR_ID						BIGINT;
	DECLARE CUR_DISPOSER_TYPE						VARCHAR(255);
	DECLARE CUR_SITE_ID								BIGINT;
	DECLARE CUR_ACTIVE								TINYINT;
	DECLARE CUR_ORDER_CODE							VARCHAR(10);
	DECLARE CUR_MANAGER_ID							BIGINT;
	DECLARE CUR_SUCCESS_BIDDER						BIGINT;
	DECLARE CUR_FIRST_PLACE							BIGINT;
	DECLARE CUR_SECOND_PLACE						BIGINT;
    DECLARE CUR_PROSPECTIVE_VISITORS				INT;
    DECLARE CUR_BIDDERS								INT;
    DECLARE CUR_PROSPECTIVE_BIDDERS					INT;
    DECLARE CUR_CREATED_AT							DATETIME;
    DECLARE CUR_UPDATED_AT							DATETIME;
    DECLARE CUR_VISIT_START_AT						DATETIME;
    DECLARE CUR_VISIT_END_AT						DATETIME;
    DECLARE CUR_BIDDING_END_AT						DATETIME;
    DECLARE CUR_OPEN_AT								DATETIME;
    DECLARE CUR_CLOSE_AT							DATETIME;
    DECLARE CUR_KIKCD_B_CODE						VARCHAR(10);
	DECLARE CUR_ADDR								VARCHAR(255);
	DECLARE CUR_NOTE								VARCHAR(255);
	DECLARE CUR_LAT									DECIMAL(12,9);
	DECLARE CUR_LNG									DECIMAL(12,9);
	DECLARE CUR_VISIT_EARLY_CLOSING					TINYINT;
	DECLARE CUR_BIDDING_EARLY_CLOSING				TINYINT;
	DECLARE CUR_IS_DELETED							TINYINT;
	DECLARE CUR_SELECTED							BIGINT;
	DECLARE CUR_SELECTED_AT							DATETIME;
	DECLARE CUR_COLLECTOR_SELECTION_CONFIRMED		TINYINT;
	DECLARE CUR_COLLECTOR_SELECTION_CONFIRMED_AT	DATETIME;
	DECLARE CUR_VISIT_EARLY_CLOSED_AT				DATETIME;
	DECLARE CUR_BIDDING_EARLY_CLOSED_AT				DATETIME;
	DECLARE CUR_DELETED_AT							DATETIME;
	DECLARE CUR_MAX_SELECT_AT						DATETIME;
	DECLARE CUR_SELECTED2							TINYINT;
	DECLARE CUR_SELECTED2_AT						DATETIME;
	DECLARE CUR_COLLECTOR_SELECTION_CONFIRMED2		TINYINT;
	DECLARE CUR_COLLECTOR_SELECTION_CONFIRMED2_AT	DATETIME;
	DECLARE CUR_MAX_SELECT2_AT						DATETIME;
	DECLARE CUR_COLLECTOR_BIDDING_ID				BIGINT;
	DECLARE CUR_COLLECTOR_MAX_DECISION_AT			DATETIME;
	DECLARE CUR_COLLECTOR_MAX_DECISION2_AT			DATETIME;
	DECLARE CUR_MAX_DECISION_AT						DATETIME;
	DECLARE CUR_MAX_DECISION2_AT					DATETIME;
	DECLARE CUR_TRANSACTION_ID						BIGINT;
	DECLARE CUR_CHECK_STATE							TINYINT;
    DECLARE TEMP_CURSOR		 						CURSOR FOR 
	SELECT 
		ID,
		DISPOSER_ID,
		COLLECTOR_ID,
		DISPOSER_TYPE,
		SITE_ID,
		ACTIVE,
		ORDER_CODE,
		MANAGER_ID,
		SUCCESS_BIDDER,
		FIRST_PLACE,
		SECOND_PLACE,
		PROSPECTIVE_VISITORS,
		BIDDERS,
		PROSPECTIVE_BIDDERS,
		CREATED_AT,
		UPDATED_AT,
		VISIT_START_AT,
		VISIT_END_AT,
		BIDDING_END_AT,
		OPEN_AT,
		CLOSE_AT,
		KIKCD_B_CODE,
		ADDR,
		NOTE,
		LAT,
		LNG,
		VISIT_EARLY_CLOSING,
		BIDDING_EARLY_CLOSING,
		IS_DELETED,
		SELECTED,
		SELECTED_AT,
		COLLECTOR_SELECTION_CONFIRMED,
		COLLECTOR_SELECTION_CONFIRMED_AT,
		VISIT_EARLY_CLOSED_AT,
		BIDDING_EARLY_CLOSED_AT,
		DELETED_AT,
		MAX_SELECT_AT,
		SELECTED2,
		SELECTED2_AT,
		COLLECTOR_SELECTION_CONFIRMED2,
		COLLECTOR_SELECTION_CONFIRMED2_AT,
		MAX_SELECT2_AT,
		COLLECTOR_BIDDING_ID,
		COLLECTOR_MAX_DECISION_AT,
		COLLECTOR_MAX_DECISION2_AT,
		MAX_DECISION_AT,
		MAX_DECISION2_AT,
		TRANSACTION_ID,
		CHECK_STATE
	FROM SITE_WSTE_DISPOSAL_ORDER A
    WHERE IF(IN_SITE_ID = 0, DISPOSER_ID = IN_DISPOSER_ID, SITE_ID = IN_SITE_ID); 
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
    SET OUT_ORDER_LIST = NULL;
	CREATE TEMPORARY TABLE IF NOT EXISTS GET_DISPOSER_ORDER_LIST_TEMP (
		ORDER_ID							BIGINT,
		DISPOSER_ID							BIGINT,
		COLLECTOR_ID						BIGINT,
		DISPOSER_TYPE						VARCHAR(255),
		SITE_ID								BIGINT,
		ACTIVE								TINYINT,
		ORDER_CODE							VARCHAR(10),
		MANAGER_ID							BIGINT,
		SUCCESS_BIDDER						BIGINT,
		FIRST_PLACE							BIGINT,
		SECOND_PLACE						BIGINT,
        PROSPECTIVE_VISITORS				INT,
		BIDDERS								INT,
		PROSPECTIVE_BIDDERS					INT,
        CREATED_AT							DATETIME,
        UPDATED_AT							DATETIME,
        VISIT_START_AT						DATETIME,
        VISIT_END_AT						DATETIME,
        BIDDING_END_AT						DATETIME,
        OPEN_AT								DATETIME,
        CLOSE_AT							DATETIME,
        KIKCD_B_CODE						VARCHAR(10),
		ADDR								VARCHAR(255),
		NOTE								VARCHAR(255),
		LAT									DECIMAL(12,9),
		LNG									DECIMAL(12,9),
		VISIT_EARLY_CLOSING					TINYINT,
		BIDDING_EARLY_CLOSING				TINYINT,
		IS_DELETED							TINYINT,
		SELECTED							BIGINT,
		SELECTED_AT							DATETIME,
		COLLECTOR_SELECTION_CONFIRMED		TINYINT,
		COLLECTOR_SELECTION_CONFIRMED_AT	DATETIME,
		VISIT_EARLY_CLOSED_AT				DATETIME,
		BIDDING_EARLY_CLOSED_AT				DATETIME,
		DELETED_AT							DATETIME,
		MAX_SELECT_AT						DATETIME,
		SELECTED2							TINYINT,
		SELECTED2_AT						DATETIME,
		COLLECTOR_SELECTION_CONFIRMED2		TINYINT,
		COLLECTOR_SELECTION_CONFIRMED2_AT	DATETIME,
		MAX_SELECT2_AT						DATETIME,
		COLLECTOR_BIDDING_ID				BIGINT,
		COLLECTOR_MAX_DECISION_AT			DATETIME,
		COLLECTOR_MAX_DECISION2_AT			DATETIME,
		MAX_DECISION_AT						DATETIME,
		MAX_DECISION2_AT					DATETIME,
		TRANSACTION_ID						BIGINT,
		CHECK_STATE							TINYINT,
        SITE_NAME							VARCHAR(255)
	);  
    
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		
		FETCH TEMP_CURSOR 
		INTO  
			CUR_ORDER_ID,
			CUR_DISPOSER_ID,
			CUR_COLLECTOR_ID,
			CUR_DISPOSER_TYPE,
			CUR_SITE_ID,
			CUR_ACTIVE,
			CUR_ORDER_CODE,
			CUR_MANAGER_ID,
			CUR_SUCCESS_BIDDER,
			CUR_FIRST_PLACE,
			CUR_SECOND_PLACE,
			CUR_PROSPECTIVE_VISITORS,
			CUR_BIDDERS,
			CUR_PROSPECTIVE_BIDDERS,
			CUR_CREATED_AT,
			CUR_UPDATED_AT,
			CUR_VISIT_START_AT,
			CUR_VISIT_END_AT,
			CUR_BIDDING_END_AT,
			CUR_OPEN_AT,
			CUR_CLOSE_AT,
			CUR_KIKCD_B_CODE,
			CUR_ADDR,
			CUR_NOTE,
			CUR_LAT,
			CUR_LNG,
			CUR_VISIT_EARLY_CLOSING,
			CUR_BIDDING_EARLY_CLOSING,
			CUR_IS_DELETED,
			CUR_SELECTED,
			CUR_SELECTED_AT,
			CUR_COLLECTOR_SELECTION_CONFIRMED,
			CUR_COLLECTOR_SELECTION_CONFIRMED_AT,
			CUR_VISIT_EARLY_CLOSED_AT,
			CUR_BIDDING_EARLY_CLOSED_AT,
			CUR_DELETED_AT,
			CUR_MAX_SELECT_AT,
			CUR_SELECTED2,
			CUR_SELECTED2_AT,
			CUR_COLLECTOR_SELECTION_CONFIRMED2,
			CUR_COLLECTOR_SELECTION_CONFIRMED2_AT,
			CUR_MAX_SELECT2_AT,
			CUR_COLLECTOR_BIDDING_ID,
			CUR_COLLECTOR_MAX_DECISION_AT,
			CUR_COLLECTOR_MAX_DECISION2_AT,
			CUR_MAX_DECISION_AT,
			CUR_MAX_DECISION2_AT,
			CUR_TRANSACTION_ID,
			CUR_CHECK_STATE;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		GET_DISPOSER_ORDER_LIST_TEMP(
			ORDER_ID,
			DISPOSER_ID,
			COLLECTOR_ID,
			DISPOSER_TYPE,
			SITE_ID,
			ACTIVE,
			ORDER_CODE,
			MANAGER_ID,
			SUCCESS_BIDDER,
			FIRST_PLACE,
			SECOND_PLACE,
			PROSPECTIVE_VISITORS,
			BIDDERS,
			PROSPECTIVE_BIDDERS,
			CREATED_AT,
			UPDATED_AT,
			VISIT_START_AT,
			VISIT_END_AT,
			BIDDING_END_AT,
			OPEN_AT,
			CLOSE_AT,
			KIKCD_B_CODE,
			ADDR,
			NOTE,
			LAT,
			LNG,
			VISIT_EARLY_CLOSING,
			BIDDING_EARLY_CLOSING,
			IS_DELETED,
			SELECTED,
			SELECTED_AT,
			COLLECTOR_SELECTION_CONFIRMED,
			COLLECTOR_SELECTION_CONFIRMED_AT,
			VISIT_EARLY_CLOSED_AT,
			BIDDING_EARLY_CLOSED_AT,
			DELETED_AT,
			MAX_SELECT_AT,
			SELECTED2,
			SELECTED2_AT,
			COLLECTOR_SELECTION_CONFIRMED2,
			COLLECTOR_SELECTION_CONFIRMED2_AT,
			MAX_SELECT2_AT,
			COLLECTOR_BIDDING_ID,
			COLLECTOR_MAX_DECISION_AT,
			COLLECTOR_MAX_DECISION2_AT,
			MAX_DECISION_AT,
			MAX_DECISION2_AT,
			TRANSACTION_ID,
			CHECK_STATE
		)
		VALUES(
			CUR_ORDER_ID,
			CUR_DISPOSER_ID,
			CUR_COLLECTOR_ID,
			CUR_DISPOSER_TYPE,
			CUR_SITE_ID,
			CUR_ACTIVE,
			CUR_ORDER_CODE,
			CUR_MANAGER_ID,
			CUR_SUCCESS_BIDDER,
			CUR_FIRST_PLACE,
			CUR_SECOND_PLACE,
			CUR_PROSPECTIVE_VISITORS,
			CUR_BIDDERS,
			CUR_PROSPECTIVE_BIDDERS,
			CUR_CREATED_AT,
			CUR_UPDATED_AT,
			CUR_VISIT_START_AT,
			CUR_VISIT_END_AT,
			CUR_BIDDING_END_AT,
			CUR_OPEN_AT,
			CUR_CLOSE_AT,
			CUR_KIKCD_B_CODE,
			CUR_ADDR,
			CUR_NOTE,
			CUR_LAT,
			CUR_LNG,
			CUR_VISIT_EARLY_CLOSING,
			CUR_BIDDING_EARLY_CLOSING,
			CUR_IS_DELETED,
			CUR_SELECTED,
			CUR_SELECTED_AT,
			CUR_COLLECTOR_SELECTION_CONFIRMED,
			CUR_COLLECTOR_SELECTION_CONFIRMED_AT,
			CUR_VISIT_EARLY_CLOSED_AT,
			CUR_BIDDING_EARLY_CLOSED_AT,
			CUR_DELETED_AT,
			CUR_MAX_SELECT_AT,
			CUR_SELECTED2,
			CUR_SELECTED2_AT,
			CUR_COLLECTOR_SELECTION_CONFIRMED2,
			CUR_COLLECTOR_SELECTION_CONFIRMED2_AT,
			CUR_MAX_SELECT2_AT,
			CUR_COLLECTOR_BIDDING_ID,
			CUR_COLLECTOR_MAX_DECISION_AT,
			CUR_COLLECTOR_MAX_DECISION2_AT,
			CUR_MAX_DECISION_AT,
			CUR_MAX_DECISION2_AT,
			CUR_TRANSACTION_ID,
			CUR_CHECK_STATE
		);
        
        IF IN_SITE_ID = 0 THEN
			SELECT USER_NAME INTO @SITE_NAME
            FROM USERS
            WHERE ID = IN_DISPOSER_ID;
        ELSE
			SELECT SITE_NAME INTO @SITE_NAME
            FROM COMP_SITE
            WHERE ID = IN_SITE_ID;
        END IF;
        
        UPDATE GET_DISPOSER_ORDER_LIST_TEMP
        SET SITE_NAME = @SITE_NAME
        WHERE ORDER_ID = CUR_ORDER_ID;
        
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'ORDER_ID'								, ORDER_ID,
		'DISPOSER_ID'							, DISPOSER_ID,
		'COLLECTOR_ID'							, COLLECTOR_ID,
		'DISPOSER_TYPE'							, DISPOSER_TYPE,
		'SITE_ID'								, SITE_ID,
		'ACTIVE'								, ACTIVE,
		'ORDER_CODE'							, ORDER_CODE,
		'MANAGER_ID'							, MANAGER_ID,
		'SUCCESS_BIDDER'						, SUCCESS_BIDDER,
		'FIRST_PLACE'							, FIRST_PLACE,
		'SECOND_PLACE'							, SECOND_PLACE,
		'PROSPECTIVE_VISITORS'					, PROSPECTIVE_VISITORS,
		'BIDDERS'								, BIDDERS,
		'PROSPECTIVE_BIDDERS'					, PROSPECTIVE_BIDDERS,
		'CREATED_AT'							, CREATED_AT,
		'UPDATED_AT'							, UPDATED_AT,
		'VISIT_START_AT'						, VISIT_START_AT,
		'VISIT_END_AT'							, VISIT_END_AT,
		'BIDDING_END_AT'						, BIDDING_END_AT,
		'OPEN_AT'								, OPEN_AT,
		'CLOSE_AT'								, CLOSE_AT,
		'KIKCD_B_CODE'							, KIKCD_B_CODE,
		'ADDR'									, ADDR,
		'NOTE'									, NOTE,
		'LAT'									, LAT,
		'LNG'									, LNG,
		'VISIT_EARLY_CLOSING'					, VISIT_EARLY_CLOSING,
		'BIDDING_EARLY_CLOSING'					, BIDDING_EARLY_CLOSING,
		'IS_DELETED'							, IS_DELETED,
		'SELECTED'								, SELECTED,
		'SELECTED_AT'							, SELECTED_AT,
		'COLLECTOR_SELECTION_CONFIRMED'			, COLLECTOR_SELECTION_CONFIRMED,
		'COLLECTOR_SELECTION_CONFIRMED_AT'		, COLLECTOR_SELECTION_CONFIRMED_AT,
		'VISIT_EARLY_CLOSED_AT'					, VISIT_EARLY_CLOSED_AT,
		'BIDDING_EARLY_CLOSED_AT'				, BIDDING_EARLY_CLOSED_AT,
		'DELETED_AT'							, DELETED_AT,
		'MAX_SELECT_AT'							, MAX_SELECT_AT,
		'SELECTED2'								, SELECTED2,
		'SELECTED2_AT'							, SELECTED2_AT,
		'COLLECTOR_SELECTION_CONFIRMED2'		, COLLECTOR_SELECTION_CONFIRMED2,
		'COLLECTOR_SELECTION_CONFIRMED2_AT'		, COLLECTOR_SELECTION_CONFIRMED2_AT,
		'MAX_SELECT2_AT'						, MAX_SELECT2_AT,
		'COLLECTOR_BIDDING_ID'					, COLLECTOR_BIDDING_ID,
		'COLLECTOR_MAX_DECISION_AT'				, COLLECTOR_MAX_DECISION_AT,
		'COLLECTOR_MAX_DECISION2_AT'			, COLLECTOR_MAX_DECISION2_AT,
		'MAX_DECISION_AT'						, MAX_DECISION_AT,
		'MAX_DECISION2_AT'						, MAX_DECISION2_AT,
		'TRANSACTION_ID'						, TRANSACTION_ID,
		'CHECK_STATE'							, CHECK_STATE,
		'SITE_NAME'								, SITE_NAME
	)) 
    INTO OUT_ORDER_LIST FROM GET_DISPOSER_ORDER_LIST_TEMP;
    
	DROP TABLE IF EXISTS GET_DISPOSER_ORDER_LIST_TEMP;

END