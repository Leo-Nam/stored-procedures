CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_chat_room`(
	IN IN_USER_ID				BIGINT,
    IN IN_ORDER_ID				BIGINT,
    IN IN_BIDDING_ID			BIGINT,
    IN IN_CONFIRMED				TINYINT,
    IN IN_STATE					INT,
    OUT rtn_val					INT,
    OUT msg_txt					VARCHAR(200)
)
BEGIN
    CALL sp_req_current_time(@REG_DT);
    
    SELECT DISPOSER_ID INTO @DISPOSER_USER_ID
    FROM SITE_WSTE_DISPOSAL_ORDER
    WHERE ID = IN_ORDER_ID;
    
    SELECT COUNT(ID) INTO @CHAT_ROOM_EXISTS
    FROM CHAT_ROOMS
    WHERE
		ORDER_ID = IN_ORDER_ID AND
        BIDDING_ID = IN_BIDDING_ID AND
        STATE = IN_STATE;
	
    IF @CHAT_ROOM_EXISTS = 0 THEN
		INSERT INTO CHAT_ROOMS(
			ORDER_ID,
			BIDDING_ID,
			DISPOSER_USER_ID,
			COLLECTOR_USER_ID,
            CONFIRMED,
            STATE,
            CONFIRMED_AT,
            UPDATED_AT,
			CREATED_AT
		) VALUES(
			IN_ORDER_ID,
			IN_BIDDING_ID,
			@DISPOSER_USER_ID,
			IN_USER_ID,
			IN_CONFIRMED,
			IN_STATE,
            IF(CONFIRMED = TRUE,
				@REG_DT,
                NULL
            ),
            IF(CONFIRMED = TRUE,
				@REG_DT,
                NULL
            ),
			@REG_DT
		);
		IF ROW_COUNT() = 1 THEN
			SET rtn_val = 0;
			SET msg_txt = 'success';
		ELSE
			SET rtn_val = 40102;
			SET msg_txt = 'failed to create a chat room';
		END IF;
    ELSE
		SET rtn_val = 40101;
		SET msg_txt = 'chat room already exists';
    END IF;
END