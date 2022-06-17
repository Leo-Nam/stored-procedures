CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_disposal_order_details`(
	IN IN_DISPOSER_ORDER_ID							BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_disposal_order_details
Input param 	: 1개
Job 			: 배출자의 배출신청에 대한 입찰 상세정보
Update 			: 2022.02.15
Version			: 0.0.4
AUTHOR 			: Leo Nam
*/
    

    DECLARE vRowCount 								INT DEFAULT 0;
    DECLARE endOfRow 								TINYINT DEFAULT FALSE;    
    DECLARE CUR_DISPOSER_ORDER_ID					BIGINT;
    DECLARE CUR_COLLECTOR_ID						BIGINT;
    DECLARE CUR_DISPOSER_ORDER_CODE					VARCHAR(10);
    DECLARE CUR_DISPOSER_SITE_ID					BIGINT;
    DECLARE CUR_DISPOSER_SITE_SI_DO					VARCHAR(20);
    DECLARE CUR_DISPOSER_SITE_SI_GUN_GU				VARCHAR(20);
    DECLARE CUR_DISPOSER_SITE_EUP_MYEON_DONG		VARCHAR(20);
    DECLARE CUR_DISPOSER_SITE_DONG_RI				VARCHAR(20);
    DECLARE CUR_DISPOSER_SITE_ADDR					VARCHAR(255);
    DECLARE CUR_DATE 								DATETIME;	
    DECLARE CUR_STATE								VARCHAR(20);
    DECLARE CUR_STATE_CODE							INT;
    DECLARE CUR_NOTE								VARCHAR(255);
    DECLARE CUR_B_CODE								VARCHAR(10);
    DECLARE CUR_WSTE_DISPOSED_SI_DO					VARCHAR(20);
    DECLARE CUR_WSTE_DISPOSED_SI_GUN_GU				VARCHAR(20);
    DECLARE CUR_WSTE_DISPOSED_EUP_MYEON_DONG		VARCHAR(20);
    DECLARE CUR_WSTE_DISPOSED_DONG_RI				VARCHAR(20);
    DECLARE CUR_WSTE_DISPOSED_KIKCD_B_CODE			VARCHAR(20);
    DECLARE CUR_WSTE_DISPOSED_ADDR					VARCHAR(255);
    DECLARE CUR_DISPOSER_CREATED_AT					DATETIME;	
    DECLARE CUR_DISPOSER_CLOSE_AT					DATETIME;	
    DECLARE CUR_STATE_CATEGORY_CODE					INT;
    DECLARE CUR_TRANSACTION_ID						BIGINT;
    DECLARE CUR_WSTE_LAT							DECIMAL(12,9);
    DECLARE CUR_WSTE_LNG							DECIMAL(12,9);
    DECLARE CUR_VISIT_START_AT						DATETIME;	
    DECLARE CUR_VISIT_END_AT						DATETIME;	
    DECLARE TEMP_CURSOR		 						CURSOR FOR 
	SELECT 
		A.ID, 
		A.COLLECTOR_ID, 
		A.ORDER_CODE, 
        A.SITE_ID,
        B.COMP_SITE_SI_DO,
        B.COMP_SITE_SI_GUN_GU,
        B.COMP_SITE_EUP_MYEON_DONG,
        B.COMP_SITE_DONG_RI,
        B.COMP_SITE_ADDR,
        C.STATE, 
        C.STATE_CODE,
        A.NOTE,
        B.COMP_SITE_KIKCD_B_CODE,
        D.SI_DO,
        D.SI_GUN_GU,
        D.EUP_MYEON_DONG,
        D.DONG_RI,
        A.KIKCD_B_CODE,
        A.ADDR,
        A.CREATED_AT,
        A.CLOSE_AT,
        C.STATE_CATEGORY_ID,
        A.TRANSACTION_ID,
        A.LAT,
        A.LNG,
        A.VISIT_START_AT,
        A.VISIT_END_AT
    FROM SITE_WSTE_DISPOSAL_ORDER A
    LEFT JOIN V_COMP_SITE B ON A.SITE_ID = B.COMP_SITE_ID
    LEFT JOIN V_ORDER_STATE_NAME C ON A.ID = C.DISPOSER_ORDER_ID
    LEFT JOIN KIKCD_B D ON A.KIKCD_B_CODE = D.B_CODE
    LEFT JOIN COMP_SITE E ON A.SITE_ID = E.ID
    LEFT JOIN COMPANY F ON E.COMP_ID = F.ID
	WHERE 
		A.ID = IN_DISPOSER_ORDER_ID AND
		IF(A.SITE_ID = 0, 
			A.ID = IN_DISPOSER_ORDER_ID, 
            A.ID = IN_DISPOSER_ORDER_ID AND E.ACTIVE = TRUE AND F.ACTIVE = TRUE
		);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		DROP TABLE IF EXISTS ORDER_DETAIL_TEMP;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;				
    /*트랜잭션 시작*/  
    
	CREATE TEMPORARY TABLE IF NOT EXISTS ORDER_DETAIL_TEMP (
		DISPOSER_ORDER_ID							BIGINT,
		DISPOSER_ORDER_CODE							VARCHAR(10),
		DISPOSER_SITE_ID							BIGINT,
		DISPOSER_SITE_SI_DO							VARCHAR(20),
		DISPOSER_SITE_SI_GUN_GU						VARCHAR(20),
		DISPOSER_SITE_EUP_MYEON_DONG				VARCHAR(20),
		DISPOSER_SITE_DONG_RI						VARCHAR(20),
		DISPOSER_SITE_ADDR							VARCHAR(255),
		DISPLAY_DATE								DATETIME,
		STATE										VARCHAR(20),
		STATE_CODE									INT,
		NOTE										VARCHAR(255),
		DISPOSER_SITE_KIKCD_B_CODE					VARCHAR(20),
		WSTE_DISPOSED_SI_DO							VARCHAR(20),
		WSTE_DISPOSED_SI_GUN_GU						VARCHAR(20),
		WSTE_DISPOSED_EUP_MYEON_DONG				VARCHAR(20),
		WSTE_DISPOSED_DONG_RI						VARCHAR(20),
		WSTE_DISPOSED_KIKCD_B_CODE					VARCHAR(20),
		WSTE_DISPOSED_ADDR							VARCHAR(255),
		DISPOSER_CREATED_AT							DATETIME,
		DISPOSER_CLOSE_AT							DATETIME,
		STATE_CATEGORY_CODE							INT,
		TRANSACTION_ID								BIGINT,
		WSTE_LAT									DECIMAL(12,9),
		WSTE_LNG									DECIMAL(12,9),
		TRANSACTION_TYPE							VARCHAR(20),
		VISIT_START_AT								DATETIME,
		VISIT_END_AT								DATETIME,
		DISPOSAL_WSTE_LIST							JSON,
		IMG_LIST									JSON,
		COLLECTOR_INFO								JSON,
		TRANSACTION_INFO							JSON
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_DISPOSER_ORDER_ID,
			CUR_COLLECTOR_ID,
			CUR_DISPOSER_ORDER_CODE,
			CUR_DISPOSER_SITE_ID,
			CUR_DISPOSER_SITE_SI_DO,
			CUR_DISPOSER_SITE_SI_GUN_GU,
			CUR_DISPOSER_SITE_EUP_MYEON_DONG,
			CUR_DISPOSER_SITE_DONG_RI,
			CUR_DISPOSER_SITE_ADDR,
			CUR_STATE,
			CUR_STATE_CODE,
			CUR_NOTE,
			CUR_B_CODE,
			CUR_WSTE_DISPOSED_SI_DO,
			CUR_WSTE_DISPOSED_SI_GUN_GU,
			CUR_WSTE_DISPOSED_EUP_MYEON_DONG,
			CUR_WSTE_DISPOSED_DONG_RI,
			CUR_WSTE_DISPOSED_KIKCD_B_CODE,
			CUR_WSTE_DISPOSED_ADDR,
			CUR_DISPOSER_CREATED_AT,
			CUR_DISPOSER_CLOSE_AT,
			CUR_STATE_CATEGORY_CODE,
			CUR_TRANSACTION_ID,
			CUR_WSTE_LAT,
			CUR_WSTE_LNG,
			CUR_VISIT_START_AT,
			CUR_VISIT_END_AT;     
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		ORDER_DETAIL_TEMP(
			DISPOSER_ORDER_ID, 
			DISPOSER_ORDER_CODE, 
			DISPOSER_SITE_ID, 
			DISPOSER_SITE_SI_DO,
			DISPOSER_SITE_SI_GUN_GU,
			DISPOSER_SITE_EUP_MYEON_DONG,
			DISPOSER_SITE_DONG_RI,
			DISPOSER_SITE_ADDR,
			STATE, 
			STATE_CODE,
			NOTE, 
			DISPOSER_SITE_KIKCD_B_CODE,
			WSTE_DISPOSED_SI_DO,
			WSTE_DISPOSED_SI_GUN_GU,
			WSTE_DISPOSED_EUP_MYEON_DONG,
			WSTE_DISPOSED_DONG_RI,
			WSTE_DISPOSED_KIKCD_B_CODE,
			WSTE_DISPOSED_ADDR,
			DISPOSER_CREATED_AT,
			DISPOSER_CLOSE_AT,
			STATE_CATEGORY_CODE,
			TRANSACTION_ID,
			WSTE_LAT,
			WSTE_LNG,
			VISIT_START_AT,
			VISIT_END_AT
		)
		VALUES(
			CUR_DISPOSER_ORDER_ID, 
			CUR_DISPOSER_ORDER_CODE, 
			CUR_DISPOSER_SITE_ID,
			CUR_DISPOSER_SITE_SI_DO,
			CUR_DISPOSER_SITE_SI_GUN_GU,
			CUR_DISPOSER_SITE_EUP_MYEON_DONG,
			CUR_DISPOSER_SITE_DONG_RI,
			CUR_DISPOSER_SITE_ADDR,
			CUR_STATE, 
			CUR_STATE_CODE,
			CUR_NOTE,
			CUR_B_CODE,
			CUR_WSTE_DISPOSED_SI_DO,
			CUR_WSTE_DISPOSED_SI_GUN_GU,
			CUR_WSTE_DISPOSED_EUP_MYEON_DONG,
			CUR_WSTE_DISPOSED_DONG_RI,
			CUR_WSTE_DISPOSED_KIKCD_B_CODE,
			CUR_WSTE_DISPOSED_ADDR,
			CUR_DISPOSER_CREATED_AT,
			CUR_DISPOSER_CLOSE_AT,
			CUR_STATE_CATEGORY_CODE,
			CUR_TRANSACTION_ID,
			CUR_WSTE_LAT,
			CUR_WSTE_LNG,
			CUR_VISIT_START_AT,
			CUR_VISIT_END_AT
		);
		
		IF CUR_COLLECTOR_ID IS NULL THEN
			CALL sp_get_collector_lists(
				CUR_DISPOSER_ORDER_ID,
				CUR_STATE_CATEGORY_CODE,
				@COLLECTOR_INFO
			);
		ELSE
			CALL sp_get_site_info(
				CUR_COLLECTOR_ID,
				@COLLECTOR_INFO
			);
		END IF;
		
		CALL sp_get_disposal_wste_lists(
			CUR_DISPOSER_ORDER_ID,
			@DISPOSAL_WSTE_LIST 
		);
		
		CALL sp_get_disposal_img_lists(
			CUR_DISPOSER_ORDER_ID,
			'입찰',
			@IMG_LIST
		);
		
		CALL sp_set_display_time(
			CUR_DISPOSER_ORDER_ID,
			CUR_STATE_CATEGORY_CODE,
			@DISPLAY_DATE
		);
		
		CALL sp_get_transaction_info(
			CUR_DISPOSER_ORDER_ID,
			@TRANSACTION_INFO 
		);
		
		SELECT COLLECTOR_SITE_ID INTO @COLLECTOR_SITE_ID 
		FROM WSTE_CLCT_TRMT_TRANSACTION 
		WHERE 
			DISPOSAL_ORDER_ID = CUR_DISPOSER_ORDER_ID AND
			IN_PROGRESS = TRUE;
		
		UPDATE ORDER_DETAIL_TEMP 
		SET 
			COLLECTOR_INFO 				= @COLLECTOR_INFO, 
			DISPOSAL_WSTE_LIST 			= @DISPOSAL_WSTE_LIST, 
			IMG_LIST		 			= @IMG_LIST,
			DISPLAY_DATE				= @DISPLAY_DATE,
			TRANSACTION_INFO			= @TRANSACTION_INFO,
			TRANSACTION_TYPE			= IF(@COLLECTOR_SITE_ID IS NULL, '입찰거래', '기존거래')
		WHERE DISPOSER_ORDER_ID 		= CUR_DISPOSER_ORDER_ID;
		/*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'DISPOSER_ORDER_ID'						, DISPOSER_ORDER_ID, 
			'DISPOSER_ORDER_CODE'					, DISPOSER_ORDER_CODE, 
			'DISPOSER_SITE_ID'						, DISPOSER_SITE_ID, 
			'DISPOSER_SITE_SI_DO'					, DISPOSER_SITE_SI_DO, 
			'DISPOSER_SITE_SI_GUN_GU'				, DISPOSER_SITE_SI_GUN_GU, 
			'DISPOSER_SITE_EUP_MYEON_DONG'			, DISPOSER_SITE_EUP_MYEON_DONG, 
			'DISPOSER_SITE_DONG_RI'					, DISPOSER_SITE_DONG_RI, 
			'DISPOSER_SITE_ADDR'					, DISPOSER_SITE_ADDR, 
			'DISPLAY_DATE'							, DISPLAY_DATE,
			'STATE'									, STATE, 
			'STATE_CODE'							, STATE_CODE, 
			'NOTE'									, NOTE, 
			'DISPOSER_SITE_KIKCD_B_CODE'			, DISPOSER_SITE_KIKCD_B_CODE, 
			'WSTE_DISPOSED_SI_DO'					, WSTE_DISPOSED_SI_DO, 
			'WSTE_DISPOSED_SI_GUN_GU'				, WSTE_DISPOSED_SI_GUN_GU, 
			'WSTE_DISPOSED_EUP_MYEON_DONG'			, WSTE_DISPOSED_EUP_MYEON_DONG, 
			'WSTE_DISPOSED_DONG_RI'					, WSTE_DISPOSED_DONG_RI, 
			'WSTE_DISPOSED_KIKCD_B_CODE'			, WSTE_DISPOSED_KIKCD_B_CODE, 
			'WSTE_DISPOSED_ADDR'					, WSTE_DISPOSED_ADDR, 
			'DISPOSER_CREATED_AT'					, DISPOSER_CREATED_AT, 
			'STATE_CATEGORY_CODE'					, STATE_CATEGORY_CODE, 
			'TRANSACTION_ID'						, TRANSACTION_ID, 
			'WSTE_LAT'								, WSTE_LAT, 
			'WSTE_LNG'								, WSTE_LNG, 
			'TRANSACTION_TYPE'						, TRANSACTION_TYPE, 
			'DISPOSAL_WSTE_LIST'					, DISPOSAL_WSTE_LIST, 
			'IMG_LIST'								, IMG_LIST, 
			'COLLECTOR_INFO'						, COLLECTOR_INFO, 
			'TRANSACTION_INFO'						, TRANSACTION_INFO, 
			'VISIT_START_AT'						, VISIT_START_AT, 
			'VISIT_END_AT'							, VISIT_END_AT
		)
	) 
	INTO @json_data FROM ORDER_DETAIL_TEMP;
	
	SET @rtn_val 					= 0;
	SET @msg_txt 					= 'Success789456';
	DROP TABLE IF EXISTS ORDER_DETAIL_TEMP;  
	COMMIT;     
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END