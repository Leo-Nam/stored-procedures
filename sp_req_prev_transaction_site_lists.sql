CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_prev_transaction_site_lists`(
	IN IN_USER_ID			BIGINT,				/*입력값 : 사용자 등록번호(USERS.ID)*/
	IN IN_WSTE_CODE			VARCHAR(8),			/*입력값 : 폐기물등록코드(WSTE_CODE.CODE)*/
	IN IN_KIKCD_B_CODE		VARCHAR(10)			/*입력값 : 주소코드(KIKCD_B.B_CODE)*/
)
BEGIN

/*
Procedure Name 	: sp_req_prev_transaction_site_lists
Input param 	: 3개
Job 			: 이전거래 이력이 있는 사이트를 반환한다.
Update 			: 2022.01.30
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 					INT DEFAULT 0;
    DECLARE endOfRow 					TINYINT DEFAULT FALSE;    
    DECLARE CUR_COLLECTOR_SITE_ID		BIGINT;
    DECLARE CUR_COLLECTOR_SITE_NM		VARCHAR(255);
    DECLARE TEMP_CURSOR		 			CURSOR FOR 
	SELECT COLLECTOR_SITE_ID, COLLECTOR_SITE_NM
    FROM V_PREV_TRANSACTION_SITES
	WHERE 
		DISPOSER_SITE_ID IS NOT NULL AND 
        DISPOSER_SITE_ID IN (SELECT AFFILIATED_SITE FROM USERS WHERE ID = IN_USER_ID AND ACTIVE = TRUE) AND
        COLLECTOR_SITE_ID IN (SELECT COLLECTOR_SITE_ID FROM V_WSTE_CLCT_TRMT_TRANSACTION WHERE WSTE_CLASS = IN_WSTE_CODE);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS CURRENT_STATE (
		COLLECTOR_SITE_ID				BIGINT,
		COLLECTOR_SITE_NM				VARCHAR(255),
		WSTE_NM							JSON
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_COLLECTOR_SITE_ID,
			CUR_COLLECTOR_SITE_NM;   
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		CURRENT_STATE(
			COLLECTOR_SITE_ID, 
			COLLECTOR_SITE_NM
		)
		VALUES(
			CUR_COLLECTOR_SITE_ID, 
			CUR_COLLECTOR_SITE_NM
		);
        
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'WSTE_NM'			, WSTE_NM, 
                'APR'				, WSTE_APPEARANCE_NM_KO, 
                'QTY'				, WSTE_QUANTITY, 
                'UNIT'				, WSTE_UNIT, 
                'UNIT_PRICE'		, WSTE_UNIT_PRICE, 
                'DC_AT'				, WSTE_DISCHARGED_AT
			)
		) 
        INTO @WSTE_CLASS_NM 
        FROM V_WSTE_LIST_DISCHARGED 
        WHERE COLLECTOR_SITE_ID = CUR_COLLECTOR_SITE_ID;
		/*처리된 폐기물 종류를 JSON형태로 변환한다.*/
		
		UPDATE CURRENT_STATE 
        SET WSTE_NM 				= @WSTE_CLASS_NM 
        WHERE COLLECTOR_SITE_ID 	= CUR_COLLECTOR_SITE_ID;
		/*위에서 받아온 JSON 타입 데이타를 비롯한 몇가지의 데이타를 NEW_COMING 테이블에 반영한다.*/
		
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
    
    IF vRowCount - 1 = 0 THEN
		SET @rtn_val 				= 29701;
		SET @msg_txt 				= 'No data found';
		SET @json_data 				= NULL;
    ELSE
		SET @rtn_val 				= 0;
		SET @msg_txt 				= 'Success';	
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'COLLECTOR_SITE_ID'	, COLLECTOR_SITE_ID, 
				'COLLECTOR_SITE_NM'	, COLLECTOR_SITE_NM,
				'WSTE_NM'			, WSTE_NM  
			)
		) 
		INTO @json_data 
		FROM CURRENT_STATE;
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);   
	DROP TABLE IF EXISTS CURRENT_STATE;
END