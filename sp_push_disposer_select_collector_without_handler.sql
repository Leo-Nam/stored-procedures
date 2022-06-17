CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_disposer_select_collector_without_handler`(
	IN IN_USER_ID					BIGINT,
	IN IN_ORDER_ID					BIGINT,
	IN IN_BIDDING_ID				BIGINT,
	IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val 					INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN
	
	SET rtn_val = NULL;
    SET msg_txt = NULL;
	SELECT COUNT(ID) 
    INTO @BIDDING_EXISTS
    FROM COLLECTOR_BIDDING
    WHERE 
		ID = IN_BIDDING_ID AND
        DELETED = FALSE AND
        ACTIVE = TRUE;
        
    IF @BIDDING_EXISTS = 1 THEN
		SELECT B.ORDER_CODE, A.COLLECTOR_ID
        INTO @ORDER_CODE, @COLLECTOR_SITE_ID
        FROM COLLECTOR_BIDDING A
        LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID
        WHERE
			A.ID = IN_BIDDING_ID;
    
		SELECT ID INTO @TRANSACTION_ID
		FROM WSTE_CLCT_TRMT_TRANSACTION
		WHERE 
			DISPOSAL_ORDER_ID = IN_ORDER_ID AND
			IN_PROGRESS = TRUE;  
            
		SET @TITLE = CONCAT('[', @ORDER_CODE, ']낙찰자선정');
		SET @BODY = CONCAT('신청하신 [', @ORDER_CODE, ']의 입찰에 낙찰되셨습니다. 상세 내용을 확인해주세요.');
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
			AFFILIATED_SITE			= @COLLECTOR_SITE_ID;
        
        CALL sp_insert_push(
			IN_USER_ID,
			@PUSH_INFO,
			@rtn_val,
			@msg_txt
        );
		SET rtn_val = @rtn_val;
		SET msg_txt = @msg_txt;
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
        SET msg_txt = 'success-sp_push_disposer_select_collector';
		SET OUT_TARGET_LIST = NULL;
    END IF;
END