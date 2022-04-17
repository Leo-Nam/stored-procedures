CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_push_history`(
	IN IN_USER_ID							BIGINT,
    IN IN_OFFSET_SIZE						INT,
    IN IN_PAGE_SIZE							INT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_push_history
Input param 	: 3개
Job 			: 푸시 히스토리를 반환한다
Update 			: 2022.04.16
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_ID 								BIGINT; 
    DECLARE CUR_USER_ID 						BIGINT;
    DECLARE CUR_TITLE 							VARCHAR(255);
    DECLARE CUR_BODY							VARCHAR(255);	
    DECLARE CUR_CREATED_AT						DATETIME;	
    DECLARE CUR_IS_READ							TINYINT;	
    DECLARE CUR_IS_READ_AT						DATETIME;	
    DECLARE CUR_DELETED							TINYINT;	
    DECLARE CUR_DELETED_AT						DATETIME;	
    DECLARE CUR_SENDER_ID						BIGINT;	
    DECLARE CUR_ORDER_ID						BIGINT;	
    DECLARE CUR_BIDDING_ID						BIGINT;	
    DECLARE CUR_TRANSACTION_ID					BIGINT;	
    DECLARE CUR_REPORT_ID						BIGINT;	
    DECLARE CUR_TARGET_URL						VARCHAR(255);	
    DECLARE PUSH_HISTORY_CURSOR 				CURSOR FOR 
	SELECT 
		A.ID, 
        A.USER_ID, 
        A.TITLE,
        A.BODY,
        A.CREATED_AT,
        A.IS_READ	,
        A.IS_READ_AT,
        A.DELETED,
        A.DELETED_AT,
        A.SENDER_ID,
        A.ORDER_ID,
        A.BIDDING_ID,
        A.TRANSACTION_ID,
        A.REPORT_ID,
        A.TARGET_URL
    FROM PUSH_HISTORY A
    LEFT JOIN USERS B ON A.USER_ID = B.ID
    WHERE B.ID = IN_USER_ID
    ORDER BY CREATED_AT DESC
    LIMIT IN_OFFSET_SIZE, IN_PAGE_SIZE;  
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		DROP TABLE IF EXISTS PUSH_HISTORY_TEMP;
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
        
	CREATE TEMPORARY TABLE IF NOT EXISTS PUSH_HISTORY_TEMP (
		ID 								BIGINT,
		USER_ID 						BIGINT,
		TITLE 							VARCHAR(255),
		BODY							VARCHAR(255),
		CREATED_AT						DATETIME,
		IS_READ							TINYINT,
		IS_READ_AT						DATETIME,
		DELETED							TINYINT,
		DELETED_AT						DATETIME,
		SENDER_ID						BIGINT,
		ORDER_ID						BIGINT,
		BIDDING_ID						BIGINT,
		TRANSACTION_ID					BIGINT,
		REPORT_ID						BIGINT,
		TARGET_URL						VARCHAR(255),
        ORDER_INFO						JSON,
        BIDDING_INFO					JSON,
        TRANSACTION_INFO				JSON,
        REPORT_INFO						JSON
	);
    
	OPEN PUSH_HISTORY_CURSOR;	
	cloop: LOOP
		FETCH PUSH_HISTORY_CURSOR 
        INTO  
			CUR_ID,
			CUR_USER_ID,
			CUR_TITLE,
			CUR_BODY,
			CUR_CREATED_AT,
			CUR_IS_READ,
			CUR_IS_READ_AT,
			CUR_DELETED,
			CUR_DELETED_AT,
			CUR_SENDER_ID,
			CUR_ORDER_ID,
			CUR_BIDDING_ID,
			CUR_TRANSACTION_ID,
			CUR_REPORT_ID,
			CUR_TARGET_URL;
        
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
		INSERT INTO 
        PUSH_HISTORY_TEMP(
			ID,
			USER_ID,
			TITLE,
			BODY,
			CREATED_AT,
			IS_READ,
			IS_READ_AT,
			DELETED,
			DELETED_AT,
			SENDER_ID,
			ORDER_ID,
			BIDDING_ID,
			TRANSACTION_ID,
			REPORT_ID,
			TARGET_URL
		)
        VALUES(
			CUR_ID,
			CUR_USER_ID,
			CUR_TITLE,
			CUR_BODY,
			CUR_CREATED_AT,
			CUR_IS_READ,
			CUR_IS_READ_AT,
			CUR_DELETED,
			CUR_DELETED_AT,
			CUR_SENDER_ID,
			CUR_ORDER_ID,
			CUR_BIDDING_ID,
			CUR_TRANSACTION_ID,
			CUR_REPORT_ID,
			CUR_TARGET_URL
		);
        
        IF CUR_ORDER_ID IS NOT NULL THEN
			CALL sp_get_disposal_order_info(
				CUR_ORDER_ID,
				@ORDER_INFO
			);
        ELSE
			SET @ORDER_INFO = NULL;
        END IF;
        
        IF CUR_BIDDING_ID IS NOT NULL THEN
			CALL sp_get_bidding_info(
				CUR_BIDDING_ID,
				@BIDDING_INFO
			);
        ELSE
			SET @BIDDING_INFO = NULL;
        END IF;
        
        IF CUR_TRANSACTION_ID IS NOT NULL THEN
			CALL sp_get_transaction_info_2(
				CUR_TRANSACTION_ID,
				@TRANSACTION_INFO
			);
        ELSE
			SET @TRANSACTION_INFO = NULL;
        END IF;
        
        IF CUR_REPORT_ID IS NOT NULL THEN
			CALL sp_get_transaction_report(
				CUR_REPORT_ID,
				@REPORT_INFO
			);
        ELSE
			SET @REPORT_INFO = NULL;
        END IF;
        
		UPDATE PUSH_HISTORY_TEMP 
        SET 
			ORDER_INFO 			= @ORDER_INFO, 
			BIDDING_INFO 		= @BIDDING_INFO, 
			TRANSACTION_INFO 	= @TRANSACTION_INFO, 
            REPORT_INFO 		= @REPORT_INFO 
		WHERE ID = CUR_ID;
        /*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 PUSH_HISTORY_TEMP 테이블에 반영한다.*/        
        
	END LOOP;   
	CLOSE PUSH_HISTORY_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'				, ID, 
            'USER_ID'			, USER_ID, 
            'TITLE'				, TITLE, 
            'BODY'				, BODY, 
            'CREATED_AT'		, CREATED_AT, 
            'IS_READ'			, IS_READ, 
            'IS_READ_AT'		, IS_READ_AT, 
            'DELETED'			, DELETED, 
            'DELETED_AT'		, DELETED_AT, 
            'SENDER_ID'			, SENDER_ID, 
            'ORDER_ID'			, ORDER_ID, 
            'BIDDING_ID'		, BIDDING_ID, 
            'TRANSACTION_ID'	, TRANSACTION_ID, 
            'REPORT_ID'			, REPORT_ID, 
            'TARGET_URL'		, TARGET_URL, 
            'ORDER_INFO'		, ORDER_INFO, 
            'BIDDING_INFO'		, BIDDING_INFO, 
            'TRANSACTION_INFO'	, TRANSACTION_INFO, 
            'REPORT_INFO'		, REPORT_INFO
		)
	) 
    INTO @json_data 
    FROM PUSH_HISTORY_TEMP;
    
	SET @rtn_val = 0;
	SET @msg_txt = 'Success11';
    DROP TABLE IF EXISTS PUSH_HISTORY_TEMP;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END