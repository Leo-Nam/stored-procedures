CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_my_registered_site_lists_without_handler`(
	IN IN_USER_ID							BIGINT,
	IN IN_USER_TYPE							INT,
    IN IN_OFFSET_SIZE						INT,
    IN IN_PAGE_SIZE							INT,
    OUT rtn_val								INT,
    OUT msg_txt								VARCHAR(200),
    OUT OUT_LISTS							JSON
)
BEGIN

/*
Procedure Name 	: sp_retrieve_my_registered_site_lists_without_handler
Input param 	: 1개
Job 			: 배출자가 등록한 사이트 및 수거자를 등록한 배출자 사이트의 리스트를 반환한다.
Update 			: 2022.05.13
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_USER_ID 						BIGINT;
    DECLARE CUR_SITE_ID 						BIGINT;
    DECLARE CUR_OPPONENT_ID 					BIGINT;
    DECLARE CUR_CREATED_AT 						DATETIME;
    DECLARE CUR_UPDATED_AT 						DATETIME;
    DECLARE CUR_DELETED_AT 						DATETIME;
    DECLARE CUR_ACTIVE 							TINYINT;
    DECLARE CUR_CONFIRMED 						TINYINT;
    DECLARE CUR_CONFIRMED_AT					DATETIME;
    DECLARE CUR_DELETED2_AT						DATETIME;
    DECLARE REGISTERED_SITE_CURSOR 				CURSOR FOR 
	SELECT 
		A.USER_ID,
		IF(IN_USER_TYPE = 2, A.SITE_ID, A.TARGET_ID),
		IF(IN_USER_TYPE = 2, A.TARGET_ID, IF(A.SITE_ID = 0, A.USER_ID, A.SITE_ID)),
		A.CREATED_AT,
		A.UPDATED_AT,
		A.DELETED_AT,
		A.ACTIVE,
		A.DELETED2_AT 
    FROM REGISTERED_SITE A 
    LEFT JOIN COMP_SITE B ON IF(IN_USER_TYPE = 2, A.SITE_ID = B.ID, A.TARGET_ID = B.ID)
    LEFT JOIN USERS C ON B.ID = C.AFFILIATED_SITE
    WHERE C.ID = IN_USER_ID
	LIMIT IN_OFFSET_SIZE, IN_PAGE_SIZE;  
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
        
	CREATE TEMPORARY TABLE IF NOT EXISTS MY_REGISTERED_SITE_LISTS_TEMP (
		SITE_ID							BIGINT,
		OPPONENT_ID						BIGINT,
		OPPONENT_SITE_NAME				VARCHAR(255),
		CREATED_AT						DATETIME,
		UPDATED_AT						DATETIME,
		DELETED_AT						DATETIME,
		ACTIVE							TINYINT,
		DELETED2_AT						DATETIME
	);
    
	OPEN REGISTERED_SITE_CURSOR;	
	cloop: LOOP
		FETCH REGISTERED_SITE_CURSOR 
        INTO 
			CUR_USER_ID,
			CUR_SITE_ID,
			CUR_OPPONENT_ID,
			CUR_CREATED_AT,
			CUR_UPDATED_AT,
			CUR_DELETED_AT,
			CUR_ACTIVE,
			CUR_DELETED2_AT;
        
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
		INSERT INTO 
        MY_REGISTERED_SITE_LISTS_TEMP(
			SITE_ID,
			OPPONENT_ID,
			CREATED_AT,
			UPDATED_AT,
			DELETED_AT,
			ACTIVE,
			DELETED2_AT
		)
        VALUES(
			CUR_SITE_ID,
			CUR_OPPONENT_ID,
			CUR_CREATED_AT,
			CUR_UPDATED_AT,
			CUR_DELETED_AT,
			CUR_ACTIVE,
			CUR_DELETED2_AT
		);
        
        IF IN_USER_TYPE = 2 THEN
        /*자료를 요청하는 자가 배출자인 경우*/
			SELECT SITE_NAME INTO @OPPONENT_SITE_NAME
            FROM COMP_SITE
            WHERE ID = CUR_OPPONENT_ID;
        ELSE
        /*자료를 요청하는 자가 배출자가 아닌 경우*/
			IF CUR_OPPONENT_ID = 0 THEN
			/*자료를 요청하는 자가 배출자인 경우*/
				SELECT USER_NAME INTO @OPPONENT_SITE_NAME
				FROM USERS
				WHERE ID = CUR_USER_ID;
			ELSE
			/*자료를 요청하는 자가 배출자가 아닌 경우*/
				SELECT SITE_NAME INTO @OPPONENT_SITE_NAME
				FROM COMP_SITE
				WHERE ID = CUR_OPPONENT_ID;
			END IF;
        END IF;
        
		UPDATE MY_REGISTERED_SITE_LISTS_TEMP 
        SET 
			OPPONENT_SITE_NAME 		= @OPPONENT_SITE_NAME
		WHERE SITE_ID = CUR_SITE_ID AND USER_ID = CUR_USER_ID AND OPPONENT_ID = CUR_OPPONENT_ID;
        /*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/        
        
	END LOOP;   
	CLOSE REGISTERED_SITE_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
            'SITE_ID'				, SITE_ID, 
            'OPPONENT_ID'			, OPPONENT_ID, 
            'OPPONENT_SITE_NAME'	, OPPONENT_SITE_NAME,
            'CREATED_AT'			, CREATED_AT, 
            'UPDATED_AT'			, UPDATED_AT, 
            'DELETED_AT'			, DELETED_AT, 
            'ACTIVE'				, ACTIVE, 
            'DELETED2_AT'			, DELETED2_AT
		)
	) 
    INTO OUT_LISTS 
    FROM MY_REGISTERED_SITE_LISTS_TEMP;
    
	SET rtn_val = 0;
	SET msg_txt = 'Success11';
    DROP TABLE IF EXISTS MY_REGISTERED_SITE_LISTS_TEMP;
END