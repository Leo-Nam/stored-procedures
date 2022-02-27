CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_my_disposal_lists_with_json`(
	IN IN_USER_ID							BIGINT,
    IN IN_USER_TYPE							VARCHAR(20),
    OUT rtn_val								INT,
    OUT msg_txt								VARCHAR(200),
    OUT json_data							JSON
)
BEGIN

/*
Procedure Name 	: sp_retrieve_my_disposal_lists_with_json
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
    
    DECLARE CUR_DATE 								DATETIME;	
    DECLARE CUR_STATE								VARCHAR(20);
    DECLARE CUR_STATE_CODE							INT;
    DECLARE TEMP_CURSOR		 						CURSOR FOR 
	SELECT 
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
        
		IF (STATE = '삭제', DISPOSER_ORDER_DELETED_AT,
			IF (STATE = '기존거래', DISPOSER_UPDATED_AT,
				IF (STATE = '방문대기중', IF (DISPOSER_VISIT_START_AT IS NOT NULL, DISPOSER_VISIT_START_AT, DISPOSER_VISIT_END_AT), 
					IF (STATE = '방문중', DISPOSER_VISIT_END_AT, 
						IF (STATE = '승인중', DISPOSER_BIDDING_END_AT, 
							IF (STATE = '입찰거절', DISPOSER_UPDATED_AT, 
								IF (STATE = '승인거절', DISPOSER_UPDATED_AT, 
									IF (STATE = '선정중', DISPOSER_BIDDING_END_AT, 
										IF (STATE = '거래종료', DISPOSER_UPDATED_AT, 
											IF (STATE = '입찰중', DISPOSER_BIDDING_END_AT, 
												DISPOSER_CREATED_AT
											)
										)
									)
								)
							)
						)
					)
				)
			)
		), 
        STATE, 
        STATE_CODE
    FROM V_SITE_WSTE_DISPOSAL_ORDER_WITH_STATE
	WHERE 
		STATE IS NOT NULL AND 
        DISPOSER_ORDER_DELETED = FALSE AND
        IF (IN_USER_TYPE = 'Person',
			(DISPOSER_ID = IN_USER_ID),            
			(DISPOSER_SITE_ID IS NOT NULL AND DISPOSER_SITE_ID IN (SELECT AFFILIATED_SITE FROM USERS WHERE ID = IN_USER_ID AND ACTIVE = TRUE)));
            
            
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS CURRENT_STATE (
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
    
		DISPLAY_DATE						DATETIME,
		STATE								VARCHAR(20),
		STATE_CODE							INT,
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
    
			CUR_DATE,
			CUR_STATE,
			CUR_STATE_CODE;   
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		CURRENT_STATE(
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
        
			DISPLAY_DATE, 
			STATE, 
			STATE_CODE
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
            
			CUR_DATE, 
			CUR_STATE, 
			CUR_STATE_CODE
		);
        
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'ID'				, WSTE_REG_ID, 
				'WSTE_NM'			, WSTE_CLASS_NM, 
                'APR'				, WSTE_APPEARANCE_NM, 
                'QTY'				, WSTE_QUANTITY, 
                'UNIT'				, WSTE_UNIT,
                'UPDATED_AT'		, WSTE_DISCHARGED_UPDATED_AT
			)
		) 
        INTO @WSTE_LIST 
        FROM V_WSTE_DISCHARGED_FROM_SITE 
        WHERE DISPOSAL_ORDER_ID = CUR_DISPOSER_ORDER_ID;
		
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'ID'				, ID, 
                'PATH'				, IMG_PATH
			)
		) 
        INTO @IMG_PATH 
        FROM WSTE_REGISTRATION_PHOTO 
        WHERE 
			DISPOSAL_ORDER_ID 		= CUR_DISPOSER_ORDER_ID AND 
            CLASS_CODE 				= '입찰';
		/*DISPOSAL_ORDER_ID에 해당하는 이미지에 대한 저장경로를 JSON 형태로 받아온다.*/
		
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'COLLECTOR_BIDDING_ID'			, COLLECTOR_BIDDING_ID, 
				'COLLECTOR_SITE_ID'				, COLLECTOR_SITE_ID, 
                'COLLECTOR_SI_DO'				, COLLECTOR_SI_DO, 
                'COLLECTOR_SI_GUN_GU'			, COLLECTOR_SI_GUN_GU, 
                'COLLECTOR_STATE'				, STATE, 
                'COLLECTOR_STATE_CODE'			, STATE_CODE, 
                'COLLECTOR_LAT'					, COLLECTOR_LAT, 
                'COLLECTOR_LNG'					, COLLECTOR_LNG, 
                'COLLECTOR_SITE_NAME'			, COLLECTOR_SITE_NAME, 
                'COLLECTOR_TRMT_BIZ_CODE'		, COLLECTOR_TRMT_BIZ_CODE, 
                'COLLECTOR_TRMT_BIZ_NM'			, TRMT_BIZ_NM, 
                'COLLECTOR_BID_AMOUNT'			, COLLECTOR_BID_AMOUNT, 
                'COLLECTOR_GREENHOUSE_GAS'		, COLLECTOR_GREENHOUSE_GAS, 
                'COLLECTOR_WINNER'				, COLLECTOR_WINNER, 
                'COLLECTOR_ACTIVE'				, COLLECTOR_ACTIVE, 
                'COLLECTOR_CANCEL_VISIT'		, COLLECTOR_CANCEL_VISIT, 
                'COLLECTOR_CANCEL_BIDDING'		, COLLECTOR_CANCEL_BIDDING, 
                'COLLECTOR_DATE_OF_VISIT'		, COLLECTOR_DATE_OF_VISIT, 
                'COLLECTOR_DATE_OF_BIDDING'		, COLLECTOR_DATE_OF_BIDDING, 
                'COLLECTOR_SELECTED'			, COLLECTOR_SELECTED, 
                'COLLECTOR_SELECTED_AT'			, COLLECTOR_SELECTED_AT, 
                'COLLECTOR_REJECT_DECISION'		, COLLECTOR_REJECT_DECISION, 
                'COLLECTOR_REJECTED_AT'			, COLLECTOR_REJECTED_AT, 
                'DISPOSER_RESPONSE_VISIT'		, DISPOSER_RESPONSE_VISIT, 
                'DISPOSER_RESPONSE_VISIT_AT'	, DISPOSER_RESPONSE_VISIT_AT,
                'DISPOSER_REJECT_BIDDING'		, DISPOSER_REJECT_BIDDING, 
                'DISPOSER_REJECT_BIDDING_AT'	, DISPOSER_REJECT_BIDDING_AT
			)
		) 
        INTO @BIDDING_LIST 
        FROM V_COLLECTOR_BIDDING_WITH_STATE 
        WHERE 
			DISPOSER_ORDER_ID 		= CUR_DISPOSER_ORDER_ID AND 
            COLLECTOR_CANCEL_VISIT IS NOT TRUE;
		
		UPDATE CURRENT_STATE 
        SET 
			IMG_PATH 				= @IMG_PATH, 
            WSTE_LIST 				= @WSTE_LIST , 
            BIDDING_LIST 			= @BIDDING_LIST 
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
            
            'DISPLAY_DATE'						, DISPLAY_DATE, 
            'STATE'								, STATE, 
            'STATE_CODE'						, STATE_CODE, 
            'IMG_PATH'							, IMG_PATH, 
            'WSTE_LIST'							, WSTE_LIST, 
            'BIDDING_LIST'						, BIDDING_LIST
		)
	) 
    INTO json_data 
    FROM CURRENT_STATE;
    
    IF vRowCount = 0 THEN
		SET json_data 				= NULL;
		SET rtn_val 				= 30601;
		SET msg_txt 				= 'No data found';
    ELSE
		SET rtn_val 				= 0;
		SET msg_txt 				= 'Success';
    END IF;
	DROP TABLE IF EXISTS CURRENT_STATE;
END