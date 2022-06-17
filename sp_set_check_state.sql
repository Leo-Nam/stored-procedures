CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_set_check_state`(
	IN IN_ORDER_ID			BIGINT,
    IN IN_BIDDING_ID		BIGINT,
    IN IN_TRANSACTION_ID	BIGINT,
    IN IN_USER_ID			BIGINT,
    IN IN_USER_SITE_ID		BIGINT,
    IN IN_USER_TYPE			INT,
    OUT rtn_val				INT,
    OUT msg_txt				VARCHAR(200)
)
BEGIN
    
	SELECT TRANSACTION_STATE_CODE INTO @TRANSACTION_STATE
	FROM V_TRANSACTION_STATE
	WHERE DISPOSAL_ORDER_ID = IN_ORDER_ID;   
	
    SELECT COUNT(ID) INTO @CHECK_EXISTS
    FROM STATE_CONTROLLER
    WHERE
		IF(IN_USER_SITE_ID = 0,
			USER_ID = IN_USER_ID,
            SITE_ID = IN_USER_SITE_ID
        ) AND
        ORDER_ID = IN_ORDER_ID AND
        TRANSACTION_STATE = @TRANSACTION_STATE;        
	
    IF @CHECK_EXISTS = 0 THEN    
		CALL sp_req_current_time(@REG_DT);
        
        SELECT STATE_CODE INTO @ORDER_STATE
        FROM V_ORDER_STATE
        WHERE DISPOSER_ORDER_ID = IN_ORDER_ID;
        
        SELECT STATE_CODE INTO @BIDDING_STATE
        FROM V_BIDDING_STATE
        WHERE 
			DISPOER_ORDER_ID = IN_ORDER_ID AND
            COLLECTOR_ID = IN_USER_SITE_ID;
		
        
		INSERT INTO STATE_CONTROLLER(
			USER_ID,
			USER_TYPE,
			SITE_ID,
			ORDER_ID,
			ORDER_STATE,
			BIDDING_STATE,
			TRANSACTION_STATE,
			CREATED_AT
        ) VALUES(
			IN_USER_ID,
            IN_USER_TYPE,
            IN_USER_SITE_ID,
            IN_ORDER_ID,
            @ORDER_STATE,
            @BIDDING_STATE,
            @TRANSACTION_STATE,
            @REG_DT
        );
        IF ROW_COUNT() = 1 THEN
			SET rtn_val = 0;
			SET msg_txt = 'success1';
        ELSE
			SET rtn_val = 39801;
			SET msg_txt = 'failed to insert record';
        END IF;
		SET rtn_val = 0;
        SET msg_txt = 'success2';
    ELSE
		SET rtn_val = 0;
        SET msg_txt = 'success3';
    END IF;
END