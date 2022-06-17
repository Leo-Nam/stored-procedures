CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_disposer_close_bidding_early`(
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
        
		CALL sp_req_policy_direction(
			'max_selection_duration',
			@max_selection_duration
		);
    
		SELECT ID INTO @TRANSACTION_ID
		FROM WSTE_CLCT_TRMT_TRANSACTION
		WHERE 
			DISPOSAL_ORDER_ID = IN_ORDER_ID AND
			IN_PROGRESS = TRUE;  
		
		SET @TITLE = CONCAT('[', @ORDER_CODE, ']입찰조기마감');
		SET @BODY = CONCAT('신청하신 [', @ORDER_CODE, ']의 입찰이 조기마감되어 입찰자 선정이 시작되었습니다. 선정은 ', CAST(@max_selection_duration AS UNSIGNED)*2, '시간 이내에 완료됩니다.');
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'USER_ID'				, A.ID, 
				'USER_NAME'				, A.USER_NAME, 
				'FCM'					, A.FCM, 
				'AVATAR_PATH'			, A.AVATAR_PATH,
				'TITLE'					, @TITLE,
				'BODY'					, @BODY,
				'ORDER_ID'				, IN_ORDER_ID, 
				'BIDDING_ID'			, B.ID, 
				'TRANSACTION_ID'		, @TRANSACTION_ID, 
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
            B.REJECT_BIDDING_APPLY	= FALSE AND
            B.GIVEUP_BIDDING		= FALSE AND
            B.CANCEL_BIDDING		= FALSE AND
            B.REJECT_BIDDING		= FALSE;
        
        CALL sp_insert_push(
			IN_USER_ID,
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
		SET rtn_val = 0;
        SET msg_txt = 'success1';
    ELSE
		SET rtn_val = 0;
        SET msg_txt = 'success2';
		SET OUT_TARGET_LIST = NULL;
    END IF;
END