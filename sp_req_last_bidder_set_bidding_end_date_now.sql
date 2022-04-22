CREATE PROCEDURE `sp_req_last_bidder_set_bidding_end_date_now` (
	IN IN_DISPOSER_ORDER_ID			BIGINT,
    IN IN_COLLECTOR_BIDDING_ID		BIGINT,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN
    CALL sp_req_current_time(@REG_DT);
    
    SELECT COUNT(ID) INTO @ORDER_EXISTS
    FROM SITE_WSTE_DISPOSAL_ORDER
    WHERE 
		ID = IN_DISPOSER_ORDER_ID AND 
        ACTIVE = TRUE AND
        IS_DELETED = FALSE;
	IF @ORDER_EXISTS = 1 THEN
		SELECT COUNT(ID) INTO @BIDDING_EXISTS
		FROM COLLECTOR_BIDDING
		WHERE 
			ID = IN_COLLECTOR_BIDDING_ID AND 
			ACTIVE = TRUE AND
			DELETED = FALSE;
		IF @BIDDING_EXISTS = 1 THEN
			SELECT DISPOSAL_ORDER_ID INTO @BIDDING_ORDER_ID
            FROM COLLECTOR_BIDDING
            WHERE ID = IN_COLLECTOR_BIDDING_ID;
            IF @BIDDING_ORDER_ID = IN_DISPOSER_ORDER_ID THEN
				UPDATE SITE_WSTE_DISPOSAL_ORDER
				SET BIDDING_END_AT = @REG_DT
				WHERE ID = IN_DISPOSER_ORDER_ID;
                IF ROW_COUINT() = 1 THEN
					SET rtn_val = 0;
					SET msg_txt = 'success';
                ELSE
					SET rtn_val = 38504;
					SET msg_txt = 'bidding failed to set bidding end date now';
                END IF;
            ELSE
				SET rtn_val = 38503;
				SET msg_txt = 'bidding does not belong to the order';
            END IF;
        ELSE
			SET rtn_val = 38502;
			SET msg_txt = 'bidding does not exist';
        END IF;
    ELSE
		SET rtn_val = 38501;
		SET msg_txt = 'order does not exist';
    END IF;


END
