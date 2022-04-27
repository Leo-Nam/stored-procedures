CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_last_bidder_set_bidding_end_date_now_for_cancel`(
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
		SELECT DATE_OF_BIDDING INTO @ALREADY_BID
        FROM COLLECTOR_BIDDING
        WHERE ID = IN_COLLECTOR_BIDDING_ID;
        IF @ALREADY_BID IS NOT NULL THEN
        /*이미 입찰한 사람인 경우*/
			SET rtn_val = 0;
			SET msg_txt = 'success';
        ELSE
        /*아직 입찰하지 않은 사람인 경우*/
			CALL sp_set_bidding_end_at(
				IN_DISPOSER_ORDER_ID,
				IN_COLLECTOR_BIDDING_ID,
				@REG_DT,
				rtn_val,
				msg_txt
			);
        END IF;
    ELSE
		SET rtn_val = 39101;
		SET msg_txt = 'order does not exist';
    END IF;


END