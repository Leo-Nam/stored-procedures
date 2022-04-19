CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_new_visitor_come`(
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
		SELECT ORDER_CODE, DISPOSER_ID, SITE_ID
        INTO @ORDER_CODE, @DISPOSER_ID, @DISPOSER_SITE_ID
        FROM SITE_WSTE_DISPOSAL_ORDER
        WHERE
			ID = IN_ORDER_ID AND
			ACTIVE = TRUE;
		SET @TITLE = CONCAT('[', @ORDER_CODE, ']방문신청');
		SET @BODY = CONCAT('신청하신 [', @ORDER_CODE, ']에 대하여 방문신청이 도달하였습니다.');
        IF @DISPOSER_SITE_ID = 0 THEN
			SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'USER_ID'				, ID, 
					'USER_NAME'				, USER_NAME, 
					'FCM'					, FCM, 
					'AVATAR_PATH'			, @AVATAR_PATH,
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
			FROM USERS 
			WHERE 
				ACTIVE 					= TRUE AND
				PUSH_ENABLED			= TRUE AND
                ID						= @DISPOSER_ID;
        ELSE
			SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'USER_ID'				, A.ID, 
					'USER_NAME'				, A.USER_NAME, 
					'FCM'					, A.FCM, 
					'AVATAR_PATH'			, @AVATAR_PATH,
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
			LEFT JOIN COMP_SITE B ON A.AFFILIATED_SITE = B.ID
			WHERE 
				A.ACTIVE 					= TRUE AND
				A.PUSH_ENABLED				= TRUE AND
				B.ACTIVE 					= TRUE AND
				A.AFFILIATED_SITE			= @DISPOSER_SITE_ID;
        END IF;
        
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