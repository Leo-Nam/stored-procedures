CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_make_decision_at_all`(
)
BEGIN

    DECLARE vRowCount 						INT DEFAULT 0;
    DECLARE endOfRow 						TINYINT DEFAULT FALSE;      
    DECLARE CUR_ID		 					BIGINT;    
    DECLARE TEMP_CURSOR 					CURSOR FOR 
    SELECT 
		ID
	FROM COLLECTOR_BIDDING;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;  
    
	CALL sp_req_policy_direction(
	/*수거자가 배출자의 최종입찰선정에 응답을 할 수 있는 최대의 시간으로서 배출자의 최종낙찰자선정일로부터의 기간을 반환받는다(단위:시간)*/
		'max_selection_duration',
		@max_selection_duration
	);
    	
	OPEN TEMP_CURSOR;	
    CALL sp_req_current_time(@REG_DT);
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_ID;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF; 
        
        SELECT COUNT(ID) INTO @rec_count FROM COLLECTOR_BIDDING WHERE DATE_OF_BIDDING IS NOT NULL AND ID = CUR_ID;
        IF @rec_count = 1 THEN
			SELECT B.BIDDING_END_AT INTO @BIDDING_END_AT FROM COLLECTOR_BIDDING A INNER JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID WHERE A.ID = CUR_ID;
			SET @MAX_DECISION_AT = ADDTIME(@BIDDING_END_AT, CONCAT(CAST(@max_selection_duration AS UNSIGNED), ':00:00'));
			UPDATE COLLECTOR_BIDDING SET MAX_DECISION_AT = @MAX_DECISION_AT WHERE ID = CUR_ID;
        END IF;

	END LOOP;   
	CLOSE TEMP_CURSOR;
    
END