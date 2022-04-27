CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_collector_list_for_push_3`(
	IN IN_ORDER_ID					BIGINT,
    IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_get_collector_list_for_push_3
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
		SELECT COLLECTOR_ID, ORDER_CODE INTO @COLLECTOR_ID, @ORDER_CODE
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
				'TITLE'					, IF(A.BIDDING_RANK = 1, CONCAT('[', @ORDER_CODE, ']', '유찰알림'), CONCAT('[', @ORDER_CODE, ']', '낙찰알림')),
				'BODY'					, IF(A.BIDDING_RANK = 1, '해당입찰에 유찰되었습니다.', '2순위로 낙찰되었습니다.'), 
				'ORDER_ID'				, IN_ORDER_ID,
				'BIDDING_ID'			, A.ID,
				'TRANSACTION_ID'		, @TRANSACTION_ID,
				'REPORT_ID'				, @REPORT_ID,
				'CATEGORY_ID'			, IN_CATEGORY_ID,
				'CREATED_AT'			, @REG_DT
			)
		) 
		INTO @PUSH_INFO
		FROM COLLECTOR_BIDDING A 
		LEFT JOIN USERS B ON A.COLLECTOR_ID = B.AFFILIATED_SITE
		WHERE 
			B.ACTIVE 				= TRUE AND 
			B.PUSH_ENABLED 			= TRUE AND
			A.ACTIVE 				= TRUE AND
			A.DELETED 				= FALSE AND
			A.RESPONSE_VISIT 		= TRUE AND
			A.CANCEL_VISIT 			= FALSE AND
			A.REJECT_BIDDING_APPLY 	= FALSE AND
			A.GIVEUP_BIDDING 		= FALSE AND
			A.CANCEL_BIDDING 		= FALSE AND
			A.REJECT_BIDDING 		= FALSE AND
			A.BIDDING_VISIBLE 		= TRUE AND
			A.ORDER_VISIBLE 		= TRUE AND
			A.DISPOSAL_ORDER_ID 	= IN_ORDER_ID AND
			(A.BIDDING_RANK <= 2);
        
        CALL sp_insert_push(
			0,
			@PUSH_INFO,
			rtn_val,
			msg_txt
        );
            
		SET OUT_TARGET_LIST = @PUSH_INFO;
    ELSE
		SET rtn_val = 38901;
        SET msg_txt = 'order does not exist';
		SET OUT_TARGET_LIST = NULL;
    END IF;
END