CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_disposer_reject_bidding_apply`(
	IN IN_DISPOSER_ORDER_ID			BIGINT,
	IN IN_COLLECTOR_BIDDING_ID		BIGINT,
    OUT OUT_TARGET_LIST				JSON
)
BEGIN
	
	SELECT COUNT(ID) 
    INTO @ORDER_EXISTS
    FROM SITE_WSTE_DISPOSAL_ORDER
    WHERE 
		ID = IN_DISPOSER_ORDER_ID AND
        ACTIVE = TRUE;
        
    IF @ORDER_EXISTS = 1 THEN		
		SELECT COUNT(ID) 
		INTO @BIDDING_EXISTS
		FROM COLLECTOR_BIDDING
		WHERE 
			ID = IN_COLLECTOR_BIDDING_ID AND
			ACTIVE = TRUE AND
            REJECT_BIDDING_APPLY = FALSE;
		IF @BIDDING_EXISTS = 1 THEN
			SELECT ORDER_CODE
			INTO @ORDER_CODE
			FROM SITE_WSTE_DISPOSAL_ORDER
			WHERE ID = IN_DISPOSER_ORDER_ID;
			
			SET @MSG = CONCAT('신청하신 [', @ORDER_CODE, ']의 입찰참여가 거절되었습니다.');
			SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'USER_ID'	, A.ID, 
					'FCM'		, A.FCM,
					'MSG'		, @MSG
				)
			) 
			INTO OUT_TARGET_LIST
			FROM USERS A
			LEFT JOIN COLLECTOR_BIDDING B ON A.AFFILIATED_SITE = B.COLLECTOR_ID
			WHERE 
				A.ACTIVE 				= TRUE AND
				A.PUSH_ENABLED			= TRUE AND
				B.ID					= IN_COLLECTOR_BIDDING_ID AND
				B.ACTIVE				= TRUE AND
				B.DELETED				= FALSE AND
				B.RESPONSE_VISIT		= TRUE AND
				B.CANCEL_VISIT			= FALSE AND
				B.REJECT_BIDDING_APPLY	= FALSE;
        ELSE
			SET OUT_TARGET_LIST = NULL;
        END IF;
    ELSE
		SET OUT_TARGET_LIST = NULL;
    END IF;
END