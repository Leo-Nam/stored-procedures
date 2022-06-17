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
    DECLARE CUR_USER_ID							BIGINT; 
    DECLARE CUR_USER_SITE_ID					BIGINT; 
    DECLARE TEMP_CURSOR		 					CURSOR FOR 
	SELECT 
		ID,
        AFFILIATED_SITE
    FROM USERS 
    WHERE ID = IN_USER_ID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS RETRIEVE_PREV_TRANSACTION_SITE_TEMP_999 (
		USER_ID							BIGINT,
		PREV_TRANSACTION_LIST			JSON,
		REGISTERED_SITE_LIST			JSON        
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		
		FETCH TEMP_CURSOR 
		INTO 
			CUR_USER_ID,
			CUR_USER_SITE_ID;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		RETRIEVE_PREV_TRANSACTION_SITE_TEMP_999(
			USER_ID
		)
		VALUES(
			CUR_USER_ID
		);
    
		CALL sp_req_registered_site_lists_without_handler(
			CUR_USER_ID,
			CUR_USER_SITE_ID,
			@rtn_val,
			@msg_txt,
			@REGISTERED_SITE_LIST
		);
    
		CALL sp_req_prev_transaction_site_lists_without_handler(
			CUR_USER_ID,
			CUR_USER_SITE_ID,
			@rtn_val,
			@msg_txt,
			@PREV_TRANSACTION_LIST
		);
		
		UPDATE RETRIEVE_PREV_TRANSACTION_SITE_TEMP_999 
        SET 
			PREV_TRANSACTION_LIST 			= @PREV_TRANSACTION_LIST, 
            REGISTERED_SITE_LIST 			= @REGISTERED_SITE_LIST
        WHERE USER_ID = CUR_USER_ID;
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'USER_ID'					, USER_ID, 
        'PREV_TRANSACTION_LIST'		, PREV_TRANSACTION_LIST, 
        'REGISTERED_SITE_LIST'		, REGISTERED_SITE_LIST
	)) 
    INTO @json_data FROM RETRIEVE_PREV_TRANSACTION_SITE_TEMP_999;
    
	DROP TABLE IF EXISTS RETRIEVE_PREV_TRANSACTION_SITE_TEMP_999;
    
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END