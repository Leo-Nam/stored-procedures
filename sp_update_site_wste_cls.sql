CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_site_wste_cls`(
	IN IN_SITE_ID			BIGINT,				/*입력값 : 사이트 고유등록번호*/
	IN IN_WSTE_LIST			JSON,				/*입력값 : 폐기물 구분 코드(JSON)*/
	IN IN_REG_DT			DATETIME,			/*입력값 : 입력시간*/
    OUT rtn_val				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_update_site_wste_cls
Input param 	: 3개
Output param 	: 2개
Job 			: 수거자 등의 사업자가 관리가능한 폐기물 대구분 코드(JSON)를 풀어서 개별적인 INSERT 실행
Update 			: 2022.02.11
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/
    
    DECLARE vRowCount INT DEFAULT 0;
    DECLARE endOfRow TINYINT DEFAULT FALSE;
    
    DECLARE CUR_WSTE_CODE 		VARCHAR(8);
    DECLARE CUR_WSTE_APPEARANCE INT;
    
    DECLARE WSTE_CODE_CURSOR CURSOR FOR 
	SELECT WSTE_CODE, WSTE_APPEARANCE
    FROM JSON_TABLE(IN_WSTE_LIST, "$[*]" COLUMNS(
    /*JSON 데이타에서 사용하는 KEY와 VALUE 타입*/
		WSTE_CODE		 		VARCHAR(8)						PATH "$.WSTE_CODE",
		WSTE_APPEARANCE			INT			 					PATH "$.WSTE_APPEARANCE"
	)) AS WSTE_LIST;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
	OPEN WSTE_CODE_CURSOR;	
	cloop: LOOP
		FETCH WSTE_CODE_CURSOR 
        INTO 
			CUR_WSTE_CODE,
			CUR_WSTE_APPEARANCE;   
        
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
		INSERT INTO 
        SITE_WSTE_CLS_MATCH(
			SITE_ID, 
            WSTE_CLS_CODE, 
            WSTE_APPEARANCE,
            CREATED_AT,
            UPDATED_AT
		)
        VALUES(
			IN_SITE_ID, 
            CUR_WSTE_CODE, 
            CUR_WSTE_APPEARANCE,
            IN_REG_DT, 
            IN_REG_DT
		);
        
        IF ROW_COUNT() = 0 THEN
			SET rtn_val = 22601;
			SET msg_txt = 'Failed to enter waste information';
			LEAVE cloop;
		ELSE
			SET rtn_val = 0;
			SET msg_txt = 'Success';
        END IF;
	END LOOP;   
	CLOSE WSTE_CODE_CURSOR;
END