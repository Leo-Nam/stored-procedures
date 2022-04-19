CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_disposer_close_visit_early`(
	IN IN_USER_ID					BIGINT,
	IN IN_ORDER_ID					BIGINT,
	IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val 					INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN
    CALL sp_req_current_time(@REG_DT);
	SELECT COUNT(ID) 
    INTO @ORDER_EXISTS
    FROM SITE_WSTE_DISPOSAL_ORDER
    WHERE 
		ID = IN_ORDER_ID AND
        ACTIVE = TRUE;
        
    IF @ORDER_EXISTS = 1 THEN
		SELECT ORDER_CODE
        INTO @ORDER_CODE
        FROM SITE_WSTE_DISPOSAL_ORDER
        WHERE ID = IN_ORDER_ID;
        
		SET @TITLE = CONCAT('[', @ORDER_CODE, ']방문조기마감');
		SET @BODY = CONCAT('신청하신 [', @ORDER_CODE, ']이 조기마감되어서 입찰이 시작되었습니다.');
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'USER_ID'				, A.ID, 
				'USER_NAME'				, A.USER_NAME, 
				'FCM'					, A.FCM, 
				'AVATAR_PATH'			, A.AVATAR_PATH,
				'TITLE'					, @TITLE,
				'BODY'					, @BODY,
				'ORDER_ID'				, IN_ORDER_ID, 
				'BIDDING_ID'			, NULL, 
				'TRANSACTION_ID'		, NULL, 
				'REPORT_ID'				, NULL, 
				'CATEGORY_ID'			, IN_CATEGORY_ID,
				'CREATED_AT'			, @REG_DT
			)
		) 
		INTO @PUSH_INFO
		FROM USERS A
        LEFT JOIN COLLECTOR_BIDDING B ON A.AFFILIATED_SITE = B.COLLECTOR_ID
        LEFT JOIN SITE_WSTE_DISPOSAL_ORDER C ON B.DISPOSAL_ORDER_ID = C.ID
		WHERE 
			A.ACTIVE 				= TRUE AND
			A.PUSH_ENABLED			= TRUE AND
			C.ID					= IN_ORDER_ID AND
            B.ACTIVE				= TRUE AND
            B.DELETED				= FALSE AND
            B.RESPONSE_VISIT		= TRUE AND
            B.CANCEL_VISIT			= FALSE AND
            B.REJECT_BIDDING_APPLY	= FALSE;
        
        CALL sp_insert_push(
			0,
			@PUSH_INFO,
			rtn_val,
			msg_txt
        );
    
		CREATE TEMPORARY TABLE IF NOT EXISTS PUSH_INFO_TEMP (
			PUSH_INFO						JSON
		);     
		INSERT PUSH_INFO_TEMP(PUSH_INFO) VALUES(@PUSH_INFO);
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'PUSH_INFO'			, PUSH_INFO
		)) 
		INTO OUT_TARGET_LIST
		FROM PUSH_INFO_TEMP;  
		DROP TABLE IF EXISTS PUSH_INFO_TEMP;  
    ELSE
		SET rtn_val = 0;
        SET msg_txt = 'success2';
		SET OUT_TARGET_LIST = NULL;
    END IF;
END