CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_collector_wste_lists`(
	IN IN_COLLECTOR_BIDDING_ID			BIGINT,						/*입력값 : 수거자등의 업체가 입찰 신청을 할 때 생성되는 고유등록번호(COLLECTOR_BIDDING.ID)*/
	IN IN_DISPOSER_ORDER_ID				BIGINT,						/*입력값 : 폐기물 배출 고유등록번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
	IN IN_REG_DT						DATETIME,					/*입력값 : 입력날짜*/
	IN IN_JSON_DATA						JSON,						/*입력값 : 입력 폐기물 리스트*/
	OUT rtn_val							INT,						/*출력값 : 처리결과 반환값*/
	OUT msg_txt 						VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_insert_collector_wste_lists
Input param 	: 3개
Output param 	: 2개
Job 			: 수거자 등이 입력한 입찰정보를 데이타베이스에 저장한다.
Update 			: 2022.01.20
Version			: 0.0.1
AUTHOR 			: Leo Nam
IN_JSON_DATA	: JSON 데이타에서 사용하는 KEY와 VALUE 타입
*/
    
    DECLARE vRowCount INT DEFAULT 0;
    DECLARE endOfRow TINYINT DEFAULT FALSE;
    
    DECLARE CUR_WSTE_CODE 		VARCHAR(8);
    DECLARE CUR_UNIT	 		VARCHAR(20);
    DECLARE CUR_UNIT_PRICE 		INT;
    DECLARE CUR_VOLUME	 		FLOAT;
    DECLARE CUR_TRMT_CODE 		VARCHAR(4);	
    
    DECLARE WSTE_CURSOR CURSOR FOR 
	SELECT WSTE_CODE, UNIT, UNIT_PRICE, VOLUME, TRMT_CODE
    FROM JSON_TABLE(IN_JSON_DATA, "$[*]" COLUMNS(
    /*JSON 데이타에서 사용하는 KEY와 VALUE 타입*/
		WSTE_CODE 				VARCHAR(8) 			PATH "$.WSTE_CODE",
		UNIT 					VARCHAR(20)			PATH "$.UNIT",
		UNIT_PRICE				INT					PATH "$.UNIT_PRICE",
		VOLUME					FLOAT				PATH "$.VOLUME",
		TRMT_CODE				VARCHAR(4)			PATH "$.TRMT_CODE"
	)) AS WSTE_LIST;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
        
	OPEN WSTE_CURSOR;	
	cloop: LOOP
		FETCH WSTE_CURSOR 
        INTO 
			CUR_WSTE_CODE,
			CUR_UNIT,
			CUR_UNIT_PRICE,
			CUR_VOLUME,
			CUR_TRMT_CODE;   
        
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			SET rtn_val = 0;
			SET msg_txt = 'Success5';
			LEAVE cloop;
		END IF;
        
		INSERT INTO 
        BIDDING_DETAILS(
			COLLECTOR_BIDDING_ID, 
            WSTE_CODE, 
            UNIT, 
            UNIT_PRICE, 
            VOLUME,
            TRMT_CODE,
            CREATED_AT,
            UPDATED_AT
		)
        VALUES(
			IN_COLLECTOR_BIDDING_ID, 
            CUR_WSTE_CODE, 
            CUR_UNIT, 
            CUR_UNIT_PRICE, 
            IF(CUR_VOLUME = 0, 1, CUR_VOLUME), 
            CUR_TRMT_CODE, 
            IN_REG_DT, 
            IN_REG_DT
		);	
        
        IF ROW_COUNT() = 0 THEN
			SET rtn_val = 23601;
			SET msg_txt = 'Failed to save waste bidding information';
			LEAVE cloop;
		ELSE
			SET rtn_val = 0;
			SET msg_txt = 'Success4';
        END IF;
	END LOOP;   
	CLOSE WSTE_CURSOR;
    
    IF rtn_val = 0 THEN
		SELECT SUM(UNIT_PRICE * VOLUME) INTO @BID_AMOUNT FROM BIDDING_DETAILS WHERE COLLECTOR_BIDDING_ID = IN_COLLECTOR_BIDDING_ID;
		UPDATE COLLECTOR_BIDDING SET BID_AMOUNT = @BID_AMOUNT, UPDATED_AT = IN_REG_DT WHERE ID = IN_COLLECTOR_BIDDING_ID;
		
		IF ROW_COUNT() = 0 THEN
			SET rtn_val = 23602;
			SET msg_txt = 'Failed to calculate the total estimate';
		ELSE
/*
			SELECT ID INTO @WINNER_ID 
			FROM COLLECTOR_BIDDING 
			WHERE 
				BID_AMOUNT IS NOT NULL AND 
				DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID  AND
				BID_AMOUNT 
				IN (
					SELECT MIN(BID_AMOUNT) 
					FROM COLLECTOR_BIDDING 
					WHERE 
						DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND 
						ACTIVE = TRUE AND 
						BID_AMOUNT IS NOT NULL
				);
			SELECT ID INTO @WINNER_ID FROM COLLECTOR_BIDDING WHERE DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID;
			
			UPDATE COLLECTOR_BIDDING SET WINNER = NULL, UPDATED_AT = IN_REG_DT WHERE DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND ACTIVE = TRUE;
			UPDATE COLLECTOR_BIDDING SET WINNER = TRUE, UPDATED_AT = IN_REG_DT WHERE ID = @WINNER_ID;
			IF ROW_COUNT() > 0 THEN
*/            
			/*새로운 최저입찰가를 신청한 아이디(COLLECTOR_BIDDING.ID)의 WINNER값을 TRUE로 성공적으로 변경한 경우*/
				SET rtn_val = 0;
				SET msg_txt = 'Success3';
/*                
			ELSE
*/            
			/*새로운 최저입찰가를 신청한 아이디(COLLECTOR_BIDDING.ID)의 WINNER값을 TRUE로 변경하는데 실패한 경우*/
/*            
				SET rtn_val = 23603;
				SET msg_txt = 'Failure to correct information about the new lowest bidder';
			END IF;
*/                
		END IF;
    END IF;
END