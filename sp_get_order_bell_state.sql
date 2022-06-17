CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_order_bell_state`(
	IN IN_ORDER_ID					BIGINT,
    OUT OUT_STATE					TINYINT
)
BEGIN
	SELECT COUNT(ID) INTO @RECORD_COUNT
    FROM SITE_WSTE_DISPOSAL_ORDER
    WHERE 
		ID = IN_ORDER_ID AND
        CHECK_STATE = TRUE;
        
	IF @RECORD_COUNT > 0 THEN
		SET OUT_STATE = TRUE;
    ELSE
		SET OUT_STATE = FALSE;
    END IF;
END