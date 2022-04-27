CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_disposer_list_for_push`(
	IN IN_ORDER_ID					BIGINT,
	IN IN_TITLE						VARCHAR(255),
	IN IN_BODY						VARCHAR(255),
    IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_get_disposer_list_for_push
Input param 	: 1개
Output param 	: 1개
Job 			: 푸시를 보내기 위한 수거자 정보를 반환한다.
Update 			: 2022.04.23
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	
    CALL sp_req_current_time(@REG_DT);
	SELECT COUNT(ID) 
    INTO @ORDER_EXISTS
    FROM SITE_WSTE_DISPOSAL_ORDER
    WHERE 
		ID 				= IN_ORDER_ID AND
        IS_DELETED 		= FALSE AND
        ACTIVE		 	= TRUE;
        
    IF @ORDER_EXISTS = 1 THEN
		SELECT DISPOSER_ID, SITE_ID, ORDER_CODE INTO @DISPOSER_ID, @SITE_ID, @ORDER_CODE
        FROM SITE_WSTE_DISPOSAL_ORDER
        WHERE ID = IN_ORDER_ID;
        
		SELECT ID INTO @TRANSACTION_ID
        FROM WSTE_CLCT_TRMT_TRANSACTION
        WHERE DISPOSAL_ORDER_ID = IN_ORDER_ID;
        
        SELECT ID INTO @REPORT_ID
        FROM TRANSACTION_REPORT
        WHERE DISPOSER_ORDER_ID = IN_ORDER_ID;
        
		CALL sp_req_current_time(@REG_DT);
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'USER_ID'				, B.ID,
				'USER_NAME'				, B.USER_NAME,
				'FCM'					, B.FCM,
				'AVATAR_PATH'			, B.AVATAR_PATH,
				'TITLE'					, IN_TITLE,
				'BODY'					, IN_BODY,
				'ORDER_ID'				, IN_ORDER_ID,
				'BIDDING_ID'			, NULL,
				'TRANSACTION_ID'		, @TRANSACTION_ID,
				'REPORT_ID'				, @REPORT_ID,
				'CATEGORY_ID'			, IN_CATEGORY_ID,
				'CREATED_AT'			, @REG_DT
			)
		) 
		INTO @PUSH_INFO
		FROM SITE_WSTE_DISPOSAL_ORDER A 
		LEFT JOIN USERS B ON IF(@SITE_ID = 0, A.DISPOSER_ID = B.ID, A.SITE_ID = B.AFFILIATED_SITE)
		WHERE 
			B.ACTIVE = TRUE AND 
			B.PUSH_ENABLED = TRUE AND
			A.ACTIVE = TRUE AND
			A.IS_DELETED = FALSE AND
			A.ID = IN_ORDER_ID AND
			A.SITE_ID = @SITE_ID AND
			A.DISPOSER_ID = @DISPOSER_ID;
        
        CALL sp_insert_push(
			0,
			@PUSH_INFO,
			rtn_val,
			msg_txt
        );
            
		SET OUT_TARGET_LIST = @PUSH_INFO;
    ELSE
		SET rtn_val = 38601;
        SET msg_txt = 'order does not exist';
		SET OUT_TARGET_LIST = NULL;
    END IF;
END