CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_my_disposal_lists_by_option_with_json`(
	IN IN_USER_ID							BIGINT,
	IN IN_STATE_CODE						INT,
	IN IN_USER_TYPE							VARCHAR(20),
    OUT rtn_val								INT,
    OUT msg_txt								VARCHAR(200),
    OUT json_data							JSON
)
BEGIN

/*
Procedure Name 	: sp_retrieve_my_disposal_lists_by_option_with_json
Input param 	: 3개
Output param 	: 3개
Job 			: 배출자의 현재 배출중인 작업의 상태별로 리스트 반환
Update 			: 2022.02.17
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 								INT DEFAULT 0;
    DECLARE endOfRow 								TINYINT DEFAULT FALSE;    
    DECLARE CUR_DISPOSER_ORDER_ID					BIGINT;
    DECLARE CUR_DISPOSER_ORDER_CODE					VARCHAR(10);
    DECLARE CUR_DISPOSER_SITE_ID					BIGINT;    
    DECLARE CUR_DISPOSER_VISIT_START_AT				DATETIME;
    DECLARE CUR_DISPOSER_VISIT_END_AT				DATETIME;
    DECLARE CUR_DISPOSER_BIDDING_END_AT				DATETIME;
    DECLARE CUR_DISPOSER_OPEN_AT					DATETIME;
    DECLARE CUR_DISPOSER_CLOSE_AT					DATETIME;
    DECLARE CUR_DISPOSER_SERVICE_INSTRUCTION_ID		BIGINT;
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
    DECLARE CUR_NOTE								VARCHAR(255);
    DECLARE TEMP_CURSOR		 						CURSOR FOR 
	SELECT 
		A.ID, 
        A.ORDER_CODE, 
        A.SITE_ID,        
        A.VISIT_START_AT,
        A.VISIT_END_AT,
        A.BIDDING_END_AT,
        A.OPEN_AT,
        A.CLOSE_AT,
        A.SERVICE_INSTRUCTION_ID,
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
        A.NOTE
    FROM SITE_WSTE_DISPOSAL_ORDER A 
    LEFT JOIN V_ORDER_STATE_NAME B ON A.ID = B.DISPOSER_ORDER_ID
	WHERE 
		B.STATE_CODE = IN_STATE_CODE AND 
        A.IS_DELETED = FALSE AND
        IF (IN_USER_TYPE = 'Person',
			(A.DISPOSER_ID = IN_USER_ID),            
			(A.SITE_ID IS NOT NULL AND A.SITE_ID IN (SELECT AFFILIATED_SITE FROM USERS WHERE ID = IN_USER_ID AND ACTIVE = TRUE)));
            
            
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS MY_DISPOSAL_LISTS_BY_OPTION_TEMP (
		DISPOSER_ORDER_ID					BIGINT,
		DISPOSER_ORDER_CODE					VARCHAR(10),
		DISPOSER_SITE_ID					BIGINT,    
		DISPOSER_VISIT_START_AT				DATETIME,
		DISPOSER_VISIT_END_AT				DATETIME,
		DISPOSER_BIDDING_END_AT				DATETIME,
		DISPOSER_OPEN_AT					DATETIME,
		DISPOSER_CLOSE_AT					DATETIME,
		DISPOSER_SERVICE_INSTRUCTION_ID		BIGINT,
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
		NOTE								VARCHAR(255),
        DISPLAY_DATE						DATETIME,
        MIN_DISPOSAL_DURATION				INT,
		IMG_PATH							JSON,
		WSTE_LIST							JSON,
		BIDDING_LIST						JSON
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_DISPOSER_ORDER_ID,
			CUR_DISPOSER_ORDER_CODE,
			CUR_DISPOSER_SITE_ID,    
			CUR_DISPOSER_VISIT_START_AT,
			CUR_DISPOSER_VISIT_END_AT,
			CUR_DISPOSER_BIDDING_END_AT,
			CUR_DISPOSER_OPEN_AT,
			CUR_DISPOSER_CLOSE_AT,
			CUR_DISPOSER_SERVICE_INSTRUCTION_ID,
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
			CUR_NOTE;  
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		MY_DISPOSAL_LISTS_BY_OPTION_TEMP(
			DISPOSER_ORDER_ID, 
			DISPOSER_ORDER_CODE, 
			DISPOSER_SITE_ID,     
			DISPOSER_VISIT_START_AT,
			DISPOSER_VISIT_END_AT,
			DISPOSER_BIDDING_END_AT,
			DISPOSER_OPEN_AT,
			DISPOSER_CLOSE_AT,
			DISPOSER_SERVICE_INSTRUCTION_ID,
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
			NOTE
		)
		VALUES(
			CUR_DISPOSER_ORDER_ID, 
			CUR_DISPOSER_ORDER_CODE, 
			CUR_DISPOSER_SITE_ID,     
			CUR_DISPOSER_VISIT_START_AT,
			CUR_DISPOSER_VISIT_END_AT,
			CUR_DISPOSER_BIDDING_END_AT,
			CUR_DISPOSER_OPEN_AT,
			CUR_DISPOSER_CLOSE_AT,
			CUR_DISPOSER_SERVICE_INSTRUCTION_ID,
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
			CUR_NOTE
		);
        
        CALL sp_get_disposal_wste_lists_2(
			CUR_DISPOSER_ORDER_ID,
            @WSTE_LIST
        );
		
        CALL sp_get_disposal_img_lists_2(
			CUR_DISPOSER_ORDER_ID,
            '입찰',
            @IMG_PATH
        );
        
        CALL sp_get_bidding_lists(
			CUR_DISPOSER_ORDER_ID,
            CUR_STATE_CATEGORY_ID,
            @BIDDING_LIST
        );
		
        CALL sp_set_display_time(
			CUR_DISPOSER_ORDER_ID,
			CUR_STATE_CATEGORY_ID,
            @DISPLAY_DATE
        );
        
		CALL sp_req_policy_direction(
		/*수거자가 배출자의 최종입찰선정에 응답을 할 수 있는 최대의 시간으로서 배출자의 최종낙찰자선정일로부터의 기간을 반환받는다(단위:시간)*/
			'min_disposal_duration',
			@MIN_DISPOSAL_DURATION
		);        
		
		UPDATE MY_DISPOSAL_LISTS_BY_OPTION_TEMP 
        SET 
			IMG_PATH 				= @IMG_PATH, 
            WSTE_LIST 				= @WSTE_LIST, 
            BIDDING_LIST 			= @BIDDING_LIST,
            DISPLAY_DATE			= @DISPLAY_DATE,
            MIN_DISPOSAL_DURATION	= @MIN_DISPOSAL_DURATION
        WHERE DISPOSER_ORDER_ID 	= CUR_DISPOSER_ORDER_ID;
		/*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/
        
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'DISPOSER_ORDER_ID'					, DISPOSER_ORDER_ID, 
            'DISPOSER_ORDER_CODE'				, DISPOSER_ORDER_CODE, 
            'DISPOSER_SITE_ID'					, DISPOSER_SITE_ID,             
            'DISPOSER_VISIT_START_AT'			, DISPOSER_VISIT_START_AT, 
            'DISPOSER_VISIT_END_AT'				, DISPOSER_VISIT_END_AT, 
            'DISPOSER_BIDDING_END_AT'			, DISPOSER_BIDDING_END_AT, 
            'DISPOSER_OPEN_AT'					, DISPOSER_OPEN_AT, 
            'DISPOSER_CLOSE_AT'					, DISPOSER_CLOSE_AT, 
            'DISPOSER_SERVICE_INSTRUCTION_ID'	, DISPOSER_SERVICE_INSTRUCTION_ID, 
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
            'NOTE'								, NOTE, 
            'DISPLAY_DATE'						, DISPLAY_DATE, 
            'MIN_DISPOSAL_DURATION'				, MIN_DISPOSAL_DURATION, 
            'IMG_PATH'							, IMG_PATH, 
            'WSTE_LIST'							, WSTE_LIST, 
            'BIDDING_LIST'						, BIDDING_LIST
		)
	) 
    INTO json_data 
    FROM MY_DISPOSAL_LISTS_BY_OPTION_TEMP;
    
    IF vRowCount = 1 THEN
		SET json_data 				= NULL;
		SET rtn_val 				= 30701;
		SET msg_txt 				= 'No data found';
    ELSE
		SET rtn_val 				= 0;
		SET msg_txt 				= 'Success';
    END IF;
	DROP TABLE IF EXISTS MY_DISPOSAL_LISTS_BY_OPTION_TEMP;
END