CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_update_site_wste_info`(
    IN IN_SITE_ID					BIGINT,
    IN IN_PARAMS					JSON,
	OUT rtn_val						INT,						/*출력값 : 처리결과 반환값*/
	OUT msg_txt 					VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN
    
    DECLARE vRowCount INT DEFAULT 0;
    DECLARE endOfRow TINYINT DEFAULT FALSE;
    
    DECLARE CUR_WSTE_CODE 				VARCHAR(8);
    DECLARE CUR_WSTE_APPEARANCE	 		INT;    
    DECLARE WSTE_CURSOR CURSOR FOR 
	SELECT 
        WSTE_CODE, 
        WSTE_APPEARANCE
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		WSTE_CODE 				VARCHAR(8)			PATH "$.WSTE_CODE",
		WSTE_APPEARANCE			INT					PATH "$.APPR_CODE"
	)) AS WSTE_LIST;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
        
	CALL sp_req_current_time(@REG_DT);
    SELECT COUNT(ID) INTO @WSTE_COUNT
    FROM WSTE_SITE_MATCH
    WHERE 
		SITE_ID = IN_SITE_ID AND
        ACTIVE = TRUE;
	
	UPDATE WSTE_SITE_MATCH 
	SET 
		DELETED_AT = @REG_DT,
		UPDATED_AT = @REG_DT,
		ACTIVE = FALSE
	WHERE SITE_ID = IN_SITE_ID;
	SET @DELETED_COUNT = ROW_COUNT();
    
	OPEN WSTE_CURSOR;	
	cloop: LOOP
		FETCH WSTE_CURSOR 
		INTO 
			CUR_WSTE_CODE,
			CUR_WSTE_APPEARANCE;   
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			SET rtn_val = 0;
			SET msg_txt = 'Success5';
			LEAVE cloop;
		END IF;
		
		CALL sp_check_if_wste_code_valid(
			CUR_WSTE_CODE,
			@WSTE_CODE_VALID
		);
		
		IF @WSTE_CODE_VALID = 1 THEN
			INSERT INTO 
			WSTE_SITE_MATCH(
				SITE_ID,
				WSTE_CODE,
				WSTE_APPEARANCE,
				UPDATED_AT,
				CREATED_AT
			)
			VALUES(
				IN_SITE_ID, 
				CUR_WSTE_CODE, 
				CUR_WSTE_APPEARANCE, 
				@REG_DT, 
				@REG_DT
			);	
			
			IF ROW_COUNT() = 1 THEN
				SET rtn_val = 0;
				SET msg_txt = 'Success4';
			ELSE
				SET rtn_val = 39403;
				SET msg_txt = 'Failed to save site wste information';
				LEAVE cloop;
			END IF;
		ELSE
			SET rtn_val = 39402;
			SET msg_txt = 'waste code is not valid';
			LEAVE cloop;
		END IF;
	END LOOP;   
	CLOSE WSTE_CURSOR;
    
END