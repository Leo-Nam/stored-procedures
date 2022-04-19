CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_cancel_visit`(
	IN IN_USER_ID					BIGINT,
	IN IN_COLLECTOR_BIDDING_ID		BIGINT,
    IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val 					INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_push_cancel_visit
Input param 	: 1개
Output param 	: 1개
Job 			: 수거자가 배출자가 올린 폐기물에 방문 신청을 한 후 취소 했을 경우 배출자에게 푸쉬를 발송한다1
Update 			: 2022.04.14
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	
    CALL sp_req_current_time(@REG_DT);
	SELECT COUNT(ID) 
    INTO @BIDDING_EXISTS
    FROM COLLECTOR_BIDDING
    WHERE 
		ID = IN_COLLECTOR_BIDDING_ID AND
        DELETED = FALSE AND
        CANCEL_VISIT = TRUE AND
        ACTIVE = TRUE;
        
    IF @BIDDING_EXISTS = 1 THEN
		SELECT B.ID INTO @ORDER_ID
        FROM COLLECTOR_BIDDING A
        LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID
        WHERE
			A.ID = IN_COLLECTOR_BIDDING_ID;    
            
		SET @TITLE = CONCAT('[', @ORDER_CODE, ']방문취소');
		SET @BODY = CONCAT('신청하신 [', @ORDER_CODE, ']에 ',  @COLLECTOR_SITE_NAME,'님이 방문을 취소하셨습니다.');
        IF @DISPOSER_SITE_ID = 0 THEN
			SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'USER_ID'				, C.ID, 
					'USER_NAME'				, C.USER_NAME, 
					'FCM'					, C.FCM, 
					'AVATAR_PATH'			, C.AVATAR_PATH,
					'TITLE'					, @TITLE,
					'BODY'					, @BODY,
					'ORDER_ID'				, @ORDER_ID, 
					'BIDDING_ID'			, IN_COLLECTOR_BIDDING_ID, 
					'TRANSACTION_ID'		, NULL, 
					'REPORT_ID'				, NULL, 
					'CATEGORY_ID'			, IN_CATEGORY_ID,
					'CRREATED_AT'			, @REG_DT
				)
			) 
			INTO @PUSH_INFO
			FROM COLLECTOR_BIDDING A 
            LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID
            LEFT JOIN USERS C ON B.DISPOSER_ID = C.ID
			WHERE 
				C.ACTIVE 					= TRUE AND
				C.PUSH_ENABLED				= TRUE AND
                A.ID						= IN_COLLECTOR_BIDDING_ID;
        ELSE
			SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'USER_ID'				, C.ID, 
					'USER_NAME'				, C.USER_NAME, 
					'FCM'					, C.FCM, 
					'AVATAR_PATH'			, C.AVATAR_PATH,
					'TITLE'					, @TITLE,
					'BODY'					, @BODY,
					'ORDER_ID'				, @ORDER_ID, 
					'BIDDING_ID'			, IN_COLLECTOR_BIDDING_ID, 
					'TRANSACTION_ID'		, NULL, 
					'REPORT_ID'				, NULL, 
					'CATEGORY_ID'			, IN_CATEGORY_ID,
					'CRREATED_AT'			, @REG_DT
				)
			) 
			INTO @PUSH_INFO
			FROM COLLECTOR_BIDDING A 
            LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID
            LEFT JOIN USERS C ON B.SITE_ID = C.AFFILIATED_SITE
			WHERE 
				C.ACTIVE 					= TRUE AND
				C.PUSH_ENABLED				= TRUE AND
                A.ID						= IN_COLLECTOR_BIDDING_ID;
        END IF;
        
        CALL sp_insert_push(
			0,
			OUT_TARGET_LIST,
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