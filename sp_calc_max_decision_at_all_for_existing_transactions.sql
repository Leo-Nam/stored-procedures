CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_max_decision_at_all_for_existing_transactions`(
)
BEGIN

    DECLARE vRowCount 						INT DEFAULT 0;
    DECLARE endOfRow 						TINYINT DEFAULT FALSE;      
    DECLARE CUR_ID		 					BIGINT;    
    DECLARE CUR_ORDER_ID		 			BIGINT;    
    DECLARE CUR_COLLECTOR_MAX_DECISION_AT	DATETIME;    
    DECLARE TEMP_CURSOR 					CURSOR FOR 
    SELECT 
		A.ID,
        A.DISPOSAL_ORDER_ID,
        B.COLLECTOR_MAX_DECISION_AT
	FROM WSTE_CLCT_TRMT_TRANSACTION A 
    LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;   
    	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_ID,
			CUR_ORDER_ID,
			CUR_COLLECTOR_MAX_DECISION_AT;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;	
    
		UPDATE WSTE_CLCT_TRMT_TRANSACTION 
		SET MAX_DECISION_AT = CUR_COLLECTOR_MAX_DECISION_AT 
		WHERE ID = CUR_ID AND COLLECTOR_BIDDING_ID IS NULL;
		/*COLLECTOR_BIDDING 전체 레코드에 대해서 BIDDING_RANK를 NULL로 셋팅한다.*/

	END LOOP;   
	CLOSE TEMP_CURSOR;
    
END