CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_schedule_ask_review`(
	IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val26						INT,
    OUT msg_txt26						VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_push_schedule_visit_end
Input param 	: 1개
Output param 	: 1개
Job 			: 푸시를 보낼 배출 물건은 푸시가 발송되지 않은 상태에서 해당 물건이 입찰중인 입찰건을 반환한다.
Update 			: 2022.04.23
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_ORDER_ID						BIGINT;    
    DECLARE CUR_ORDER_CODE						VARCHAR(10);  
    DECLARE CUR_COLLECTOR_SITE_ID				BIGINT;    
    DECLARE TEMP_CURSOR		 					CURSOR FOR 
	SELECT 
		A.DISPOSER_ORDER_ID,
        C.ORDER_CODE,
        A.COLLECTOR_SITE_ID
    FROM TRANSACTION_REPORT A 
    LEFT JOIN COMP_SITE B ON A.DISPOSER_SITE_ID = B.ID
    LEFT JOIN SITE_WSTE_DISPOSAL_ORDER C ON A.DISPOSER_ORDER_ID = C.ID
	WHERE 
        B.ACTIVE 									= TRUE AND
        A.CONFIRMED									= TRUE AND
        DATE_ADD(A.CONFIRMED_AT, INTERVAL 1 DAY) 	>= NOW() AND
		C.ID										NOT IN (SELECT ORDER_ID FROM PUSH_HISTORY WHERE CATEGORY_ID = IN_CATEGORY_ID);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS PUSH_SCHEDULE_ASK_REVIEW_TEMP (
		ORDER_ID						BIGINT,
		PUSH_INFO						JSON
	);        
	
	SET rtn_val26 = NULL;
	SET msg_txt26 = NULL;
	SET OUT_TARGET_LIST = NULL;
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		SET @DISPOSER_INFO = NULL;
		SET @COLLECTOR_INFO = NULL; 
		
		FETCH TEMP_CURSOR 
		INTO 
			CUR_ORDER_ID,
			CUR_ORDER_CODE,
			CUR_COLLECTOR_SITE_ID;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		PUSH_SCHEDULE_ASK_REVIEW_TEMP(
			ORDER_ID
		)
		VALUES(
			CUR_ORDER_ID
		);
		
        SELECT SITE_NAME INTO @COLLECTOR_NAME
        FROM COMP_SITE
        WHERE ID = CUR_COLLECTOR_SITE_ID;
        
		SET @TITLE = CONCAT('[', CUR_ORDER_CODE,']리뷰등록요청');
		SET @BODY = CONCAT('처리는 만족스러우셨나요? [', @COLLECTOR_NAME, ']에 대한 리뷰를 등록해 주세요.');
        CALL sp_get_disposer_list_for_push(
			CUR_ORDER_ID,
			@TITLE,
			@BODY,
			IN_CATEGORY_ID,
            OUT_TARGET_LIST,
            rtn_val26,
            msg_txt26
        );
        /*
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'DISPOSER_INFO'				, @DISPOSER_INFO, 
			'COLLECTOR_INFO'			, NULL
		)) 
		INTO @PUSH_INFO;
		UPDATE PUSH_SCHEDULE_ASK_REVIEW_TEMP SET PUSH_INFO = @PUSH_INFO WHERE ORDER_ID = CUR_ORDER_ID;
		*/
	END LOOP;   
	CLOSE TEMP_CURSOR;
	/*
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'ORDER_ID'					, ORDER_ID, 
		'PUSH_INFO'					, PUSH_INFO
	)) 
	INTO OUT_TARGET_LIST FROM PUSH_SCHEDULE_ASK_REVIEW_TEMP;
	*/
	SET rtn_val26 = 0;
	SET msg_txt26 = 'Success-26';
	DROP TABLE IF EXISTS PUSH_SCHEDULE_ASK_REVIEW_TEMP;
END