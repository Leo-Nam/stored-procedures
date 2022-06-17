CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_schedule_bidding_end_1`(
	IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val19					INT,
    OUT msg_txt19					VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_push_schedule_bidding_end_1
Input param 	: 1개
Output param 	: 1개
Job 			: 입찰마감 후 선정단계 진입시 푸시 반환함
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
		IF(B.STATE_CODE = 110,
			IF(A.SITE_ID = 0,
				A.DISPOSER_ID IN (SELECT ID FROM USERS WHERE ACTIVE = TRUE AND PUSH_ENABLED = TRUE AND AFFILIATED_SITE = A.SITE_ID),
                C.ACTIVE = TRUE
			) AND
            A.ACTIVE = TRUE,
			A.ID = 0
		) AND
		A.ID						NOT IN (SELECT ORDER_ID FROM PUSH_HISTORY WHERE CATEGORY_ID = IN_CATEGORY_ID);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS PUSH_SCHEDULE_BIDDING_END_1_TEMP (
		ORDER_ID						BIGINT,
		PUSH_INFO						JSON
        
	);        
	   
	SET OUT_TARGET_LIST = NULL;
	SET rtn_val19 = NULL;
	SET msg_txt19 = NULL;
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
		PUSH_SCHEDULE_BIDDING_END_1_TEMP(
			ORDER_ID
		)
		VALUES(
			CUR_ORDER_ID
		);
		
		SET @TITLE = CONCAT('[', CUR_ORDER_CODE,']입찰마감');
		SET @BODY = '낙찰자를 확인해 주세요';
		SET @TITLE_2 = CONCAT('[', CUR_ORDER_CODE,']입찰마감');
		SET @BODY_2 = '선정대기 해주세요';
        CALL sp_get_member_list_for_push_2(
			CUR_ORDER_ID,
			@TITLE,
			@BODY,
			@TITLE_2,
			@BODY_2,
			IN_CATEGORY_ID,
            OUT_TARGET_LIST,
            rtn_val19,
            msg_txt19
        );
	END LOOP;   
	CLOSE TEMP_CURSOR;
	SET rtn_val19 = 0;
	SET msg_txt19 = 'Success-19';
	DROP TABLE IF EXISTS PUSH_SCHEDULE_BIDDING_END_1_TEMP;
END