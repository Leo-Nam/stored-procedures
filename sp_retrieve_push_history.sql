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
    DECLARE CUR_ID	 							BIGINT;  
    DECLARE CUR_TITLE 							VARCHAR(255);
    DECLARE CUR_BODY							VARCHAR(255);	
    DECLARE CUR_CATEGORY_ID						INT;	
    DECLARE CUR_AVATAR_PATH						VARCHAR(255);	
    DECLARE PUSH_HISTORY_CURSOR 				CURSOR FOR 
	SELECT 
        A.ID,
        A.TITLE,
        A.BODY,
        A.CATEGORY_ID,
        B.AVATAR_PATH
    FROM PUSH_HISTORY A
    LEFT JOIN USERS B ON A.SENDER_ID = B.ID
    WHERE A.USER_ID = IN_USER_ID
    ORDER BY A.CREATED_AT DESC
    LIMIT IN_OFFSET_SIZE, IN_PAGE_SIZE;  
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
        
	CREATE TEMPORARY TABLE IF NOT EXISTS PUSH_HISTORY_TEMP (
		HISTORY_ID	 					BIGINT,
		TITLE 							VARCHAR(255),
		BODY							VARCHAR(255),
		TARGET_URL						VARCHAR(255),
		CATEGORY_ID						INT,
		AVATAR_PATH						VARCHAR(255),
        PAYLOAD							JSON
	);
    
	OPEN PUSH_HISTORY_CURSOR;	
	cloop: LOOP
		FETCH PUSH_HISTORY_CURSOR 
        INTO  
			CUR_ID,
			CUR_TITLE,
			CUR_BODY,
			CUR_CATEGORY_ID,
			CUR_AVATAR_PATH;
        
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
		INSERT INTO 
        PUSH_HISTORY_TEMP(
			HISTORY_ID,
			TITLE,
			BODY,
			CATEGORY_ID,
			AVATAR_PATH
		)
        VALUES(
			CUR_ID,
			CUR_TITLE,
			CUR_BODY,
			CUR_CATEGORY_ID,
			CUR_AVATAR_PATH
		);
        
        CALL sp_retrieve_push_history_payload(
			CUR_ID,
            @PAYLOAD
        );
        
		UPDATE PUSH_HISTORY_TEMP 
        SET PAYLOAD = @PAYLOAD
		WHERE HISTORY_ID = CUR_ID;
        /*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 PUSH_HISTORY_TEMP 테이블에 반영한다.*/        
        
	END LOOP;   
	CLOSE PUSH_HISTORY_CURSOR;
		
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'HISTORY_ID'		, HISTORY_ID, 
			'TITLE'				, TITLE, 
			'BODY'				, BODY, 
			'CATEGORY_ID'		, CATEGORY_ID,
			'AVATAR_PATH'		, AVATAR_PATH,
			'PAYLOAD'			, PAYLOAD
		)
	) 
	INTO @json_data
    FROM PUSH_HISTORY_TEMP;  
    
	SET @rtn_val = 0;
	SET @msg_txt = 'Success111';
    DROP TABLE IF EXISTS PUSH_HISTORY_TEMP;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END