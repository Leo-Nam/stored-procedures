CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_collector_ask_transaction_completed`(
	IN IN_USER_ID					BIGINT,
	IN IN_ORDER_ID					BIGINT,
	IN IN_BIDDING_ID				BIGINT,
	IN IN_TRANSACTION_ID			BIGINT,
    IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val 					INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN
	
	SELECT COUNT(ID) 
    INTO @TRANSACTION_EXISTS
    FROM WSTE_CLCT_TRMT_TRANSACTION
    WHERE 
		ID = IN_TRANSACTION_ID;
        
    IF @TRANSACTION_EXISTS = 1 THEN
		SELECT B.ORDER_CODE, B.SITE_ID, B.DISPOSER_ID, IF(A.COLLECTOR_SITE_ID IS NULL, E.SITE_NAME, C.SITE_NAME)
        INTO @ORDER_CODE, @DISPOSER_SITE_ID, @DISPOSER_ID, @COLLECTOR_SITE_NAME
        FROM WSTE_CLCT_TRMT_TRANSACTION A
        LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID
        LEFT JOIN COMP_SITE C ON A.COLLECTOR_SITE_ID = C.ID
        LEFT JOIN COLLECTOR_BIDDING D ON A.COLLECTOR_BIDDING_ID = D.ID
        LEFT JOIN COMP_SITE E ON D.COLLECTOR_ID = E.ID
        WHERE
			A.ID = IN_TRANSACTION_ID;
    
		SELECT A.ID INTO @REPORT_ID
		FROM TRANSACTION_REPORT A 
        LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSER_ORDER_ID = B.ID
		WHERE 
			A.DISPOSER_ORDER_ID = IN_ORDER_ID;  
            
		SET @TITLE = CONCAT('[', @ORDER_CODE, ']폐기물처리완료');
		SET @BODY = CONCAT('신청하신 [', @ORDER_CODE, ']로 요청하신 폐기물을 ',  @COLLECTOR_SITE_NAME,'님이 처리완료하였습니다. 보고서를 확인해주세요.');
        IF @DISPOSER_SITE_ID = 0 THEN
			SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'USER_ID'				, ID, 
					'USER_NAME'				, USER_NAME, 
					'FCM'					, FCM, 
					'AVATAR_PATH'			, AVATAR_PATH,
					'TITLE'					, @TITLE,
					'BODY'					, @BODY,
					'ORDER_ID'				, IN_ORDER_ID, 
					'BIDDING_ID'			, NULL, 
					'TRANSACTION_ID'		, IN_TRANSACTION_ID, 
					'REPORT_ID'				, @REPORT_ID, 
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
					'USER_ID'				, ID, 
					'USER_NAME'				, USER_NAME, 
					'FCM'					, FCM, 
					'AVATAR_PATH'			, AVATAR_PATH,
					'TITLE'					, @TITLE,
					'BODY'					, @BODY,
					'ORDER_ID'				, IN_ORDER_ID, 
					'BIDDING_ID'			, NULL, 
					'TRANSACTION_ID'		, IN_TRANSACTION_ID, 
					'REPORT_ID'				, @REPORT_ID, 
					'CATEGORY_ID'			, IN_CATEGORY_ID,
					'CREATED_AT'			, @REG_DT
				)
			) 
			INTO @PUSH_INFO
			FROM USERS
			WHERE 
				ACTIVE 					= TRUE AND
				PUSH_ENABLED			= TRUE AND
                AFFILIATED_SITE			= @DISPOSER_SITE_ID;
        END IF;
        
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
        SET msg_txt = 'success222';
		SET OUT_TARGET_LIST = NULL;
    END IF;
END