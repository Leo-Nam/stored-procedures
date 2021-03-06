CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_disposer_response_visit_1`(
	IN IN_USER_ID					BIGINT,
	IN IN_ORDER_ID					BIGINT,
	IN IN_BIDDING_ID				BIGINT,
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
		SELECT B.ORDER_CODE, A.COLLECTOR_ID, A.RESPONSE_VISIT
        INTO @ORDER_CODE, @COLLECTOR_SITE_ID, @RESPONSE_VISIT
        FROM COLLECTOR_BIDDING A
        LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID
        WHERE
			A.ID = IN_BIDDING_ID;
		IF @RESPONSE_VISIT = TRUE THEN
			SET @STR_RESPONSE = '수락';
            SET @CATEGORY_ID = 2;
        ELSE
			SET @STR_RESPONSE = '거절';
            SET @CATEGORY_ID = 5;
        END IF;
    
		SELECT ID INTO @TRANSACTION_ID
		FROM WSTE_CLCT_TRMT_TRANSACTION
		WHERE 
			DISPOSAL_ORDER_ID = IN_ORDER_ID AND
			IN_PROGRESS = TRUE;  
            
		SET @TITLE = CONCAT('[', @ORDER_CODE, ']방문신청', @STR_RESPONSE);
		SET @BODY = CONCAT('신청하신 [', @ORDER_CODE, ']에 대한 방문신청이 ', @STR_RESPONSE, '되었습니다.');
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
				'CATEGORY_ID'			, @CATEGORY_ID,
				'CREATED_AT'			, @REG_DT
			)
		) 
		INTO @PUSH_INFO
		FROM USERS
		WHERE 
			ACTIVE 					= TRUE AND
			PUSH_ENABLED			= TRUE AND
			AFFILIATED_SITE			= @COLLECTOR_SITE_ID;
        
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