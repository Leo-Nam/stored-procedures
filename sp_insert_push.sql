CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_push`(
    IN IN_SENDER_ID				BIGINT,				/*입력값 : 발송자 아이디*/
	IN IN_JSON_DATA				JSON,				/*입력값 : 입력 폐기물 리스트*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_insert_push
Input param 	: 8개
Output param 	: 2개
Job 			: 시스템 또는 관리자에 의하여 사용자에게 발송된 푸시를 저장한다.
Update 			: 2022.04.14
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
    DECLARE vRowCount INT DEFAULT 0;
    DECLARE endOfRow TINYINT DEFAULT FALSE;
    
    DECLARE CUR_USER_ID 		BIGINT;
    DECLARE CUR_USER_NAME	 	VARCHAR(255);
    DECLARE CUR_FCM			 	VARCHAR(255);
    DECLARE CUR_AVATAR_PATH	 	VARCHAR(255);
    DECLARE CUR_TITLE		 	VARCHAR(255);
    DECLARE CUR_BODY 			VARCHAR(255);
    DECLARE CUR_ORDER_ID	 	BIGINT;
    DECLARE CUR_BIDDING_ID 		BIGINT;	
    DECLARE CUR_TRANSACTION_ID 	BIGINT;	
    DECLARE CUR_REPORT_ID 		BIGINT;	
    DECLARE CUR_CATEGORY_ID 	INT;	
    DECLARE CUR_CREATED_AT	 	DATETIME;	
    
    DECLARE PUSH_CURSOR CURSOR FOR 
	SELECT USER_ID, USER_NAME, FCM, AVATAR_PATH, TITLE, BODY, ORDER_ID, BIDDING_ID, TRANSACTION_ID, REPORT_ID, CATEGORY_ID, CREATED_AT
    FROM JSON_TABLE(IN_JSON_DATA, "$[*]" COLUMNS(
    /*JSON 데이타에서 사용하는 KEY와 VALUE 타입*/
		USER_ID 				BIGINT 			PATH "$.USER_ID",
		USER_NAME 				VARCHAR(255) 	PATH "$.USER_NAME",
		FCM 					VARCHAR(255) 	PATH "$.FCM",
		AVATAR_PATH				VARCHAR(255)	PATH "$.AVATAR_PATH",
		TITLE 					VARCHAR(255)	PATH "$.TITLE",
		BODY					VARCHAR(255)	PATH "$.BODY",
		ORDER_ID				BIGINT			PATH "$.ORDER_ID",
		BIDDING_ID				BIGINT			PATH "$.BIDDING_ID",
		TRANSACTION_ID			BIGINT			PATH "$.TRANSACTION_ID",
		REPORT_ID				BIGINT			PATH "$.REPORT_ID",
		CATEGORY_ID				INT				PATH "$.CATEGORY_ID",
		CREATED_AT				DATETIME		PATH "$.CREATED_AT"
	)) AS PUSH_INFO;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;        

	SET rtn_val = NULL;
    SET msg_txt = NULL;
    SELECT COUNT(USER_ID) INTO @RECORD_COUNT
    FROM JSON_TABLE(IN_JSON_DATA, "$[*]" COLUMNS(
    /*JSON 데이타에서 사용하는 KEY와 VALUE 타입*/
		USER_ID 				BIGINT 			PATH "$.USER_ID"
	)) AS PUSH_INFO_2;
    
    IF @RECORD_COUNT > 0 THEN
		CALL sp_req_current_time(@REG_DT);
		OPEN PUSH_CURSOR;	
		cloop: LOOP
			FETCH PUSH_CURSOR 
			INTO 
				CUR_USER_ID,
				CUR_USER_NAME,
				CUR_FCM,
				CUR_AVATAR_PATH,
				CUR_TITLE,
				CUR_BODY,
				CUR_ORDER_ID,
				CUR_BIDDING_ID,
				CUR_TRANSACTION_ID,
				CUR_REPORT_ID,
				CUR_CATEGORY_ID,
				CUR_CREATED_AT;   
			
			SET vRowCount = vRowCount + 1;
			IF endOfRow THEN
				SET rtn_val = 0;
				SET msg_txt = CONCAT('success-sp_insert_push-1:', vRowCount);
				LEAVE cloop;
			END IF;
                
			IF 
				CUR_USER_ID IS NOT NULL AND
				CUR_TITLE IS NOT NULL AND
				CUR_CREATED_AT IS NOT NULL AND
                IF(IN_SENDER_ID = 0,
					IN_SENDER_ID IS NOT NULL,
					IN_SENDER_ID IS NOT NULL AND
					CUR_ORDER_ID IS NOT NULL AND
					CUR_TRANSACTION_ID IS NOT NULL AND
					CUR_CATEGORY_ID IS NOT NULL
                )
            THEN
				INSERT INTO PUSH_HISTORY(
					USER_ID,
					TITLE,
					BODY,
					CREATED_AT,
					SENDER_ID,
					ORDER_ID,
					BIDDING_ID,
					TRANSACTION_ID,
					REPORT_ID,
					CATEGORY_ID
				) VALUES (
					CUR_USER_ID,
					CUR_TITLE,
					CUR_BODY,
					CUR_CREATED_AT,
					IN_SENDER_ID,
					CUR_ORDER_ID,
					CUR_BIDDING_ID,
					CUR_TRANSACTION_ID,
					CUR_REPORT_ID,
					CUR_CATEGORY_ID
				);
				
				IF ROW_COUNT() = 0 THEN
					SET rtn_val = 37701;
					SET msg_txt = 'Failed to insert push lists';
					LEAVE cloop;
				ELSE
					SET rtn_val = 0;
					SET msg_txt = 'Success-sp_insert_push-2';
				END IF;
            END IF;
		END LOOP;   
		CLOSE PUSH_CURSOR;
    ELSE
		SET rtn_val = 0;
		SET msg_txt = 'Success-sp_insert_push-3';
    END IF;
END