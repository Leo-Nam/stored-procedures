CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_current_state_by_option`(
	IN IN_USER_ID							BIGINT,
	IN IN_STATE_CODE						INT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_current_state
Input param 	: 2개
Job 			: 전체 이외의 개별 상태에서의 리스트 반환
Update 			: 2022.01.25
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_COLLECTOR_SITE_ID				BIGINT; 
    DECLARE CUR_COLLECTOR_BIDDING_ID			BIGINT;
    DECLARE CUR_DISPOSER_ORDER_ID				BIGINT;
    DECLARE CUR_DISPOSER_ORDER_CODE				VARCHAR(10);
    DECLARE CUR_STATE							VARCHAR(20);
    DECLARE CUR_STATE_CODE						INT;
    DECLARE CUR_STATE_CATEGORY					VARCHAR(20);
    DECLARE CUR_STATE_CATEGORY_ID				INT;
    DECLARE CUR_DISPOSER_NOTE					VARCHAR(255);
    DECLARE CUR_DISPOSER_CLOSE_AT				DATETIME;
    DECLARE CUR_DISPOSER_VISTI_START_AT			DATETIME;
    DECLARE CUR_DISPOSER_VISTI_END_AT			DATETIME;
    DECLARE CUR_DISPOSER_BIDDING_END_AT			DATETIME;
    DECLARE CUR_DISPOSER_B_CODE					VARCHAR(10);
    DECLARE CUR_DISPOSER_SI_DO					VARCHAR(20);
    DECLARE CUR_DISPOSER_SI_GUN_GU				VARCHAR(20);
    DECLARE CUR_DISPOSER_EUP_MYEON_DONG			VARCHAR(20);
    DECLARE CUR_DISPOSER_DONG_RI				VARCHAR(20);
    DECLARE CUR_DISPOSER_ADDR					VARCHAR(255);
    DECLARE CUR_DISPOSER_LAT					DECIMAL(12,9);
    DECLARE CUR_DISPOSER_LNG					DECIMAL(12,9);
    DECLARE TEMP_CURSOR		 					CURSOR FOR 
	SELECT 
		COLLECTOR_SITE_ID, 
        COLLECTOR_BIDDING_ID, 
        DISPOSER_ORDER_ID, 
        DISPOSER_ORDER_CODE, 
        STATE, 
        STATE_CODE, 
        STATE_CATEGORY, 
        STATE_CATEGORY_ID, 
        DISPOSER_NOTE, 
        DISPOSER_CLOSE_AT,
        DISPOSER_KIKCD_B_CODE,
        DISPOSER_SI_DO,
        DISPOSER_SI_GUN_GU,
        DISPOSER_EUP_MYEON_DONG,
        DISPOSER_DONG_RI,
        DISPOSER_ADDR,
        DISPOSER_LAT,
        DISPOSER_LNG
    FROM V_COLLECTOR_BIDDING_WITH_STATE
	WHERE 
		STATE_CODE = IN_STATE_CODE AND 
        COLLECTOR_SITE_ID IN (SELECT AFFILIATED_SITE FROM USERS WHERE ID = IN_USER_ID AND ACTIVE = TRUE);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS CURRENT_STATE_BY_OPTION (
		COLLECTOR_SITE_ID				BIGINT,
		COLLECTOR_BIDDING_ID			BIGINT,
		DISPOSER_ORDER_ID				BIGINT,
		ORDER_CODE						VARCHAR(10),
		IMG_PATH						JSON,
		WSTE_LSIT						JSON,
		WSTE_GEO_INFO					JSON,
		DISPLAY_DATE					DATETIME,
		STATE							VARCHAR(20),
		STATE_CODE						INT,
		STATE_CATEGORY					VARCHAR(20),
		STATE_CATEGORY_ID				INT,
		DISPOSER_NOTE					VARCHAR(255),
		DISPOSER_CLOSE_AT				DATETIME,
        DISPOSER_KIKCD_B_CODE			VARCHAR(10),
        DISPOSER_SI_DO					VARCHAR(20),
        DISPOSER_SI_GUN_GU				VARCHAR(20),
        DISPOSER_EUP_MYEON_DONG			VARCHAR(20),
        DISPOSER_DONG_RI				VARCHAR(20),
        DISPOSER_ADDR					VARCHAR(255),
        DISPOSER_LAT					DECIMAL(12,9),
        DISPOSER_LNG					DECIMAL(12,9)
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_COLLECTOR_SITE_ID,
			CUR_COLLECTOR_BIDDING_ID,
			CUR_DISPOSER_ORDER_ID,
			CUR_DISPOSER_ORDER_CODE,
			CUR_STATE,
			CUR_STATE_CODE,
			CUR_STATE_CATEGORY,
			CUR_STATE_CATEGORY_ID,
			CUR_DISPOSER_NOTE,
			CUR_DISPOSER_CLOSE_AT,
			CUR_DISPOSER_B_CODE,
			CUR_DISPOSER_SI_DO,
			CUR_DISPOSER_SI_GUN_GU,
			CUR_DISPOSER_EUP_MYEON_DONG,
			CUR_DISPOSER_DONG_RI,
			CUR_DISPOSER_ADDR,
			CUR_DISPOSER_LAT,
			CUR_DISPOSER_LNG;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		CURRENT_STATE_BY_OPTION(
			COLLECTOR_SITE_ID, 
			COLLECTOR_BIDDING_ID, 
			DISPOSER_ORDER_ID, 
			ORDER_CODE, 
			STATE, 
			STATE_CODE, 
			STATE_CATEGORY, 
			STATE_CATEGORY_ID, 
			DISPOSER_NOTE, 
			DISPOSER_CLOSE_AT,
			DISPOSER_KIKCD_B_CODE,
			DISPOSER_SI_DO,
			DISPOSER_SI_GUN_GU,
			DISPOSER_EUP_MYEON_DONG,
			DISPOSER_DONG_RI,
			DISPOSER_ADDR,
			DISPOSER_LAT,
			DISPOSER_LNG
		)
		VALUES(
			CUR_COLLECTOR_SITE_ID,
			CUR_COLLECTOR_BIDDING_ID, 
			CUR_DISPOSER_ORDER_ID, 
			CUR_DISPOSER_ORDER_CODE, 
			CUR_STATE, 
			CUR_STATE_CODE, 
			CUR_STATE_CATEGORY,
			CUR_STATE_CATEGORY_ID,
			CUR_DISPOSER_NOTE,
			CUR_DISPOSER_CLOSE_AT,
			CUR_DISPOSER_B_CODE,
			CUR_DISPOSER_SI_DO,
			CUR_DISPOSER_SI_GUN_GU,
			CUR_DISPOSER_EUP_MYEON_DONG,
			CUR_DISPOSER_DONG_RI,
			CUR_DISPOSER_ADDR,
			CUR_DISPOSER_LAT,
			CUR_DISPOSER_LNG
		);
        
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'WSTE_CLASS'	, WSTE_CLASS, 
			'WSTE_NM'		, WSTE_CLASS_NM, 
            'APR'			, WSTE_APPEARANCE_NM, 
            'QTY'			, WSTE_QUANTITY, 
            'UNIT'			, WSTE_UNIT, 
            'CREATED_AT'	, WSTE_DISCHARGED_CREATED_AT
		)) 
        INTO @WSTE_LIST 
        FROM V_WSTE_DISCHARGED_FROM_SITE 
        WHERE DISPOSAL_ORDER_ID = CUR_DISPOSER_ORDER_ID;
		/*DISPOSAL_ORDER_ID에 등록된 폐기물 종류 중 하나만 불러온다.*/
		
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'ID'			, ID, 
            'FILE_NAME'		, FILE_NAME, 
            'PATH'			, IMG_PATH
		)) 
        INTO @IMG_PATH 
        FROM WSTE_REGISTRATION_PHOTO 
        WHERE DISPOSAL_ORDER_ID = CUR_DISPOSER_ORDER_ID;
		/*DISPOSAL_ORDER_ID에 해당하는 이미지에 대한 저장경로를 JSON 형태로 받아온다.*/
		
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'ID'			, ID, 
            'LAT'			, LAT, 
            'LNG'			, LNG
		)) 
        INTO @WSTE_GEO_INFO 
        FROM SITE_WSTE_DISPOSAL_ORDER 
        WHERE ID = CUR_DISPOSER_ORDER_ID;
		/*DISPOSAL_ORDER_ID에 해당하는 이미지에 대한 저장경로를 JSON 형태로 받아온다.*/
        
        SELECT 
        CASE
			WHEN CUR_STATE_CATEGORY_ID = 2
				THEN (
					SELECT 
						IF(VISIT_START_AT IS NOT NULL, 
							IF(VISIT_START_AT <= NOW(), 
								VISIT_END_AT, 
								VISIT_START_AT
							),
							VISIT_END_AT
						) 
					FROM SITE_WSTE_DISPOSAL_ORDER 
					WHERE ID = CUR_DISPOSER_ORDER_ID
				)
			WHEN CUR_STATE_CATEGORY_ID = 3
				THEN (
					SELECT BIDDING_END_AT
					FROM SITE_WSTE_DISPOSAL_ORDER 
					WHERE ID = CUR_DISPOSER_ORDER_ID
				)
			WHEN CUR_STATE_CATEGORY_ID = 4
				THEN (
					SELECT 
						IF(MAX_SELECT_AT <= NOW(), 
							IF(BIDDERS > 1, 
								MAX_SELECT2_AT,
								MAX_SELECT_AT
							) ,
							MAX_SELECT_AT
						) 
					FROM SITE_WSTE_DISPOSAL_ORDER 
					WHERE ID = CUR_DISPOSER_ORDER_ID
				)
			WHEN CUR_STATE_CATEGORY_ID = 5
				THEN (
					SELECT 
						IF(A.COLLECT_ASK_END_AT <= NOW(), 
							B.CLOSE_AT,
							A.COLLECT_ASK_END_AT
						) 
					FROM WSTE_CLCT_TRMT_TRANSACTION A 
                    LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B 
                    ON A.DISPOSAL_ORDER_ID = B.ID
					WHERE A.ID = CUR_DISPOSER_ORDER_ID
				)
			WHEN CUR_STATE_CATEGORY_ID = 6
				THEN CUR_DISPOSER_CLOSE_AT
            ELSE NULL
        END INTO @DISPLAY_DATE;
		
		UPDATE CURRENT_STATE_TEMP 
        SET 
			IMG_PATH 			= @IMG_PATH, 
            WSTE_LSIT 			= @WSTE_LSIT, 
            WSTE_GEO_INFO 		= @WSTE_GEO_INFO, 
            DISPLAY_DATE 		= @DISPLAY_DATE 
        WHERE DISPOSER_ORDER_ID = CUR_DISPOSER_ORDER_ID;
		/*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/		
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'COLLECTOR_SITE_ID'			, COLLECTOR_SITE_ID, 
        'COLLECTOR_BIDDING_ID'		, COLLECTOR_BIDDING_ID, 
        'DISPOSER_ORDER_ID'			, DISPOSER_ORDER_ID, 
        'ORDER_CODE'				, ORDER_CODE, 
        'DISPLAY_DATE'				, DISPLAY_DATE, 
        'IMG_PATH'					, IMG_PATH, 
        'WSTE_LSIT'					, WSTE_LSIT, 
        'WSTE_GEO_INFO'				, WSTE_GEO_INFO, 
        'STATE'						, STATE, 
        'STATE_CODE'				, STATE_CODE, 
        'DISPOSER_NOTE'				, DISPOSER_NOTE, 
        'DISPOSER_CLOSE_AT'			, DISPOSER_CLOSE_AT, 
        'DISPOSER_KIKCD_B_CODE'		, DISPOSER_KIKCD_B_CODE, 
        'DISPOSER_SI_DO'			, DISPOSER_SI_DO, 
        'DISPOSER_SI_GUN_GU'		, DISPOSER_SI_GUN_GU, 
        'DISPOSER_EUP_MYEON_DONG'	, DISPOSER_EUP_MYEON_DONG, 
        'DISPOSER_DONG_RI'			, DISPOSER_DONG_RI, 
        'DISPOSER_ADDR'				, DISPOSER_ADDR, 
        'DISPOSER_LAT'				, DISPOSER_LAT, 
        'DISPOSER_LNG'				, DISPOSER_LNG
	)) 
    INTO @json_data FROM CURRENT_STATE_TEMP;
    
    IF vRowCount = 0 THEN
		SET @rtn_val = 29001;
		SET @msg_txt = 'No data found';
    ELSE
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	DROP TABLE IF EXISTS CURRENT_STATE_BY_OPTION;
END