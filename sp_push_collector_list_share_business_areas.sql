CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_collector_list_share_business_areas`(
	IN IN_USER_ID					BIGINT,
	IN IN_ORDER_ID					BIGINT,
	IN IN_B_CODE					VARCHAR(10),
    IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val 					INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN
    CALL sp_req_current_time(@REG_DT);
	SELECT COUNT(B_CODE) INTO @BCODE_EXISTS
    FROM KIKCD_B
    WHERE 
		B_CODE = IN_B_CODE AND
        CANCELED_DATE IS NULL;
    IF @BCODE_EXISTS = 1 THEN
		SELECT SI_DO, SI_GUN_GU
        INTO @SI_DO, @SI_GUN_GU
        FROM KIKCD_B
        WHERE
			B_CODE = IN_B_CODE AND
			CANCELED_DATE IS NULL;
            
		SELECT ORDER_CODE INTO @ORDER_CODE
        FROM SITE_WSTE_DISPOSAL_ORDER
        WHERE ID = IN_ORDER_ID;
        SET @ORDER_ID = IN_ORDER_ID;  
    
		SELECT ID INTO @TRANSACTION_ID
		FROM WSTE_CLCT_TRMT_TRANSACTION
		WHERE 
			DISPOSAL_ORDER_ID = IN_ORDER_ID AND
			IN_PROGRESS = TRUE;  
    
		SET @TITLE = CONCAT('[', @ORDER_CODE, ']신규 폐기물 등록');
		SET @BODY = CONCAT(@SI_DO, ' ', @SI_GUN_GU, '에 신규 폐기물이 등록되었습니다.');
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'USER_ID'				, C.ID, 
				'USER_NAME'				, C.USER_NAME, 
				'FCM'					, C.FCM, 
				'AVATAR_PATH'			, C.AVATAR_PATH,
				'TITLE'					, @TITLE,
				'BODY'					, @BODY,
				'ORDER_ID'				, @ORDER_ID, 
				'BIDDING_ID'			, NULL, 
				'TRANSACTION_ID'		, @TRANSACTION_ID, 
				'REPORT_ID'				, NULL, 
				'CATEGORY_ID'			, IN_CATEGORY_ID,
				'CREATED_AT'			, @REG_DT
			)
		) 
		INTO @PUSH_INFO
		FROM BUSINESS_AREA A 
		LEFT JOIN COMP_SITE B ON A.SITE_ID = B.ID
		LEFT JOIN USERS C ON B.ID = C.AFFILIATED_SITE
		WHERE 
			A.ACTIVE 					= TRUE AND
			B.ACTIVE 					= TRUE AND
			C.ACTIVE	 				= TRUE AND
            C.PUSH_ENABLED				= TRUE AND
			LEFT(A.KIKCD_B_CODE, 5) 	= LEFT(IN_B_CODE, 5);
        
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