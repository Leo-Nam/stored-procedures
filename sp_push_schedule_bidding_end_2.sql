CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_schedule_bidding_end_2`(
	IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val17					INT,
    OUT msg_txt17					VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_push_schedule_bidding_end_2
Input param 	: 1개
Output param 	: 1개
Job 			: 입찰마감 1시간 전 푸시알림
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
    LEFT JOIN COMP_SITE C ON A.SITE_ID = C.ID
	WHERE 
		IF(B.STATE_CODE = 103,
			A.BIDDING_END_AT <= ADDTIME(NOW(), '1:00:00') AND
			IF(A.SITE_ID = 0,
				A.DISPOSER_ID IN (SELECT ID FROM USERS WHERE ACTIVE = TRUE AND PUSH_ENABLED = TRUE AND AFFILIATED_SITE = A.SITE_ID),
                C.ACTIVE = TRUE
			) AND
            A.ACTIVE = TRUE,
			A.ID = 0
		) AND
		A.ID						NOT IN (SELECT ORDER_ID FROM PUSH_HISTORY WHERE CATEGORY_ID = IN_CATEGORY_ID);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS PUSH_SCHEDULE_BIDDING_END_2_TEMP (
		ORDER_ID						BIGINT,
		PUSH_INFO						JSON
        
	);        
	SET OUT_TARGET_LIST = NULL;
	SET rtn_val17 = NULL;
	SET msg_txt17 = NULL;
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
		PUSH_SCHEDULE_BIDDING_END_2_TEMP(
			ORDER_ID
		)
		VALUES(
			CUR_ORDER_ID
		);
		
		SET @TITLE = CONCAT('[', CUR_ORDER_CODE,']입찰마감 1시간전');
		SET @BODY = '입찰마감시간 1시간 남았습니다.';
		SET @TITLE = @TITLE;
		SET @BODY = @BODY;
        CALL sp_get_member_list_for_push_2(
			CUR_ORDER_ID,
			@TITLE,
			@BODY,
			@TITLE_2,
			@BODY_2,
			IN_CATEGORY_ID,
            OUT_TARGET_LIST,
            rtn_val17,
            msg_txt17
        );
        /*
		SET @TITLE = CONCAT('[', CUR_ORDER_CODE,']입찰마감 1시간전');
		SET @BODY = '입찰마감시간 1시간 남았습니다.';
		CALL sp_get_collector_list_for_push(
			CUR_ORDER_ID,
			@TITLE,
			@BODY,
			IN_CATEGORY_ID,
			@COLLECTOR_INFO,
			rtn_val17,
			msg_txt17
		);
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'DISPOSER_INFO'				, @DISPOSER_INFO, 
			'COLLECTOR_INFO'			, @COLLECTOR_INFO
		)) 
		INTO @PUSH_INFO;
		UPDATE PUSH_SCHEDULE_BIDDING_END_2_TEMP SET PUSH_INFO = @PUSH_INFO WHERE ORDER_ID = CUR_ORDER_ID;
        */
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
	/*
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'ORDER_ID'					, ORDER_ID, 
		'PUSH_INFO'					, PUSH_INFO
	)) 
	INTO OUT_TARGET_LIST FROM PUSH_SCHEDULE_BIDDING_END_2_TEMP;
	*/
    /*
	SET rtn_val17 = 0;
	SET msg_txt17 = 'Success-17';
    */
	DROP TABLE IF EXISTS PUSH_SCHEDULE_BIDDING_END_2_TEMP;
END