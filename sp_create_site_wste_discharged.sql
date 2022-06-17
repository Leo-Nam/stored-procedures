CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_site_wste_discharged`(
	IN IN_DISPOSER_ORDER_ID				BIGINT,						/*입력값 : SITE_WSTE_DISPOSAL_ID.ID*/
	IN REG_DT							DATETIME,					/*입력값 : 데이타 생성일시*/
	IN IN_JSON_DATA						JSON,						/*입력값 : 폐기물 등록 리스트*/
	OUT rtn_val							INT,						/*출력값 : 처리결과 코드*/
	OUT msg_txt 						VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_create_site_wste_discharged
Input param 	: 3개
Output param 	: 2개
Job 			: 배출자가 등록한 폐기물 대분류를 등록한다. 입력 데이타는 JSON(향후 1 이상의 데이타를 입력 받을 수 있으므로)으로 입력 받는다.
Update 			: 2022.01.22
Version			: 0.0.2
AUTHOR 			: Leo Nam
IN_JSON_DATA	: JSON 데이타에서 사용하는 KEY와 VALUE 타입
Change			: 입력값 IN_SITE_WSTE_REG_ID를 IN_DISPOSER_ORDER_ID로 변경함(0.0.2)
*/
    
    DECLARE vRowCount INT DEFAULT 0;
    DECLARE endOfRow TINYINT DEFAULT FALSE;
    
    DECLARE CUR_WSTE_CLASS_CODE INT;
    DECLARE CUR_WSTE_APPEARANCE INT;
    DECLARE CUR_UNIT VARCHAR(20);
    DECLARE CUR_QUANTITY FLOAT;
    
    DECLARE WSTE_CODE_CURSOR CURSOR FOR 
	SELECT WSTE_CLASS_CODE, WSTE_APPEARANCE, UNIT, QUANTITY 
    FROM JSON_TABLE(IN_JSON_DATA, "$[*]" COLUMNS(
    /*JSON 데이타에서 사용하는 KEY와 VALUE 타입*/
		WSTE_CLASS_CODE 		INT 							PATH "$.WSTE_CLASS_CODE",
		WSTE_APPEARANCE			INT			 					PATH "$.WSTE_APPEARANCE",
		UNIT 					ENUM('Kg','m³','식',"전체견적가")	PATH "$.UNIT",
		QUANTITY 				FLOAT							PATH "$.QUANTITY"
	)) AS WSTE_LIST;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
	OPEN WSTE_CODE_CURSOR;	
	cloop: LOOP
		FETCH WSTE_CODE_CURSOR 
        INTO 
			CUR_WSTE_CLASS_CODE,
			CUR_WSTE_APPEARANCE,
			CUR_UNIT,
			CUR_QUANTITY;   
        
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		SET vRowCount = vRowCount + 1;
        
		INSERT INTO 
        WSTE_DISCHARGED_FROM_SITE(
			DISPOSAL_ORDER_ID, 
            WSTE_CLASS, 
            WSTE_APPEARANCE, 
            QUANTITY, 
            UNIT,
            CREATED_AT,
            UPDATED_AT
		)
        VALUES(
			IN_DISPOSER_ORDER_ID, 
            CUR_WSTE_CLASS_CODE, 
            CUR_WSTE_APPEARANCE, 
            CUR_QUANTITY, 
            /*IF(CUR_UNIT = "전체견적가", '식', CUR_UNIT), */
            CUR_UNIT,
            REG_DT, 
            REG_DT
		);
        IF vRowCount > 0 THEN
        /*폐기물 정보가 존재하는 경우 경우*/
			IF ROW_COUNT() = 0 THEN
				SET rtn_val = 22701;
				SET msg_txt = 'Failed to enter waste information';
				LEAVE cloop;
			ELSE
				SET rtn_val = 0;
				SET msg_txt = 'Success';
			END IF;
        ELSE
        /*폐기물 정보가 없는 경우 예외처리한다.*/
			SET rtn_val = 22702;
			SET msg_txt = 'Waste information does not exist';
			LEAVE cloop;
        END IF;
	END LOOP;   
	CLOSE WSTE_CODE_CURSOR;
END