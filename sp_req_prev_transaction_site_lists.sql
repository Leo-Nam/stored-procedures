CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_prev_transaction_site_lists`(
	IN IN_USER_ID			BIGINT				/*입력값 : 사용자 등록번호(USERS.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_req_prev_transaction_site_lists
Input param 	: 3개
Job 			: 이전거래 이력이 있는 사이트를 반환한다.
Update 			: 2022.01.30
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;  
    DECLARE CUR_DISPOSER_ORDER_ID				BIGINT;
    DECLARE CUR_DISPOSER_ID						BIGINT;
    DECLARE CUR_DISPOSER_SITE_ID				BIGINT;
    DECLARE CUR_COLLECTOR_SITE_ID				BIGINT;
    DECLARE CUR_COLLECTOR_BIDDING_ID			BIGINT;
    DECLARE CUR_OPEN_AT							DATETIME;
    DECLARE CUR_CLOSE_AT						DATETIME;	
    DECLARE CUR_STATE_CODE						INT;
    DECLARE CUR_STATE							VARCHAR(20);
    
    DECLARE TEMP_CURSOR		 					CURSOR FOR 
	SELECT 
		A.DISPOSER_ORDER_ID, 
		A.DISPOSER_ID, 
		A.DISPOSER_SITE_ID, 
		A.COLLECTOR_SITE_ID, 
		A.COLLECTOR_BIDDING_ID, 
        A.DISPOSER_OPEN_AT, 
        A.DISPOSER_CLOSE_AT,
        A.STATE_CODE, 
        A.STATE
    FROM V_COLLECTOR_BIDDING_WITH_STATE A LEFT JOIN USERS B 
    ON IF(B.AFFILIATED_SITE = 0, A.DISPOSER_ID = B.ID, A.DISPOSER_SITE_ID = B.AFFILIATED_SITE)
	WHERE 
		(A.STATE_CODE = 211 OR A.STATE_CODE = 218 OR A.STATE_PID = 211 OR A.STATE_PID = 218 OR A.STATE_CATEGORY_ID = 5) AND 
		A.DISPOSER_SITE_ID IS NOT NULL AND 
        A.DISPOSER_SITE_ID = B.AFFILIATED_SITE AND
        B.ID = IN_USER_ID AND 
        B.ACTIVE = TRUE AND
        A.COLLECTOR_MAKE_DECISION = TRUE AND
        A.COLLECTOR_SELECTED = TRUE;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS CURRENT_STATE (
		DISPOSER_ORDER_ID				BIGINT,
		DISPOSER_ID						BIGINT,
		DISPOSER_SITE_ID				BIGINT,
		COLLECTOR_SITE_ID				BIGINT,
		COLLECTOR_BIDDING_ID			BIGINT,
		DISPOSER_OPEN_AT				DATETIME,
		DISPOSER_CLOSE_AT				DATETIME,
		STATE_CODE						INT,
		STATE							VARCHAR(20),
		COLLECTOR_INFO					JSON,
		TRANSACTION_INFO				JSON
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_DISPOSER_ORDER_ID,
			CUR_DISPOSER_ID,
			CUR_DISPOSER_SITE_ID,
			CUR_COLLECTOR_SITE_ID,
			CUR_COLLECTOR_BIDDING_ID,
			CUR_OPEN_AT,
			CUR_CLOSE_AT,
			CUR_STATE_CODE,
			CUR_STATE;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		CURRENT_STATE(
			DISPOSER_ORDER_ID, 
			DISPOSER_ID, 
			DISPOSER_SITE_ID, 
			COLLECTOR_SITE_ID, 
			COLLECTOR_BIDDING_ID, 
			DISPOSER_OPEN_AT, 
			DISPOSER_CLOSE_AT, 
			STATE_CODE, 
			STATE
		)
		VALUES(
			CUR_DISPOSER_ORDER_ID, 
			CUR_DISPOSER_ID, 
			CUR_DISPOSER_SITE_ID, 
			CUR_COLLECTOR_SITE_ID, 
			CUR_COLLECTOR_BIDDING_ID, 
			CUR_OPEN_AT, 
			CUR_CLOSE_AT, 
			CUR_STATE_CODE, 
			CUR_STATE
		);
        
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'SITE_ID'					, A.ID, 
            'SITE_NAME'					, A.SITE_NAME, 
            'ADDR'						, A.ADDR, 
            'B_CODE'					, B.B_CODE, 
            'SI_DO'						, B.SI_DO, 
            'SI_GUN_GU'					, B.SI_GUN_GU, 
            'EUP_MYEON_DONG'			, B.EUP_MYEON_DONG, 
            'DONG_RI'					, B.DONG_RI
		)) 
        INTO @COLLECTOR_INFO
        FROM COMP_SITE A LEFT JOIN KIKCD_B B ON A.KIKCD_B_CODE = B.B_CODE
        WHERE A.ID = CUR_COLLECTOR_SITE_ID;
        
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'ID'						, A.ID, 
			'WSTE_NM'					, B.NAME, 
            'QTY'						, A.WSTE_QUANTITY, 
            'UNIT'						, A.WSTE_UNIT, 
            'UNIT_PRICE'				, A.PRICE_UNIT, 
            'COLLECTOR_BIDDING_ID'		, A.COLLECTOR_BIDDING_ID, 
            'COLLECT_ASK_END_AT'		, A.COLLECT_ASK_END_AT, 
            'COLLECTING_TRUCK_ID'		, A.COLLECTING_TRUCK_ID, 
            'TRUCK_DRIVER_ID'			, A.TRUCK_DRIVER_ID, 
            'TRUCK_START_AT'			, A.TRUCK_START_AT, 
            'COLLECT_END_AT'			, A.COLLECT_END_AT, 
            'TRMT_METHOD_CODE'			, A.TRMT_METHOD_CODE, 
            'TRMT_METHOD_NM'			, C.NAME, 
            'QCC_IMG_PATH'				, A.QCC_IMG_PATH, 
            'CONTRACT_ID'				, A.CONTRACT_ID, 
            'CONFIRMER_ID'				, A.CONFIRMER_ID, 
            'DATE_OF_VISIT'				, A.DATE_OF_VISIT, 
            'VISIT_START_AT'			, A.VISIT_START_AT, 
            'VISIT_END_AT'				, A.VISIT_END_AT, 
            'CONFIRMED_AT'				, A.CONFIRMED_AT
		)) 
        INTO @TRANSACTION_INFO
        FROM WSTE_CLCT_TRMT_TRANSACTION A
        LEFT JOIN WSTE_CODE B ON A.WSTE_CODE = B.CODE
        LEFT JOIN WSTE_CODE C ON A.TRMT_METHOD_CODE = C.CODE
        WHERE A.COLLECTOR_BIDDING_ID = CUR_COLLECTOR_BIDDING_ID;
		
		UPDATE CURRENT_STATE 
        SET 
			COLLECTOR_INFO 			= @COLLECTOR_INFO, 
			TRANSACTION_INFO 		= @TRANSACTION_INFO
        WHERE COLLECTOR_SITE_ID 	= CUR_COLLECTOR_SITE_ID;
		/*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/
		
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
    
    IF vRowCount - 1 = 0 THEN
		SET @rtn_val 				= 29701;
		SET @msg_txt 				= 'No data found';
		SET @json_data 				= NULL;
    ELSE
		SET @rtn_val 				= 0;
		SET @msg_txt 				= 'Success';	
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'DISPOSER_ORDER_ID'		, DISPOSER_ORDER_ID, 
				'DISPOSER_ID'			, DISPOSER_ID,
				'DISPOSER_SITE_ID'		, DISPOSER_SITE_ID,
				'COLLECTOR_SITE_ID'		, COLLECTOR_SITE_ID,
				'COLLECTOR_BIDDING_ID'	, COLLECTOR_BIDDING_ID,
				'DISPOSER_OPEN_AT'		, DISPOSER_OPEN_AT,
				'DISPOSER_CLOSE_AT'		, DISPOSER_CLOSE_AT,
				'STATE_CODE'			, STATE_CODE,
				'STATE'					, STATE,
				'COLLECTOR_INFO'		, COLLECTOR_INFO,
				'TRANSACTION_INFO'		, TRANSACTION_INFO  
			)
		) 
		INTO @json_data 
		FROM CURRENT_STATE;
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);   
	DROP TABLE IF EXISTS CURRENT_STATE;
END