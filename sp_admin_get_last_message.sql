CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_get_last_message`(
	IN IN_USER_ID				BIGINT,
	IN IN_LIST					VARCHAR(255),
    OUT OUT_LAST_MESSAGES		JSON
)
BEGIN

/*
Procedure Name 	: sp_admin_get_last_message
Input param 	: 1개
Output param 	: 1개
Job 			: 파라미터로 받은 리스트 안에 있는 아이템의 갯수를 반환한다.
Update 			: 2022.01.10
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	SET @IN_ARRAY = IN_LIST;
    SET @ITEM = NULL;
    SET @SEPERATOR = ',' COLLATE utf8mb4_unicode_ci;
    /*리스트의 아이템을 분리하는 식별자로서 comma(,)를 사용하는 것으로 정의함. 식별자는 언제든지 변경가능함*/
    SET @INVALID_COUNT = 0;
    CALL sp_req_current_time(@REG_DT);
    
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_GET_LAST_MESSAGE_TEMP (
		ROOM_ID						BIGINT,
		CHAT_ID						BIGINT,
		UNREAD						INT,
		MESSAGE						VARCHAR(255)
	);     
    
    SET @COUNT_OF_LIST_ADDED = 0;
    IF @IN_ARRAY IS NULL OR @IN_ARRAY = '' THEN
		SET @LIST_COUNT = 0;
    ELSE
		SET @LIST_COUNT = 1;
		WHILE (LOCATE(@SEPERATOR, @IN_ARRAY) > 0) DO
			SET @ITEM = SUBSTRING(@IN_ARRAY, 1, LOCATE(@SEPERATOR, @IN_ARRAY) - 1);
			SET @IN_ARRAY = SUBSTRING(@IN_ARRAY, LOCATE(@SEPERATOR, @IN_ARRAY) + 1);  
			SET @ROOM_ID = @ITEM;
            
			SELECT ID, MESSAGE 
			INTO @CHAT_ID, @MESSAGE 
			FROM CHATS 
            WHERE ROOM_ID = @ROOM_ID 
            ORDER BY ID DESC 
            LIMIT 0, 1;
            
            SELECT COUNT(ID) INTO @UNREAD
            FROM CHATS
            WHERE 
				ROOM_ID = @ROOM_ID AND
                USER_ID <> IN_USER_ID AND
                IS_READ = FALSE;
            
            INSERT INTO ADMIN_GET_LAST_MESSAGE_TEMP (
				ROOM_ID,
				CHAT_ID,
				UNREAD,
                MESSAGE
            ) VALUES (
				@ROOM_ID,
				@CHAT_ID,
				@UNREAD,
                @MESSAGE
            );
		END WHILE;
            
		SELECT ID, MESSAGE 
        INTO @CHAT_ID, @MESSAGE 
		FROM CHATS 
		WHERE ROOM_ID = @IN_ARRAY 
		ORDER BY ID DESC 
		LIMIT 0, 1;
            
		SELECT COUNT(ID) INTO @UNREAD
		FROM CHATS
		WHERE 
			ROOM_ID = @IN_ARRAY AND
			USER_ID <> IN_USER_ID AND
			IS_READ = FALSE;
        
		INSERT INTO ADMIN_GET_LAST_MESSAGE_TEMP (
			ROOM_ID,
			CHAT_ID,
			UNREAD,
			MESSAGE
		) VALUES (
			@IN_ARRAY,
			@CHAT_ID,
			@UNREAD,
			@MESSAGE
		);
    END IF;
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'ROOM_ID'				, ROOM_ID, 
        'CHAT_ID'				, CHAT_ID, 
        'UNREAD'				, UNREAD, 
        'MESSAGE'				, MESSAGE
	)) 
    INTO OUT_LAST_MESSAGES 
    FROM ADMIN_GET_LAST_MESSAGE_TEMP;
	DROP TABLE IF EXISTS ADMIN_GET_LAST_MESSAGE_TEMP;
END