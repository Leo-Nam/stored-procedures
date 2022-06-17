CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_insert_multiple_chat`(
    IN IN_PARAMS					JSON,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN
    
	SELECT USER_ID, ROOM_ID, MESSAGE_LIST COLLATE utf8mb4_unicode_ci, IS_READ, MEDIA
    INTO @USER_ID, @ROOM_ID, @MESSAGE_LIST, @IS_READ, @MEDIA
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID",
		ROOM_ID 				INT 				PATH "$.ROOM_ID",
		MESSAGE 				VARCHAR(255) 		PATH "$.MESSAGE",
		IS_READ 				VARCHAR(255) 		PATH "$.IS_READ",
		MEDIA	 				TINYINT		 		PATH "$.MEDIA"
	)) AS PARAMS;

    CALL sp_req_current_time(@CREATED_AT);
    
    INSERT INTO CHATS(USER_ID, ROOM_ID, MESSAGE, CREATED_AT, IS_READ, MEDIA)
    VALUES(@USER_ID, @ROOM_ID, @MESSAGE, @CREATED_AT, @IS_READ, @MEDIA);
    
    SET @MESSAGE = NULL;
    SET @SEPERATOR = ',' COLLATE utf8mb4_unicode_ci;
    /*리스트의 아이템을 분리하는 식별자로서 comma(,)를 사용하는 것으로 정의함. 식별자는 언제든지 변경가능함*/
    
	SET rtn_val = 0;
	SET msg_txt = 'success';
    
    IF @MESSAGE_LIST IS NULL OR @MESSAGE_LIST = '' THEN
		SET @json_data = IN_PARAMS;
    ELSE
		SET @json_data = IN_PARAMS;
		WHILE (LOCATE(@SEPERATOR, @MESSAGE_LIST) > 0) DO
			SET @MESSAGE = SUBSTRING(@MESSAGE_LIST, 1, LOCATE(@SEPERATOR, @MESSAGE_LIST) - 1);
			SET @MESSAGE_LIST = SUBSTRING(@MESSAGE_LIST, LOCATE(@SEPERATOR, @MESSAGE_LIST) + 1);  
            
			INSERT INTO CHATS(USER_ID, ROOM_ID, MESSAGE, CREATED_AT, IS_READ, MEDIA)
			VALUES(@USER_ID, @ROOM_ID, @MESSAGE, @CREATED_AT, @IS_READ, @MEDIA);
            
            IF ROW_COUNT() = 0 THEN
				SET rtn_val = 100402;
				SET msg_txt = 'failed to insert a message';
            END IF;
		END WHILE;
            
		INSERT INTO CHATS(USER_ID, ROOM_ID, MESSAGE, CREATED_AT, IS_READ, MEDIA)
		VALUES(@USER_ID, @ROOM_ID, @MESSAGE_LIST, @CREATED_AT, @IS_READ, @MEDIA);
        
		IF ROW_COUNT() = 0 THEN
			SET rtn_val = 100401;
			SET msg_txt = 'failed to insert a message';
		END IF;
    END IF;  
END