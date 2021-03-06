CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_bidding_id_in_push_history_at_all`(
)
BEGIN

    DECLARE vRowCount 						INT DEFAULT 0;
    DECLARE endOfRow 						TINYINT DEFAULT FALSE;  
    
    DECLARE CUR_ID		 					BIGINT;
    DECLARE CUR_USER_ID							BIGINT;
    DECLARE CUR_ORDER_ID							BIGINT;
    
    DECLARE TEMP_CURSOR 					CURSOR FOR 
    SELECT 
		ID, USER_ID, ORDER_ID
	FROM PUSH_HISTORY
    WHERE CATEGORY_ID = 6;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;   
    	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_ID,
			CUR_USER_ID,
			CUR_ORDER_ID;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
        SELECT A.ID INTO @BIDDING_ID
        FROM COLLECTOR_BIDDING A
        LEFT JOIN USERS B ON A.COLLECTOR_ID = B.AFFILIATED_SITE
        WHERE B.ID = CUR_USER_ID AND A.DISPOSAL_ORDER_ID = CUR_ORDER_ID;
        
        UPDATE PUSH_HISTORY SET BIDDING_ID = @BIDDING_ID
        WHERE ID = CUR_ID AND BIDDING_ID IS NULL;
	END LOOP;   
	CLOSE TEMP_CURSOR;
    
END