CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_latest_push_history`(
	IN IN_USER_ID							BIGINT,
    IN IN_PAGE_SIZE							INT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_latest_push_history
Input param 	: 2개
Job 			: 최근 푸시 히스토리에서 사용자가 읽지 않은 푸시가 있는 경우 TRUE, 그렇지 않은 경우 FALSE를 반환한다
Update 			: 2022.04.23
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_ID	 							BIGINT;  
    DECLARE CUR_TITLE 							VARCHAR(255);
    DECLARE CUR_BODY							VARCHAR(255);	
    DECLARE CUR_CATEGORY_ID						INT;	
    DECLARE CUR_IS_READ							TINYINT;	
    DECLARE CUR_DELETED							TINYINT;	
    DECLARE CUR_AVATAR_PATH						VARCHAR(255);	
    DECLARE PUSH_HISTORY_CURSOR 				CURSOR FOR 
	SELECT 
        ID,
        TITLE,
        BODY,
        CATEGORY_ID,
        IS_READ,
        DELETED
    FROM PUSH_HISTORY
    WHERE USER_ID = IN_USER_ID
    ORDER BY CREATED_AT DESC
    LIMIT 0, IN_PAGE_SIZE;  
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
        
	CREATE TEMPORARY TABLE IF NOT EXISTS LATEST_PUSH_HISTORY_TEMP (
		HISTORY_ID	 					BIGINT,
		TITLE 							VARCHAR(255),
		BODY							VARCHAR(255),
		TARGET_URL						VARCHAR(255),
		CATEGORY_ID						INT,
		IS_READ							TINYINT,
		DELETED							TINYINT
	);
    
	OPEN PUSH_HISTORY_CURSOR;	
	cloop: LOOP
		FETCH PUSH_HISTORY_CURSOR 
        INTO  
			CUR_ID,
			CUR_TITLE,
			CUR_BODY,
			CUR_CATEGORY_ID,
			CUR_IS_READ,
			CUR_DELETED;
        
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
		INSERT INTO 
        LATEST_PUSH_HISTORY_TEMP(
			HISTORY_ID,
			TITLE,
			BODY,
			CATEGORY_ID,
			IS_READ,
			DELETED
		)
        VALUES(
			CUR_ID,
			CUR_TITLE,
			CUR_BODY,
			CUR_CATEGORY_ID,
			CUR_IS_READ,
			CUR_DELETED
		);
        
	END LOOP;   
	CLOSE PUSH_HISTORY_CURSOR;
	SELECT COUNT(HISTORY_ID) INTO @COUNT_OF_UNREAD_HISTORY
    FROM LATEST_PUSH_HISTORY_TEMP
    WHERE 
        IS_READ = FALSE AND
        DELETED = FALSE;
    DROP TABLE IF EXISTS LATEST_PUSH_HISTORY_TEMP;
	
	IF @COUNT_OF_UNREAD_HISTORY > 0 THEN
		SET @FLAG = TRUE;
    ELSE
		SET @FLAG = FALSE;
    END IF;
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'USER_ID'			, IN_USER_ID, 
			'UNREAD_COUNT'		, @COUNT_OF_UNREAD_HISTORY, 
			'FALG'				, @FLAG
		)
	) 
	INTO @json_data;
    SET @rtn_val = 0;
    SET @msg_txt = 'success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END