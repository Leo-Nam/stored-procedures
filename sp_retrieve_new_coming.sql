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

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_DISPOSER_ORDER_ID 				BIGINT;
    DECLARE CUR_DISPOSER_ORDER_CODE 			VARCHAR(10);
    DECLARE CUR_DISPOSER_VISIT_START_AT			DATETIME;	
    DECLARE CUR_DISPOSER_VISIT_END_AT			DATETIME;	
    DECLARE CUR_DISPOSER_BIDDING_END_AT			DATETIME;	
    DECLARE CUR_WSTE_DISPOSED_KIKCD_B_CODE		VARCHAR(10);	
    DECLARE CUR_WSTE_DISPOSED_ADDR				VARCHAR(255);	
    DECLARE CUR_DISPOSER_CREATED_AT				DATETIME;	
    DECLARE CUR_WSTE_DISPOSED_SI_DO				VARCHAR(20);	
    DECLARE CUR_WSTE_DISPOSED_SI_GUN_GU			VARCHAR(20);	
    DECLARE CUR_WSTE_DISPOSED_EUP_MYEON_DONG	VARCHAR(20);	
    DECLARE CUR_WSTE_DISPOSED_DONG_RI			VARCHAR(20);	
    DECLARE CUR_STATE							VARCHAR(20);	
    DECLARE CUR_STATE_CODE						INT;		
    DECLARE CUR_STATE_CATEGORY					VARCHAR(20);	
    DECLARE CUR_STATE_CATEGORY_ID				INT;	
    DECLARE CUR_STATE_PID						INT;	
    DECLARE WSTE_CODE_CURSOR 					CURSOR FOR 
	SELECT 
		A.ID, 
        A.ORDER_CODE, 
        A.VISIT_START_AT,
        A.VISIT_END_AT,
        A.BIDDING_END_AT,
        A.KIKCD_B_CODE,
        A.ADDR,
        A.CREATED_AT,
        B.SI_DO,
        B.SI_GUN_GU,
        B.EUP_MYEON_DONG,
        B.DONG_RI,
        C.STATE,
        C.STATE_CODE,
        C.STATE_CATEGORY,
        C.STATE_CATEGORY_ID,
        C.PID
    FROM SITE_WSTE_DISPOSAL_ORDER A 
    LEFT JOIN KIKCD_B B ON A.KIKCD_B_CODE = B.B_CODE
    LEFT JOIN V_ORDER_STATE_NAME C ON A.ID = C.DISPOSER_ORDER_ID
    LEFT JOIN COMP_SITE D ON A.SITE_ID = D.ID
    LEFT JOIN COMPANY E ON D.COMP_ID = E.ID
    WHERE 
		(A.COLLECTOR_ID IS NULL OR A.COLLECTOR_ID = 0) AND 				/*0.0.2에서 새롭게 추가한 부분*/
        D.ACTIVE = TRUE AND
        E.ACTIVE = TRUE AND
        IF(A.VISIT_END_AT IS NOT NULL, 
			A.VISIT_END_AT >= NOW(), 
            A.BIDDING_END_AT >= NOW()
        ) AND 
        C.STATE_CODE = 102 AND 
        (
			A.VISIT_END_AT IS NOT NULL AND A.ID NOT IN (
				SELECT DISPOSAL_ORDER_ID 
				FROM COLLECTOR_BIDDING SUB1_A
				LEFT JOIN COMP_SITE SUB1_B ON SUB1_A.COLLECTOR_ID = SUB1_B.ID
				LEFT JOIN USERS SUB1_C ON SUB1_B.ID = SUB1_C.AFFILIATED_SITE
				WHERE 
					SUB1_A.DATE_OF_VISIT IS NOT NULL AND
					SUB1_C.ID = IN_USER_ID
			) OR
			A.VISIT_END_AT IS NULL AND A.ID NOT IN (
				SELECT DISPOSAL_ORDER_ID 
				FROM COLLECTOR_BIDDING SUB1_A
				LEFT JOIN COMP_SITE SUB1_B ON SUB1_A.COLLECTOR_ID = SUB1_B.ID
				LEFT JOIN USERS SUB1_C ON SUB1_B.ID = SUB1_C.AFFILIATED_SITE
				WHERE 
					SUB1_A.DATE_OF_BIDDING IS NOT NULL AND
					SUB1_C.ID = IN_USER_ID
			)
        ) AND
		LEFT(A.KIKCD_B_CODE, 5) IN (
			SELECT LEFT(SUB2_A.KIKCD_B_CODE, 5) 
			FROM BUSINESS_AREA SUB2_A 
			LEFT JOIN USERS SUB2_B ON SUB2_A.SITE_ID = SUB2_B.AFFILIATED_SITE 
			WHERE 
				SUB2_B.ID = IN_USER_ID AND
                SUB2_A.ACTIVE = TRUE
		);  
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
        
	CREATE TEMPORARY TABLE IF NOT EXISTS NEW_COMING (
		DISPOSER_ORDER_ID				BIGINT,
		DISPOSER_ORDER_CODE				VARCHAR(10),
        VISIT_START_AT					DATETIME,
        VISIT_END_AT					DATETIME,
        BIDDING_END_AT					DATETIME,
        WSTE_B_CODE						VARCHAR(10),
        WSTE_ADDR						VARCHAR(255),
        CREATED_AT						DATETIME,
        WSTE_SI_DO						VARCHAR(20),
        WSTE_SI_GUN_GU					VARCHAR(20),
        WSTE_EUP_MYEON_DONG				VARCHAR(20),
        WSTE_DONG_RI					VARCHAR(20),
		STATE							VARCHAR(20),	
		STATE_CODE						INT,		
		STATE_CATEGORY					VARCHAR(20),
		STATE_CATEGORY_ID				INT,
		STATE_PID						INT,	
		IMG_LIST						JSON,
		WSTE_LIST						JSON
	);
    
	OPEN WSTE_CODE_CURSOR;	
	cloop: LOOP
		FETCH WSTE_CODE_CURSOR 
        INTO  
			CUR_DISPOSER_ORDER_ID,
			CUR_DISPOSER_ORDER_CODE,
			CUR_DISPOSER_VISIT_START_AT,
			CUR_DISPOSER_VISIT_END_AT,
			CUR_DISPOSER_BIDDING_END_AT,
			CUR_WSTE_DISPOSED_KIKCD_B_CODE,
			CUR_WSTE_DISPOSED_ADDR,
			CUR_DISPOSER_CREATED_AT,
			CUR_WSTE_DISPOSED_SI_DO,
			CUR_WSTE_DISPOSED_SI_GUN_GU,
			CUR_WSTE_DISPOSED_EUP_MYEON_DONG,
			CUR_WSTE_DISPOSED_DONG_RI,
			CUR_STATE,
			CUR_STATE_CODE,
			CUR_STATE_CATEGORY,
			CUR_STATE_CATEGORY_ID,
			CUR_STATE_PID;
        
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
		INSERT INTO 
        NEW_COMING(
			DISPOSER_ORDER_ID, 
            DISPOSER_ORDER_CODE, 
            VISIT_START_AT, 
            VISIT_END_AT, 
            BIDDING_END_AT, 
            WSTE_B_CODE, 
            WSTE_ADDR, 
            CREATED_AT, 
            WSTE_SI_DO, 
            WSTE_SI_GUN_GU, 
            WSTE_EUP_MYEON_DONG, 
            WSTE_DONG_RI,
			STATE,
			STATE_CODE,
			STATE_CATEGORY,
			STATE_CATEGORY_ID,
			STATE_PID
		)
        VALUES(
			CUR_DISPOSER_ORDER_ID,
			CUR_DISPOSER_ORDER_CODE,
			CUR_DISPOSER_VISIT_START_AT,
			CUR_DISPOSER_VISIT_END_AT,
			CUR_DISPOSER_BIDDING_END_AT,
			CUR_WSTE_DISPOSED_KIKCD_B_CODE,
			CUR_WSTE_DISPOSED_ADDR,
			CUR_DISPOSER_CREATED_AT,
			CUR_WSTE_DISPOSED_SI_DO,
			CUR_WSTE_DISPOSED_SI_GUN_GU,
			CUR_WSTE_DISPOSED_EUP_MYEON_DONG,
			CUR_WSTE_DISPOSED_DONG_RI,
			CUR_STATE,
			CUR_STATE_CODE,
			CUR_STATE_CATEGORY,
			CUR_STATE_CATEGORY_ID,
			CUR_STATE_PID
		);
        
        CALL sp_get_disposal_wste_lists(
			CUR_DISPOSER_ORDER_ID,
            @WSTE_LIST
        );
        
        CALL sp_get_disposal_img_lists(
			CUR_DISPOSER_ORDER_ID,
            '입찰',
            @IMG_LIST
        );
        
		UPDATE NEW_COMING 
        SET 
			IMG_LIST 			= @IMG_LIST, 
            WSTE_LIST 			= @WSTE_LIST 
		WHERE DISPOSER_ORDER_ID = CUR_DISPOSER_ORDER_ID;
        /*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/        
        
	END LOOP;   
	CLOSE WSTE_CODE_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'DISPOSER_ORDER_ID'			, DISPOSER_ORDER_ID, 
            'DISPOSER_ORDER_CODE'		, DISPOSER_ORDER_CODE, 
            'VISIT_START_AT'			, VISIT_START_AT, 
            'VISIT_END_AT'				, VISIT_END_AT, 
            'BIDDING_END_AT'			, BIDDING_END_AT, 
            'WSTE_B_CODE'				, WSTE_B_CODE, 
            'WSTE_ADDR'					, WSTE_ADDR, 
            'CREATED_AT'				, CREATED_AT, 
            'WSTE_SI_DO'				, WSTE_SI_DO, 
            'WSTE_SI_GUN_GU'			, WSTE_SI_GUN_GU, 
            'WSTE_EUP_MYEON_DONG'		, WSTE_EUP_MYEON_DONG, 
            'WSTE_DONG_RI'				, WSTE_DONG_RI, 
            'STATE'						, STATE, 
            'STATE_CODE'				, STATE_CODE, 
            'STATE_CATEGORY'			, STATE_CATEGORY, 
            'STATE_CATEGORY_ID'			, STATE_CATEGORY_ID, 
            'STATE_PID'					, STATE_PID, 
            'IMG_LIST'					, IMG_LIST, 
            'WSTE_LIST'					, WSTE_LIST
		)
	) 
    INTO @json_data 
    FROM NEW_COMING;
    
	SET @rtn_val = 0;
	SET @msg_txt = 'Success11';
/*    IF vRowCount = 0 THEN
		SET @rtn_val = 28601;
		SET @msg_txt = 'No data found';
		SIGNAL SQLSTATE '23000';
    ELSE
		SET @rtn_val = 0;
		SET @msg_txt = 'Success11';
    END IF;*/
    DROP TABLE IF EXISTS NEW_COMING;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END