CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_processing_status`(
	IN IN_TRANSACTION_ID					BIGINT,
	IN IN_STATE								TINYINT			/*입력값 : 현재처리중인것은 TRUE, 과거처리내역은 FALSE*/
)
BEGIN

/*
Procedure Name 	: sp_req_processing_status
Input param 	: 2개
Job 			: 폐기물 처리중인 작업에 대한 개별 상태 반환
Update 			: 2022.01.30
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 						INT DEFAULT 0;
    DECLARE endOfRow 						TINYINT DEFAULT FALSE;    
    DECLARE CUR_TRANSACTION_ID				BIGINT;
    DECLARE CUR_COLLECTOR_SITE_ID			BIGINT;
    DECLARE CUR_DISPOSER_ORDER_ID			BIGINT;	
    DECLARE CUR_COLLECTOR_BIDDING_ID		BIGINT;	
    DECLARE TEMP_CURSOR		 				CURSOR FOR 
	SELECT 
		ID, 
        COLLECTOR_SITE_ID,
        DISPOSAL_ORDER_ID,
        COLLECTOR_BIDDING_ID
        
    FROM WSTE_CLCT_TRMT_TRANSACTION
	WHERE 
		ID = IN_TRANSACTION_ID AND 
        ISNULL(CONFIRMED_AT) = IF(IN_STATE = FALSE, FALSE, TRUE);
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		SET @json_data 		= NULL;
		DROP TABLE IF EXISTS PROCESSING_STATUS_TEMP;
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
	CREATE TEMPORARY TABLE IF NOT EXISTS PROCESSING_STATUS_TEMP (
		TRANSACTION_ID				BIGINT,
		COLLECTOR_SITE_ID			BIGINT,
		DISPOSER_ORDER_ID			BIGINT,
		WSTE_LIST					JSON,
		IMG_LIST					JSON,
		ORDER_INFO					JSON,
		COLLECTOR_INFO				JSON
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_TRANSACTION_ID,
			CUR_COLLECTOR_SITE_ID,
			CUR_DISPOSER_ORDER_ID,
			CUR_COLLECTOR_BIDDING_ID;   
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		PROCESSING_STATUS_TEMP(
			TRANSACTION_ID, 
			COLLECTOR_SITE_ID, 
			DISPOSER_ORDER_ID
		)
		VALUES(
			CUR_TRANSACTION_ID, 
			CUR_COLLECTOR_SITE_ID, 
			CUR_DISPOSER_ORDER_ID
		);
        
        CALL sp_get_report_wste_lists(
			CUR_DISPOSER_ORDER_ID,
            CUR_TRANSACTION_ID,
            @WSTE_LIST
        );
		/*처리된 폐기물 종류를 JSON형태로 변환한다.*/
        
        CALL sp_get_collector_img_lists(
            CUR_TRANSACTION_ID,
            @IMG_LIST
        );
        
        CALL sp_get_disposal_order_info(
			CUR_DISPOSER_ORDER_ID,
			CUR_TRANSACTION_ID,
            @ORDER_INFO
        );
        
        IF CUR_COLLECTOR_SITE_ID IS NOT NULL THEN
			SET @COLLECTOR_SITE_ID = CUR_COLLECTOR_SITE_ID;
		ELSE
			SELECT COLLECTOR_ID INTO @COLLECTOR_SITE_ID
            FROM COLLECTOR_BIDDING
            WHERE ID = CUR_COLLECTOR_BIDDING_ID;
        END IF;
        
        CALL sp_get_site_info(
			@COLLECTOR_SITE_ID,
            @COLLECTOR_INFO
        );
		
		UPDATE PROCESSING_STATUS_TEMP 
        SET 
			IMG_LIST 			= @IMG_LIST, 
            WSTE_LIST 			= @WSTE_LIST, 
            ORDER_INFO 			= @ORDER_INFO , 
            COLLECTOR_INFO 		= @COLLECTOR_INFO 
        WHERE TRANSACTION_ID = CUR_TRANSACTION_ID;
		/*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/
		
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
    
    IF vRowCount = 0 THEN
		SET @rtn_val = 20801;
		SET @msg_txt = 'No data found';
		SET @json_data = NULL;
		SIGNAL SQLSTATE '23000';
    ELSE
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';	
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'TRANSACTION_ID'			, TRANSACTION_ID, 
				'COLLECTOR_SITE_ID'			, COLLECTOR_SITE_ID, 
				'DISPOSER_ORDER_ID'			, DISPOSER_ORDER_ID, 
				'WSTE_LIST'					, WSTE_LIST, 
				'IMG_LIST'					, IMG_LIST, 
				'ORDER_INFO'				, ORDER_INFO, 
				'COLLECTOR_INFO'			, COLLECTOR_INFO
			)
		) 
		INTO @json_data 
		FROM PROCESSING_STATUS_TEMP;
    END IF;   
	DROP TABLE IF EXISTS PROCESSING_STATUS_TEMP;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);  
END