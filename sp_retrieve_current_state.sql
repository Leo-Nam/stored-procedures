CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_current_state`(
	IN IN_USER_ID							BIGINT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_current_state
Input param 	: 1개
Job 			: 수거자 메인 페이지 로딩시 필요한 자료 반환.
Update 			: 2022.01.23
Version			: 0.0.3
AUTHOR 			: Leo Nam
Change			: 폐기물 리스트와 폐기물 사진에 대한 정보는 JSON 타입으로 전달하는 방식 사용(0.0.3)
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_COLLECTOR_SITE_ID				BIGINT; 
    DECLARE CUR_COLLECTOR_BIDDING_ID			BIGINT;
    DECLARE CUR_DISPOSER_ORDER_ID				BIGINT;
    DECLARE CUR_STATE_CODE						INT;
    DECLARE CUR_STATE							VARCHAR(20);
    DECLARE CUR_STATE_PID						INT;
    DECLARE CUR_COLLECTOR_CATEGORY_ID			INT;
    DECLARE CUR_COLLECTOR_CATEGORY				VARCHAR(20);
    DECLARE CUR_BIDDING_RANK					INT;
    DECLARE CUR_TRANSACTION_STATE_CODE			INT;
    DECLARE TEMP_CURSOR		 					CURSOR FOR 
	SELECT 
		A.COLLECTOR_ID, 
        A.ID, 
        A.DISPOSAL_ORDER_ID,
        B.STATE_CODE,
        B.STATE,
        B.STATE_PID,
        B.COLLECTOR_CATEGORY_ID,
        B.COLLECTOR_CATEGORY,
        A.BIDDING_RANK
    FROM COLLECTOR_BIDDING A
    LEFT JOIN V_BIDDING_STATE_NAME B ON A.ID = B.COLLECTOR_BIDDING_ID
    LEFT JOIN USERS C ON A.COLLECTOR_ID = C.AFFILIATED_SITE
    LEFT JOIN COMP_SITE D ON A.COLLECTOR_ID = D.ID
    LEFT JOIN COMPANY E ON D.COMP_ID = E.ID
    LEFT JOIN SITE_WSTE_DISPOSAL_ORDER F ON A.DISPOSAL_ORDER_ID = F.ID
    LEFT JOIN V_TRANSACTION_STATE G ON G.COLLECTOR_BIDDING_ID = A.ID
	WHERE 
        C.ID = IN_USER_ID AND
        (C.CLASS = 201 OR C.CLASS = 202) AND
        A.ORDER_VISIBLE = TRUE AND
        C.ACTIVE = TRUE AND
        D.ACTIVE = TRUE AND
        E.ACTIVE = TRUE AND
        B.STATE_CODE NOT IN (202, 207, 211, 230, 238, 239, 241, 244, 246, 249) AND
        (G.TRANSACTION_STATE_CODE NOT IN (211) OR G.TRANSACTION_STATE_CODE IS NULL);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
            
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		DROP TABLE IF EXISTS RETRIEVE_CURRENT_STATE_TEMP;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;	
   
    /*트랜잭션 시작*/  
    
	CREATE TEMPORARY TABLE IF NOT EXISTS RETRIEVE_CURRENT_STATE_TEMP (
		COLLECTOR_SITE_ID				BIGINT,
		COLLECTOR_BIDDING_ID			BIGINT,
		DISPOSER_ORDER_ID				BIGINT,
        STATE_CODE						INT,
        STATE							VARCHAR(20),
        STATE_PID						INT,
        COLLECTOR_CATEGORY_ID			INT,
        COLLECTOR_CATEGORY				VARCHAR(20),
        BIDDING_RANK					INT,
		DISPLAY_DATE					DATETIME,
        WSTE_LIST						JSON,
        IMG_PATH						JSON,
        WSTE_GEO_INFO					JSON,
        DISPOSER_ORDER_INFO				JSON
        
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		SET @RETRIEVE_CURRENT_STATE_IMG_PATH = NULL;
		SET @RETRIEVE_CURRENT_STATE_WSTE_LIST = NULL; 
		SET @RETRIEVE_CURRENT_STATE_WSTE_GEO_INFO = NULL; 
		SET @RETRIEVE_CURRENT_STATE_DISPOSER_SITE_INFO = NULL; 
		SET @RETRIEVE_CURRENT_STATE_DISPLAY_DATE = NULL;
		
		FETCH TEMP_CURSOR 
		INTO 
			CUR_COLLECTOR_SITE_ID,
			CUR_COLLECTOR_BIDDING_ID,
			CUR_DISPOSER_ORDER_ID,
			CUR_STATE_CODE,
			CUR_STATE,
			CUR_STATE_PID,
			CUR_COLLECTOR_CATEGORY_ID,
			CUR_COLLECTOR_CATEGORY,
			CUR_BIDDING_RANK;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		RETRIEVE_CURRENT_STATE_TEMP(
			COLLECTOR_SITE_ID, 
			COLLECTOR_BIDDING_ID, 
			DISPOSER_ORDER_ID,
			STATE_CODE,
			STATE,
			STATE_PID,
			COLLECTOR_CATEGORY_ID,
			COLLECTOR_CATEGORY,
			BIDDING_RANK
		)
		VALUES(
			CUR_COLLECTOR_SITE_ID,
			CUR_COLLECTOR_BIDDING_ID, 
			CUR_DISPOSER_ORDER_ID,
			CUR_STATE_CODE,
			CUR_STATE,
			CUR_STATE_PID,
			CUR_COLLECTOR_CATEGORY_ID,
			CUR_COLLECTOR_CATEGORY,
			CUR_BIDDING_RANK
		);
            
		CALL sp_get_disposal_wste_lists(
			CUR_DISPOSER_ORDER_ID,
			@RETRIEVE_CURRENT_STATE_WSTE_LIST
		);
		            
		CALL sp_get_disposal_img_lists(
			CUR_DISPOSER_ORDER_ID,
			'입찰',
			@RETRIEVE_CURRENT_STATE_IMG_PATH
		);
		            
		CALL sp_get_disposer_wste_geo_info(
			CUR_DISPOSER_ORDER_ID,
			@RETRIEVE_CURRENT_STATE_WSTE_GEO_INFO
		);
            
		CALL sp_set_display_time_for_collector(
			CUR_DISPOSER_ORDER_ID,
			CUR_COLLECTOR_BIDDING_ID,
			CUR_COLLECTOR_CATEGORY_ID,
			@RETRIEVE_CURRENT_STATE_DISPLAY_DATE
		);
        
        SELECT B.ID INTO @RETRIEVE_CURRENT_STATE_TRANSACTION_ID
        FROM SITE_WSTE_DISPOSAL_ORDER A 
        LEFT JOIN WSTE_CLCT_TRMT_TRANSACTION B ON A.ID = B.DISPOSAL_ORDER_ID
        WHERE 
			A.ID = CUR_DISPOSER_ORDER_ID;
            
		CALL sp_get_disposal_order_info(
			CUR_DISPOSER_ORDER_ID,
			@RETRIEVE_CURRENT_STATE_DISPOSER_ORDER_INFO
		);
		
		UPDATE RETRIEVE_CURRENT_STATE_TEMP 
        SET 
			IMG_PATH 			= @RETRIEVE_CURRENT_STATE_IMG_PATH, 
            WSTE_LIST 			= @RETRIEVE_CURRENT_STATE_WSTE_LIST, 
            WSTE_GEO_INFO 		= @RETRIEVE_CURRENT_STATE_WSTE_GEO_INFO, 
            DISPOSER_ORDER_INFO	= @RETRIEVE_CURRENT_STATE_DISPOSER_ORDER_INFO , 
            DISPLAY_DATE 		= @RETRIEVE_CURRENT_STATE_DISPLAY_DATE 
        WHERE COLLECTOR_BIDDING_ID = CUR_COLLECTOR_BIDDING_ID;
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'COLLECTOR_SITE_ID'			, COLLECTOR_SITE_ID, 
        'COLLECTOR_BIDDING_ID'		, COLLECTOR_BIDDING_ID, 
        'DISPOSER_ORDER_ID'			, DISPOSER_ORDER_ID, 
        'STATE_CODE'				, STATE_CODE, 
        'STATE'						, STATE, 
        'STATE_PID'					, STATE_PID, 
        'COLLECTOR_CATEGORY_ID'		, COLLECTOR_CATEGORY_ID, 
        'COLLECTOR_CATEGORY'		, COLLECTOR_CATEGORY, 
        'BIDDING_RANK'				, BIDDING_RANK, 
        'DISPLAY_DATE'				, DISPLAY_DATE, 
        'IMG_PATH'					, IMG_PATH, 
        'WSTE_LIST'					, WSTE_LIST, 
        'WSTE_GEO_INFO'				, WSTE_GEO_INFO, 
        'DISPOSER_ORDER_INFO'		, DISPOSER_ORDER_INFO
	)) 
    INTO @json_data FROM RETRIEVE_CURRENT_STATE_TEMP;
    
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
/*    IF vRowCount = 0 THEN
		SET @rtn_val = 29101;
		SET @msg_txt = 'No data found';
		SIGNAL SQLSTATE '23000';
    ELSE
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';
    END IF;*/
	DROP TABLE IF EXISTS RETRIEVE_CURRENT_STATE_TEMP;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END