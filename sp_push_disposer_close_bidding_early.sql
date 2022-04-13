CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_disposer_close_bidding_early`(
	IN IN_DISPOSER_ORDER_ID			BIGINT,
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
		SELECT ORDER_CODE
        INTO @ORDER_CODE
        FROM SITE_WSTE_DISPOSAL_ORDER
        WHERE ID = IN_DISPOSER_ORDER_ID;
        
		CALL sp_req_policy_direction(
			'max_selection_duration',
			@max_selection_duration
		);
		
		SET @MSG = CONCAT('신청하신 [', @ORDER_CODE, ']의 입찰이 조기마감되어 입찰자 선정이 시작되었습니다. 선정은 ', CAST(@max_selection_duration AS UNSIGNED)*2, '시간 이내에 완료됩니다.');
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
        LEFT JOIN SITE_WSTE_DISPOSAL_ORDER C ON B.DISPOSAL_ORDER_ID = C.ID
		WHERE 
			A.ACTIVE 				= TRUE AND
			A.PUSH_ENABLED			= TRUE AND
			C.ID					= IN_DISPOSER_ORDER_ID AND
            B.ACTIVE				= TRUE AND
            B.DELETED				= FALSE AND
            B.RESPONSE_VISIT		= TRUE AND
            B.CANCEL_VISIT			= FALSE AND
            B.REJECT_BIDDING_APPLY	= FALSE AND
            B.GIVEUP_BIDDING		= FALSE AND
            B.CANCEL_BIDDING		= FALSE AND
            B.REJECT_BIDDING		= FALSE;
    ELSE
		SET OUT_TARGET_LIST = NULL;
    END IF;
END