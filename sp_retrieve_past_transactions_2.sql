CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_past_transactions_2`(
	IN IN_USER_ID							BIGINT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_past_transactions_2
Input param 	: 1개
Job 			: 수거자의 과거 처리업체(거래내역)를 리스트한다.
Update 			: 2022.02.10
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 								INT 				DEFAULT 0;
    DECLARE endOfRow 								TINYINT 			DEFAULT FALSE;   
    DECLARE CUR_REPORT_ID							BIGINT;   			/*수거자가 제출한 보고서 등록번호*/
    DECLARE CUR_TRANSACTION_ID						BIGINT;   			/*트랜잭션 아이디*/
    DECLARE CUR_WSTE_CODE							VARCHAR(8);			/*수거자가 처리완료한 폐기물 코드*/
    DECLARE CUR_WSTE_NAME							VARCHAR(255);		/*수거자가 처리완료한 폐기물 이름*/
    DECLARE CUR_WSTE_TRMT_METHOD					VARCHAR(30);   		/*폐기물 처리방법 이름*/
    DECLARE CUR_WSTE_APPEARANCE						VARCHAR(20);   		/*폐기물 성상*/
    DECLARE CUR_DISPOSER_ORDER_ID					BIGINT;				/*폐기물 배출 입찰등록번호*/
    DECLARE CUR_DISPOSER_ORDER_CODE					VARCHAR(10);    	/*폐기물 배출 입찰등록코드*/
    DECLARE CUR_CREATED_AT							DATETIME;    		/*수거자가 보고서를 제출한 일자*/
    DECLARE CUR_CONFIRMED_AT						DATETIME;    		/*수거자가 제출한 보고서를 배출자가 확정한 일자*/
    DECLARE CUR_STATE								VARCHAR(20);    	/*오더 상태*/
    DECLARE CUR_STATE_CODE							INT;   				/*오더 상태 코드*/
    DECLARE CUR_STATE_CATEGORY						VARCHAR(20);   		/*오더 대구분 상태*/
    DECLARE CUR_STATE_CATEGORY_ID					INT;    			/*오더 대구분 상태 코드*/
    DECLARE CUR_AVATAR_PATH							VARCHAR(255); 		/*수거자 아바타 경로*/
    DECLARE TEMP_CURSOR		 						CURSOR FOR 
	SELECT 
		A.ID, 
		A.TRANSACTION_ID, 
		A.WSTE_CODE, 
        B.NAME, 
        C.NAME,
        G.KOREAN,
        D.ID,
        D.ORDER_CODE,
        A.CREATED_AT,
        A.CONFIRMED_AT,
        E.STATE,
        E.STATE_CODE,
        E.STATE_CATEGORY,
        E.STATE_CATEGORY_ID,
        H.AVATAR_PATH
    FROM TRANSACTION_REPORT A
    LEFT JOIN WSTE_CODE B ON A.WSTE_CODE = B.CODE
    LEFT JOIN WSTE_TRMT_METHOD C ON A.TRMT_METHOD = C.CODE
    LEFT JOIN SITE_WSTE_DISPOSAL_ORDER D ON A.DISPOSER_ORDER_ID = D.ID
    LEFT JOIN V_TRANSACTION_STATE_NAME E ON A.TRANSACTION_ID = E.TRANSACTION_ID
    LEFT JOIN USERS F ON A.COLLECTOR_SITE_ID = F.AFFILIATED_SITE
    LEFT JOIN WSTE_APPEARANCE G ON A.WSTE_APPEARANCE = G.ID
    LEFT JOIN USERS H ON A.DISPOSER_SITE_ID = H.AFFILIATED_SITE
	WHERE 
        A.CONFIRMED_AT <= NOW() AND
        F.CLASS = 201 AND
        F.ID = IN_USER_ID AND
        F.ACTIVE = TRUE;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;   
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		DROP TABLE IF EXISTS PAST_TRANSACTIONS;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;				
    /*트랜잭션 시작*/  
     
    
	CREATE TEMPORARY TABLE IF NOT EXISTS PAST_TRANSACTIONS (
		REPORT_ID							BIGINT,   			/*수거자가 제출한 보고서 등록번호*/
		TRANSACTION_ID						BIGINT,   			/*트랜잭션 아이디*/
		WSTE_CODE							VARCHAR(8),			/*수거자가 처리완료한 폐기물 코드*/
		WSTE_NAME							VARCHAR(255),		/*수거자가 처리완료한 폐기물 이름*/
		WSTE_TRMT_METHOD					VARCHAR(30),   		/*폐기물 처리방법 이름*/
		WSTE_APPEARANCE						VARCHAR(20),   		/*폐기물 성상*/
		DISPOSER_ORDER_ID					BIGINT,				/*폐기물 배출 입찰등록번호*/
		DISPOSER_ORDER_CODE					VARCHAR(10),    	/*폐기물 배출 입찰등록코드*/
		CREATED_AT							DATETIME,    		/*수거자가 보고서를 제출한 일자*/
		CONFIRMED_AT						DATETIME,    		/*수거자가 제출한 보고서를 배출자가 확정한 일자*/
		STATE								VARCHAR(20),    	/*오더 상태*/
		STATE_CODE							INT,   				/*오더 상태 코드*/
		STATE_CATEGORY						VARCHAR(20),   		/*오더 대구분 상태*/
		STATE_CATEGORY_ID					INT,    			/*오더 대구분 상태 코드*/
		AVATAR_PATH							VARCHAR(255),		/*수거자 아바타 경로*/
        SITE_INFO							JSON
	);         
	
	OPEN TEMP_CURSOR;	
    SELECT FOUND_ROWS() into @rec_cnt;
    IF @rec_cnt > 0 THEN
		cloop: LOOP
			FETCH TEMP_CURSOR 
			INTO 
				CUR_REPORT_ID,
				CUR_TRANSACTION_ID,
				CUR_WSTE_CODE,
				CUR_WSTE_NAME,
				CUR_WSTE_TRMT_METHOD,
				CUR_WSTE_APPEARANCE,
				CUR_DISPOSER_ORDER_ID,
				CUR_DISPOSER_ORDER_CODE,
				CUR_CREATED_AT,
				CUR_CONFIRMED_AT,
				CUR_STATE,
				CUR_STATE_CODE,
				CUR_STATE_CATEGORY,
				CUR_STATE_CATEGORY_ID,
				CUR_AVATAR_PATH;
			
			SET vRowCount = vRowCount + 1;
			IF endOfRow THEN
				LEAVE cloop;
			END IF;
			
			INSERT INTO 
			PAST_TRANSACTIONS(
				REPORT_ID,
				TRANSACTION_ID,
				WSTE_CODE,
				WSTE_NAME,
				WSTE_TRMT_METHOD,
				WSTE_APPEARANCE,
				DISPOSER_ORDER_ID,
				DISPOSER_ORDER_CODE,
				CREATED_AT,
				CONFIRMED_AT,
				STATE,
				STATE_CODE,
				STATE_CATEGORY,
				STATE_CATEGORY_ID,
				AVATAR_PATH
			)
			VALUES(
				CUR_REPORT_ID,
				CUR_TRANSACTION_ID,
				CUR_WSTE_CODE,
				CUR_WSTE_NAME,
				CUR_WSTE_TRMT_METHOD,
				CUR_WSTE_APPEARANCE,
				CUR_DISPOSER_ORDER_ID,
				CUR_DISPOSER_ORDER_CODE,
				CUR_CREATED_AT,
				CUR_CONFIRMED_AT,
				CUR_STATE,
				CUR_STATE_CODE,
				CUR_STATE_CATEGORY,
				CUR_STATE_CATEGORY_ID,
				CUR_AVATAR_PATH
			);
            
            SELECT SITE_ID INTO @SITE_ID
            FROM SITE_WSTE_DISPOSAL_ORDER
            WHERE ID = CUR_DISPOSER_ORDER_ID;
            
            IF @SITE_ID = 0 THEN
				SET @SITE_INFO = NULL;
            ELSE
				CALL sp_get_site_info_simple(
					@SITE_ID,
					@SITE_INFO
				);
            END IF;
            
			UPDATE PAST_TRANSACTIONS
			SET SITE_INFO = @SITE_INFO
			WHERE REPORT_ID = CUR_REPORT_ID;
			
		END LOOP;   
		CLOSE TEMP_CURSOR;
		
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'REPORT_ID'						, REPORT_ID, 
				'TRANSACTION_ID'				, TRANSACTION_ID, 
				'WSTE_CODE'						, WSTE_CODE, 				
				'WSTE_NAME'						, WSTE_NAME, 
				'WSTE_TRMT_METHOD'				, WSTE_TRMT_METHOD, 
				'WSTE_APPEARANCE'				, WSTE_APPEARANCE, 
				'DISPOSER_ORDER_ID'				, DISPOSER_ORDER_ID, 				
				'DISPOSER_ORDER_CODE'			, DISPOSER_ORDER_CODE, 
				'CREATED_AT'					, CREATED_AT, 
				'CONFIRMED_AT'					, CONFIRMED_AT, 
				'STATE'							, STATE, 
				'STATE_CODE'					, STATE_CODE, 
				'STATE_CATEGORY'				, STATE_CATEGORY, 
				'STATE_CATEGORY_ID'				, STATE_CATEGORY_ID, 
				'AVATAR_PATH'					, AVATAR_PATH, 
				'SITE_INFO'						, SITE_INFO
			)
		) 
		INTO @json_data 
		FROM PAST_TRANSACTIONS;
		
		SET @rtn_val = 0;
		SET @msg_txt = 'Success1';
    ELSE
		SET @json_data = NULL;
		SET @rtn_val = 37301;
		SET @msg_txt = 'No data found';
    END IF;
    DROP TABLE IF EXISTS PAST_TRANSACTIONS;
	COMMIT;     
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END