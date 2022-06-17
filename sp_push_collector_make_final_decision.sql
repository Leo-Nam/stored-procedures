CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_collector_make_final_decision`(
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
    INTO @BIDDING_EXISTS
    FROM COLLECTOR_BIDDING
    WHERE 
		ID = IN_BIDDING_ID AND
        DELETED = FALSE AND
        CANCEL_VISIT = FALSE AND
        ACTIVE = TRUE;
        
    IF @BIDDING_EXISTS = 1 THEN
		SELECT B.ORDER_CODE, B.SITE_ID, B.DISPOSER_ID, C.SITE_NAME
        INTO @ORDER_CODE, @DISPOSER_SITE_ID, @DISPOSER_ID, @COLLECTOR_SITE_NAME
        FROM COLLECTOR_BIDDING A
        LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID
        LEFT JOIN COMP_SITE C ON A.COLLECTOR_ID = C.ID
        WHERE
			A.ID = IN_BIDDING_ID;
		
        IF IN_CATEGORY_ID = 23 THEN
			SET @WHAT = '승인';
        ELSE
			SET @WHAT = '거절';
        END IF;
    
		SELECT ID INTO @TRANSACTION_ID
		FROM WSTE_CLCT_TRMT_TRANSACTION
		WHERE 
			DISPOSAL_ORDER_ID = IN_ORDER_ID AND
			IN_PROGRESS = TRUE;  
            
		SET @TITLE = CONCAT('[', @ORDER_CODE, ']낙찰자선정', @WHAT);
		SET @BODY = CONCAT('신청하신 [', @ORDER_CODE, ']의 된 ',  @COLLECTOR_SITE_NAME,'님이 거래를 ',  @WHAT, '하였습니다. 확인해주세요.');
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
					'BIDDING_ID'			, IN_BIDDING_ID, 
					'TRANSACTION_ID'		, @TRANSACTION_ID, 
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
					'USER_ID'				, ID, 
					'USER_NAME'				, USER_NAME, 
					'FCM'					, FCM, 
					'AVATAR_PATH'			, AVATAR_PATH,
					'TITLE'					, @TITLE,
					'BODY'					, @BODY,
					'ORDER_ID'				, IN_ORDER_ID, 
					'BIDDING_ID'			, IN_BIDDING_ID, 
					'TRANSACTION_ID'		, @TRANSACTION_ID, 
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