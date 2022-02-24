CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_new_coming`(
	IN IN_USER_ID							BIGINT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_new_coming
Input param 	: 1개
Job 			: 수거자의 사업지역의 신규입찰건에 대한 리스트를 반환한다.
Update 			: 2022.02.10
Version			: 0.0.3
AUTHOR 			: Leo Nam
Change			: 기존거래를 위한 칼럼(SITE_WSTE_DISPOSAL_ORDER.COLLECTOR_ID)을 추가함으로써 이 칼럼의 값이 NULL인 경우에만 신규입찰이 되며 NULL이 아닌것은 기존거래로서 기존 업체의 나의 활동에 자동으로 등록됨(0.0.2)
*/

    DECLARE vRowCount 					INT DEFAULT 0;
    DECLARE endOfRow 					TINYINT DEFAULT FALSE;    
    DECLARE CUR_DISPOSER_ORDER_ID 		BIGINT;
    DECLARE CUR_DISPOSER_ORDER_CODE 	VARCHAR(10);
    DECLARE CUR_DATE 					DATETIME;	
    DECLARE WSTE_CODE_CURSOR 			CURSOR FOR 
	SELECT 
		DISPOSER_ORDER_ID, 
        DISPOSER_ORDER_CODE, 
        IF(
			DISPOSER_VISIT_END_AT IS NULL, 
            DISPOSER_BIDDING_END_AT, 
            DISPOSER_VISIT_END_AT
		) AS DISPLAY_DATE
    FROM V_SITE_WSTE_DISPOSAL_ORDER
    WHERE 
		COLLECTOR_ID IS NULL AND 				/*0.0.2에서 새롭게 추가한 부분*/
		LEFT(DISPOSER_SITE_KIKCD_B_CODE, 5) IN (SELECT LEFT(A.KIKCD_B_CODE, 5) 
	FROM BUSINESS_AREA A 
    LEFT JOIN USERS B ON A.SITE_ID = B.AFFILIATED_SITE 
    WHERE B.ID = IN_USER_ID);    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
        
	CREATE TEMPORARY TABLE IF NOT EXISTS NEW_COMING (
		DISPOSAL_ORDER_ID				BIGINT,
		ORDER_CODE						VARCHAR(10),
		IMG_PATH						JSON,
		WSTE_LIST						JSON,
		DISPLAY_DATE					DATETIME
	);
    
	OPEN WSTE_CODE_CURSOR;	
	cloop: LOOP
		FETCH WSTE_CODE_CURSOR 
        INTO 
			CUR_DISPOSER_ORDER_ID,
			CUR_DISPOSER_ORDER_CODE,
			CUR_DATE;   
        
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
		INSERT INTO 
        NEW_COMING(
			DISPOSAL_ORDER_ID, 
            ORDER_CODE, 
            DISPLAY_DATE
		)
        VALUES(
			CUR_DISPOSER_ORDER_ID, 
            CUR_DISPOSER_ORDER_CODE, 
            CUR_DATE
		);
        SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'CLASS'	, WSTE_CLASS_NM, 
                'APR'	, WSTE_APPEARANCE_NM
			)
		) 
        INTO @WSTE_LIST 
        FROM V_WSTE_DISCHARGED_FROM_SITE 
        WHERE DISPOSAL_ORDER_ID = CUR_DISPOSER_ORDER_ID;
        /*DISPOSAL_ORDER_ID에 등록된 폐기물 종류 중 하나만 불러온다.*/
        
        SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'ID'	, ID, 
                'PATH'	, IMG_PATH
			)
		) 
        INTO @IMG_PATH 
        FROM WSTE_REGISTRATION_PHOTO 
        WHERE DISPOSAL_ORDER_ID = CUR_DISPOSER_ORDER_ID;
        /*DISPOSAL_ORDER_ID에 해당하는 이미지에 대한 저장경로를 JSON 형태로 받아온다.*/
        
		UPDATE NEW_COMING 
        SET 
			IMG_PATH 			= @IMG_PATH, 
            WSTE_LIST 			= @WSTE_LIST 
		WHERE DISPOSAL_ORDER_ID = CUR_DISPOSER_ORDER_ID;
        /*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/        
        
	END LOOP;   
	CLOSE WSTE_CODE_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'DISPOSAL_ORDER_ID'	, DISPOSAL_ORDER_ID, 
            'ORDER_CODE'		, ORDER_CODE, 
            'DISPLAY_DATE'		, DISPLAY_DATE
		)
	) 
    INTO @json_data 
    FROM NEW_COMING;
    
    IF vRowCount = 0 THEN
		SET @rtn_val = 28601;
		SET @msg_txt = 'No data found';
    ELSE
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
    DROP TABLE IF EXISTS NEW_COMING;
END