CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_last_bidder_set_bidding_end_date_now_for_bidding`(
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
		CALL sp_set_bidding_end_at(
			IN_DISPOSER_ORDER_ID,
            IN_COLLECTOR_BIDDING_ID,
            @REG_DT,
			rtn_val,
            msg_txt
        );
    ELSE
		SET rtn_val = 38501;
		SET msg_txt = 'order does not exist';
    END IF;


END