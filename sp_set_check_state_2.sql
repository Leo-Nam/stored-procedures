CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_set_check_state_2`(
	IN IN_ORDER_ID			BIGINT,
    IN IN_TRANSACTION_ID	BIGINT,
    IN IN_USER_ID			BIGINT,
    IN IN_USER_SITE_ID		BIGINT,
    OUT rtn_val				INT,
    OUT msg_txt				VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_set_check_state_2
Input param 	: 2개
Job 			: ...
Update 			: 2022.05.23
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
	SELECT STATE_CODE INTO @ORDER_STATE
	FROM V_ORDER_STATE
	WHERE DISPOSER_ORDER_ID = IN_ORDER_ID;  
    
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
		ORDER_STATE = @ORDER_STATE;   
	
    IF @CHECK_EXISTS = 0 THEN    
		CALL sp_req_current_time(@REG_DT);
        
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
            2,
            IN_USER_SITE_ID,
            IN_ORDER_ID,
            @ORDER_STATE,
            NULL,
            @TRANSACTION_STATE,
            @REG_DT
        );
        IF ROW_COUNT() = 1 THEN
			SET rtn_val = 0;
			SET msg_txt = 'success1';
        ELSE
			SET rtn_val = 40001;
			SET msg_txt = 'failed to insert record';
        END IF;
		SET rtn_val = 0;
        SET msg_txt = 'success2';
    ELSE
		SET rtn_val = 0;
        SET msg_txt = 'success3';
    END IF;
END