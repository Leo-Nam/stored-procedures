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
    DECLARE CUR_STATE_CODE						INT;
    DECLARE CUR_STATE							VARCHAR(20);
    DECLARE CUR_STATE_PID						INT;
    DECLARE CUR_COLLECTOR_CATEGORY_ID			INT;
    DECLARE CUR_COLLECTOR_CATEGORY				VARCHAR(20);
    DECLARE CUR_BIDDING_RANK					INT;
    DECLARE CUR_TRANSACTION_ID					BIGINT;
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
        A.BIDDING_RANK,
        G.ID
    FROM COLLECTOR_BIDDING A
    LEFT JOIN V_BIDDING_STATE_NAME B ON A.ID = B.COLLECTOR_BIDDING_ID
    LEFT JOIN USERS C ON A.COLLECTOR_ID = C.AFFILIATED_SITE
    LEFT JOIN COMP_SITE D ON A.COLLECTOR_ID = D.ID
    LEFT JOIN COMPANY E ON D.COMP_ID = E.ID
    LEFT JOIN SITE_WSTE_DISPOSAL_ORDER F ON A.DISPOSAL_ORDER_ID = F.ID
    LEFT JOIN WSTE_CLCT_TRMT_TRANSACTOIN G ON A.ID = G.COLLECTOR_BIDDING_ID
	WHERE 
		B.COLLECTOR_CATEGORY_ID = IN_STATE_CODE AND 
        C.ID = IN_USER_ID AND
        (C.CLASS = 201 OR C.CLASS = 202) AND
        C.ACTIVE = TRUE AND
        D.ACTIVE = TRUE AND
        E.ACTIVE = TRUE;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
	CREATE TEMPORARY TABLE IF NOT EXISTS CURRENT_STATE_BY_OPTION (
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
        DISPOSER_ORDER_INFO				JSON,
        SECOND_PLACE_ON					TINYINT
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		SET @RETRIEVE_CURRENT_STATE_IMG_PATH = NULL;
		SET @RETRIEVE_CURRENT_STATE_WSTE_LIST = NULL; 
		SET @RETRIEVE_CURRENT_STATE_WSTE_GEO_INFO = NULL; 
		SET @RETRIEVE_CURRENT_STATE_DISPOSER_SITE_INFO = NULL; 
		SET @RETRIEVE_CURRENT_STATE_DISPLAY_DATE = NULL;
		SET @RETRIEVE_CURRENT_STATE_TRANSACTION_INFO = NULL;
        
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
			CUR_BIDDING_RANK,
			CUR_TRANSACTION_ID;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		CURRENT_STATE_BY_OPTION(
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
            
		CALL sp_get_transaction_info_2(
			CUR_TRANSACTION_ID,
			@RETRIEVE_CURRENT_STATE_TRANSACTION_INFO
		);
        
        CALL sp_check_if_second_place_on(
			CUR_DISPOSER_ORDER_ID,
            CUR_COLLECTOR_BIDDING_ID,
            @SECOND_PLACE_ON
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
		
		UPDATE CURRENT_STATE_BY_OPTION 
        SET 
			IMG_PATH 			= @RETRIEVE_CURRENT_STATE_IMG_PATH, 
            WSTE_LIST 			= @RETRIEVE_CURRENT_STATE_WSTE_LIST, 
            WSTE_GEO_INFO 		= @RETRIEVE_CURRENT_STATE_WSTE_GEO_INFO, 
            DISPOSER_ORDER_INFO	= @RETRIEVE_CURRENT_STATE_DISPOSER_ORDER_INFO , 
            DISPLAY_DATE 		= @RETRIEVE_CURRENT_STATE_DISPLAY_DATE ,
            TRANSACTION_INFO	= @RETRIEVE_CURRENT_STATE_TRANSACTION_INFO ,
            SECOND_PLACE_ON		= @SECOND_PLACE_ON 
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
        'DISPOSER_ORDER_INFO'		, DISPOSER_ORDER_INFO, 
        'TRANSACTION_INFO'			, TRANSACTION_INFO, 
        'SECOND_PLACE_ON'			, SECOND_PLACE_ON
	)) 
    INTO @json_data FROM CURRENT_STATE_BY_OPTION;
    
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
/*    IF vRowCount = 1 THEN
		SET @rtn_val = 29001;
		SET @msg_txt = 'No data found';
		SIGNAL SQLSTATE '23000';
    ELSE
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';
    END IF;*/
	DROP TABLE IF EXISTS CURRENT_STATE_BY_OPTION;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END