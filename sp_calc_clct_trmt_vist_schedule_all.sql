CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_clct_trmt_vist_schedule_all`(
)
BEGIN

    DECLARE vRowCount 						INT DEFAULT 0;
    DECLARE endOfRow 						TINYINT DEFAULT FALSE;      
    DECLARE CUR_ID		 					BIGINT;       
    DECLARE CUR_VISIT_START_AT				DATETIME;      
    DECLARE CUR_VISIT_END_AT				DATETIME;    
    DECLARE TEMP_CURSOR 					CURSOR FOR 
    SELECT 
		ID,
        VISIT_START_AT,
        VISIT_END_AT
	FROM SITE_WSTE_DISPOSAL_ORDER;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;  
    
    UPDATE WSTE_CLCT_TRMT_TRANSACTION 
	SET 
		VISIT_START_AT = NULL, 
		VISIT_END_AT = NULL; 
	
	OPEN TEMP_CURSOR;	
    CALL sp_req_current_time(@REG_DT);
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_ID,
			CUR_VISIT_START_AT,
			CUR_VISIT_END_AT;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF; 
        
		UPDATE WSTE_CLCT_TRMT_TRANSACTION 
        SET 
			VISIT_START_AT = CUR_VISIT_START_AT, 
            VISIT_END_AT = CUR_VISIT_END_AT 
        WHERE DISPOSAL_ORDER_ID = CUR_ID;

	END LOOP;   
	CLOSE TEMP_CURSOR;
    
END