CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_delete_chat_without_handler`(
    IN IN_USER_ID				BIGINT,
    IN IN_CHAT_ID				BIGINT,
    IN REG_DT					DATETIME,
    OUT rtn_val					INT,
    OUT msg_txt					VARCHAR(200)
)
BEGIN
    
	SELECT COUNT(ID) INTO @CHAT_EXISTS
    FROM CHATS
    WHERE 
		USER_ID = IN_USER_ID AND
        CHAT_ID = IN_CHAT_ID;
	
    IF @CHAT_EXISTS = 1 THEN
		UPDATE CHATS
		SET 
			DELETED = TRUE,
			DELETED_AT = REG_DT,
            UPDATED_AT = REG_DT
		WHERE 
			USER_ID = IN_USER_ID AND
			CHAT_ID = IN_CHAT_ID;
		
		IF ROW_COUST() = 1 THEN
			SET rtn_val = 0;
			SET msg_txt = 'success';
		ELSE
			SET rtn_val = 100402;
			SET msg_txt = 'failed to delete chat message';
		END IF;
    ELSE
		SET rtn_val = 100401;
		SET msg_txt = 'chat message to delete does not exist';
    END IF;
END