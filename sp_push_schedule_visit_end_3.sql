CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_schedule_visit_end_3`(
	IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_push_schedule_visit_end_3
Input param 	: 1개
Output param 	: 1개
Job 			: 방문마감 하루전 푸시 반환
Update 			: 2022.04.23
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_ORDER_ID						BIGINT;    
    DECLARE CUR_ORDER_CODE						VARCHAR(10);  
    DECLARE TEMP_CURSOR		 					CURSOR FOR 
	SELECT 
		A.ID,
        A.ORDER_CODE
    FROM SITE_WSTE_DISPOSAL_ORDER A 
	LEFT JOIN V_ORDER_STATE B ON A.ID = B.DISPOSER_ORDER_ID
	LEFT JOIN V_TRANSACTION_STATE C ON A.TRANSACTION_ID = C.TRANSACTION_ID
    LEFT JOIN WSTE_CLCT_TRMT_TRANSACTION D ON A.TRANSACTION_ID = D.ID
    LEFT JOIN COMP_SITE E ON A.SITE_ID = E.ID
	WHERE 
		IF(A.COLLECTOR_ID IS NULL,
			IF(B.STATE_CODE = 102,
				A.VISIT_END_AT <= DATE_ADD(NOW(), INTERVAL 1 DAY) AND
				A.ACTIVE = TRUE AND
                E.ACTIVE = TRUE,
				A.ID = 0
			),
			IF(C.TRANSACTION_STATE_CODE = 201,
				D.VISIT_END_AT <= DATE_ADD(NOW(), INTERVAL 1 DAY) AND
				D.IN_PROGRESS = TRUE AND
                E.ACTIVE = TRUE,
				A.ID = 0
			)
		) AND
		A.ID						NOT IN (SELECT ORDER_ID FROM PUSH_HISTORY WHERE CATEGORY_ID = IN_CATEGORY_ID);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS PUSH_SCHEDULE_VISIT_END_TEMP (
		ORDER_ID						BIGINT,
		DISPOSER_INFO					JSON,
		COLLECTOR_INFO					JSON
        
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		SET @DISPOSER_INFO = NULL;
		SET @COLLECTOR_INFO = NULL; 
		
		FETCH TEMP_CURSOR 
		INTO 
			CUR_ORDER_ID,
			CUR_ORDER_CODE;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		PUSH_SCHEDULE_VISIT_END_TEMP(
			ORDER_ID
		)
		VALUES(
			CUR_ORDER_ID
		);
		
		SET @TITLE = CONCAT('[', CUR_ORDER_CODE,']방문마감 1일전');
		SET @BODY = '방문마감이 1일 남았습니다.';
        CALL sp_get_disposer_list_for_push(
			CUR_ORDER_ID,
			@TITLE,
			@BODY,
			IN_CATEGORY_ID,
            @DISPOSER_INFO,
            rtn_val,
            msg_txt
        );
        IF rtn_val = 0 THEN
			SET @TITLE = CONCAT('[', CUR_ORDER_CODE,']방문마감 1일전');
			SET @BODY = '방문마감이 1일 남았습니다.';
			CALL sp_get_collector_list_for_push(
				CUR_ORDER_ID,
				@TITLE,
				@BODY,
				IN_CATEGORY_ID,
				@COLLECTOR_INFO,
				rtn_val,
				msg_txt
			);
			IF rtn_val = 0 THEN
				UPDATE PUSH_SCHEDULE_VISIT_END_TEMP 
				SET 
					DISPOSER_INFO 			= @DISPOSER_INFO,
					COLLECTOR_INFO 			= @COLLECTOR_INFO
				WHERE ORDER_ID 				= CUR_ORDER_ID;
            ELSE
				LEAVE cloop;
            END IF;
        ELSE
			LEAVE cloop;
        END IF;
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'ORDER_ID'					, ORDER_ID, 
		'DISPOSER_INFO'				, DISPOSER_INFO, 
		'COLLECTOR_INFO'			, COLLECTOR_INFO
	)) 
	INTO OUT_TARGET_LIST FROM PUSH_SCHEDULE_VISIT_END_TEMP;
	
	SET rtn_val = 0;
	SET msg_txt = 'Success';
	DROP TABLE IF EXISTS PUSH_SCHEDULE_VISIT_END_TEMP;
END