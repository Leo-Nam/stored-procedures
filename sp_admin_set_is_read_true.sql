CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_set_is_read_true`(
	IN IN_ROOM_ID				BIGINT,
    IN IN_USER_ID				BIGINT,
    OUT rtn_val					INT,
    OUT msg_txt					VARCHAR(200)
)
BEGIN
	SELECT COUNT(ID) INTO @RECORD_COUNT 
    FROM CHATS
    WHERE 
		USER_ID <> IN_USER_ID AND
		ROOM_ID = IN_ROOM_ID AND
        IS_READ = FALSE;
        
	IF @RECORD_COUNT > 0 THEN
		UPDATE CHATS
		SET IS_READ = TRUE
		WHERE 
			USER_ID <> IN_USER_ID AND
			ROOM_ID = IN_ROOM_ID AND
			IS_READ = FALSE;
			
		IF ROW_COUNT() > 0 THEN 
		/* 성공한 경우 */
			SET rtn_val = 0;
            SET msg_txt = 'success';
		ELSE
		/* 실패한 경우 */
			SET rtn_val = 100302;
            SET msg_txt = 'fail to update';
			
		END IF;
	ELSE
		SET rtn_val = 100301;
		SET msg_txt = 'messages has already read';
    END IF;
    
	
END