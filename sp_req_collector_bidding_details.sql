CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_collector_bidding_details`(
	IN IN_COLLECTOR_BIDDING_ID				BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_collector_bidding_details
Input param 	: 1개
Job 			: 수거자의 개별 입찰건에 대한 상세정보 보기
Update 			: 2022.02.10
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 					INT DEFAULT 0;
    DECLARE endOfRow 					TINYINT DEFAULT FALSE;    
    DECLARE CUR_COLLECTOR_BIDDING_ID	BIGINT;
    DECLARE CUR_DISPOSER_ORDER_ID		BIGINT;
    DECLARE CUR_DISPOSER_ORDER_CODE		VARCHAR(10);
    DECLARE CUR_DATE 					DATETIME;	
    DECLARE CUR_STATE					VARCHAR(20);
    DECLARE CUR_STATE_CODE				INT;
    DECLARE TEMP_CURSOR		 			CURSOR FOR 
	SELECT 
		COLLECTOR_BIDDING_ID, 
        DISPOSER_ORDER_ID, 
        DISPOSER_ORDER_CODE, 
		IF (STATE = '삭제', DISPOSER_ORDER_DELETED_AT, 
			IF (STATE = '방문거절', DISPOSER_RESPONSE_VISIT_AT, 
				IF (STATE = '방문대기중', DISPOSER_VISIT_END_AT, 
					IF (STATE = '방문조기마감', DISPOSER_VISIT_EARLY_CLOSED_AT, 
						IF (STATE = '방문포기', COLLECTOR_RECORD_UPDATED_AT, 
							IF (STATE = '입찰중', DISPOSER_BIDDING_END_AT, 
								IF (STATE = '입찰대기중', DISPOSER_BIDDING_END_AT, 
									IF (STATE = '입찰포기', COLLECTOR_RECORD_UPDATED_AT, 
										IF (STATE = '선정중', DISPOSER_BIDDING_END_AT, 
											IF (STATE = '선정대기중', DISPOSER_BIDDING_END_AT, 
												IF (STATE = '낙찰포기', COLLECTOR_REJECTED_AT, 
													IF (STATE = '낙찰', COLLECTOR_RECORD_UPDATED_AT, 
														IF (STATE = '유찰', DISPOSER_BIDDING_END_AT, 
															DISPOSER_BIDDING_END_AT
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		), 
        STATE, 
        STATE_CODE
    FROM V_COLLECTOR_BIDDING_WITH_STATE
	WHERE COLLECTOR_BIDDING_ID = IN_COLLECTOR_BIDDING_ID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS CURRENT_STATE (
		COLLECTOR_BIDDING_ID			BIGINT,
		DISPOSER_ORDER_ID				BIGINT,
		ORDER_CODE						VARCHAR(10),
		IMG_PATH						JSON,
		WSTE_BIDDING_LIST				JSON,
		WSTE_DISPOSAL_LIST				JSON,
		CREATED_AT						DATETIME,
		STATE							VARCHAR(20),
		STATE_CODE						INT
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_COLLECTOR_BIDDING_ID,
			CUR_DISPOSER_ORDER_ID,
			CUR_DISPOSER_ORDER_CODE,
			CUR_DATE,
			CUR_STATE,
			CUR_STATE_CODE;   
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		CURRENT_STATE(
			COLLECTOR_BIDDING_ID, 
			DISPOSER_ORDER_ID, 
			ORDER_CODE, 
			CREATED_AT, 
			STATE, 
			STATE_CODE
		)
		VALUES(
			CUR_COLLECTOR_BIDDING_ID, 
			CUR_DISPOSER_ORDER_ID, 
			CUR_DISPOSER_ORDER_CODE, 
			CUR_DATE, 
			CUR_STATE, 
			CUR_STATE_CODE
		);
        
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'ID'							, ID, 
            'DISPOSAL_ORDER_ID'				, DISPOSAL_ORDER_ID, 
            'COLLECTOR_BIDDING_ID'			, COLLECTOR_BIDDING_ID, 
            'WSTE_NM'						, WSTE_NM, 
            'WSTE_CODE'						, WSTE_CODE, 
            'UNIT'							, UNIT, 
            'UNIT_PRICE'					, UNIT_PRICE, 
            'VOLUME'						, VOLUME, 
            'TRMT_METHOD_CODE'				, TRMT_METHOD_CODE, 
            'TRMT_METHOD_NM'				, TRMT_METHOD_NM, 
            'ACTIVE'						, ACTIVE, 
            'GREENHOUSE_GAS'				, GREENHOUSE_GAS, 
            'CREATED_AT'					, CREATED_AT
		)) 
        INTO @WSTE_BIDDING_LIST 
        FROM V_BIDDING_DETAILS 
        WHERE DISPOSAL_ORDER_ID = CUR_DISPOSER_ORDER_ID;
		/*DISPOSAL_ORDER_ID에 등록된 폐기물 종류 중 하나만 불러온다.*/
        
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'CLASS'				, WSTE_CLASS_NM, 
            'APR'				, WSTE_APPEARANCE_NM
		)) 
        INTO @WSTE_DISPOSAL_LIST 
        FROM V_WSTE_DISCHARGED_FROM_SITE 
        WHERE DISPOSAL_ORDER_ID = CUR_DISPOSER_ORDER_ID;
		/*DISPOSAL_ORDER_ID에 등록된 폐기물 종류 중 하나만 불러온다.*/
		
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'ID'				, ID, 
            'PATH'				, IMG_PATH
		)) 
        INTO @IMG_PATH 
        FROM WSTE_REGISTRATION_PHOTO 
        WHERE DISPOSAL_ORDER_ID = CUR_DISPOSER_ORDER_ID;
		/*DISPOSAL_ORDER_ID에 해당하는 이미지에 대한 저장경로를 JSON 형태로 받아온다.*/
		
		UPDATE CURRENT_STATE 
        SET 
			IMG_PATH 			= @IMG_PATH, 
            WSTE_BIDDING_LIST 	= @WSTE_BIDDING_LIST , 
            WSTE_DISPOSAL_LIST 	= @WSTE_DISPOSAL_LIST 
        WHERE DISPOSER_ORDER_ID = CUR_DISPOSER_ORDER_ID;
		/*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/
		
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'COLLECTOR_BIDDING_ID'	, COLLECTOR_BIDDING_ID, 
        'DISPOSER_ORDER_ID'		, DISPOSER_ORDER_ID, 
        'ORDER_CODE'			, ORDER_CODE, 
        'CREATED_AT'			, CREATED_AT, 
        'STATE'					, STATE, 
        'STATE_CODE'			, STATE_CODE, 
        'IMG_PATH'				, IMG_PATH, 
        'WSTE_BIDDING_LIST'		, WSTE_BIDDING_LIST, 
        'WSTE_DISPOSAL_LIST'	, WSTE_DISPOSAL_LIST
	)) 
    INTO @json_data 
    FROM CURRENT_STATE;
    
    IF vRowCount = 0 THEN
		SET @rtn_val = 27901;
		SET @msg_txt = 'No data found';
    ELSE
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
	DROP TABLE IF EXISTS CURRENT_STATE;
END