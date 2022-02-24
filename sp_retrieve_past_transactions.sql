CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_past_transactions`(
	IN IN_USER_ID							BIGINT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_past_transactions
Input param 	: 1개
Job 			: 과거 처리업체(거래내역)를 리스트한다.
Update 			: 2022.02.10
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 					INT 				DEFAULT 0;
    DECLARE endOfRow 					TINYINT 			DEFAULT FALSE;    
    DECLARE CUR_COLLECTOR_ID			BIGINT;
    DECLARE CUR_COLLECTOR_SITE_NAME		VARCHAR(255);
    DECLARE CUR_CLOSE_AT				DATETIME;	
    DECLARE CUR_WSTE_LIST				JSON;
    DECLARE TEMP_CURSOR		 			CURSOR FOR 
	SELECT 
		COLLECTOR_ID, 
        COLLECTOR_SITE_NAME, 
        DISPOSER_CLOSE_AT
    FROM V_SITE_WSTE_DISPOSAL_ORDER_WITH_STATE
	WHERE 
		DISPOSER_SITE_ID IN (
			SELECT AFFILIATED_SITE 
            FROM USERS 
            WHERE 
				ID = IN_USER_ID AND 
                ACTIVE = TRUE
		) AND
        DISPOSER_CLOSE_AT <= NOW();
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS CURRENT_STATE (
		COLLECTOR_ID					BIGINT,
		COLLECTOR_SITE_NAME				VARCHAR(255),
		DISPOSER_CLOSE_AT				DATETIME,
        WSTE_LIST						JSON
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_COLLECTOR_ID,
			CUR_COLLECTOR_SITE_NAME,
			CUR_CLOSE_AT;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		CURRENT_STATE(
			COLLECTOR_ID, 
			COLLECTOR_SITE_NAME, 
			DISPOSER_CLOSE_AT
		)
		VALUES(
			CUR_COLLECTOR_ID, 
			CUR_COLLECTOR_SITE_NAME, 
			CUR_CLOSE_AT
		);
        
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'WSTE_NM'				, WSTE_NM, 
                'QTY'					, WSTE_QUANTITY, 
                'UNIT'					, WSTE_UNIT, 
                'UNIT_PRICE'			, PRICE_UNIT
			)
		) 
        INTO @WSTE_LIST 
        FROM V_WSTE_CLCT_TRMT_TRANSACTION 
        WHERE COLLECTOR_SITE_ID = CUR_COLLECTOR_ID;
		/*처리된 폐기물 종류를 JSON형태로 변환한다.*/
		
		UPDATE CURRENT_STATE 
        SET WSTE_LIST = @WSTE_LIST 
        WHERE COLLECTOR_ID = CUR_COLLECTOR_ID;
		/*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'COLLECTOR_ID'				, COLLECTOR_ID, 
            'COLLECTOR_SITE_NAME'		, COLLECTOR_SITE_NAME, 
            'DISPOSER_CLOSE_AT'			, DISPOSER_CLOSE_AT, 
            'WSTE_LIST'					, WSTE_LIST
		)
	) 
    INTO @json_data 
    FROM CURRENT_STATE;
    
    IF vRowCount = 0 THEN
		SET @rtn_val = 28501;
		SET @msg_txt = 'No data found';
    ELSE
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
    DROP TABLE IF EXISTS NEW_COMING;
END