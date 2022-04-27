CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_set_bidding_end_at`(
	IN IN_DISPOSER_ORDER_ID			BIGINT,
    IN IN_COLLECTOR_BIDDING_ID		BIGINT,
    IN IN_REG_DT					DATETIME,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN
	SELECT PROSPECTIVE_BIDDERS INTO @PROSPECTIVE_BIDDERS
	FROM SITE_WSTE_DISPOSAL_ORDER
	WHERE ID = IN_DISPOSER_ORDER_ID;
	IF @PROSPECTIVE_BIDDERS = 1 THEN
		SELECT DISPOSAL_ORDER_ID INTO @BIDDING_ORDER_ID
		FROM COLLECTOR_BIDDING
		WHERE ID = IN_COLLECTOR_BIDDING_ID;
		IF @BIDDING_ORDER_ID = IN_DISPOSER_ORDER_ID THEN                
			UPDATE SITE_WSTE_DISPOSAL_ORDER
			SET 
				BIDDING_END_AT = IN_REG_DT,
                UPDATED_AT = IN_REG_DT
			WHERE ID = IN_DISPOSER_ORDER_ID;
			IF ROW_COUNT() = 1 THEN
				SET rtn_val = 0;
				SET msg_txt = 'success888';
			ELSE
				SET rtn_val = 39002;
				SET msg_txt = 'bidding failed to set bidding end date now';
			END IF;
		ELSE
			SET rtn_val = 39001;
			SET msg_txt = 'bidding does not belong to the order';
		END IF;
	ELSE
		SET rtn_val = 0;
		SET msg_txt = 'success999';
	END IF;
END