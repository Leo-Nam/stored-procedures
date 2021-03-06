CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_bidder_and_prospective_visitors_at_all`(
	OUT OUT_COUNT				INT
)
BEGIN

    DECLARE vRowCount 						INT DEFAULT 0;
    DECLARE endOfRow 						TINYINT DEFAULT FALSE;  
    
    DECLARE CUR_ID		 					BIGINT;
    
    DECLARE TEMP_CURSOR 					CURSOR FOR 
    SELECT 
		ID
	FROM SITE_WSTE_DISPOSAL_ORDER;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;   
    	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_ID;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
				
		SELECT COUNT(ID) INTO @BIDDERS 
		FROM COLLECTOR_BIDDING 
		WHERE 
			BID_AMOUNT 				IS NOT NULL AND
			DISPOSAL_ORDER_ID 		= CUR_ID AND 
			DATE_OF_BIDDING			IS NOT NULL AND
			CANCEL_BIDDING 			= FALSE AND
			REJECT_BIDDING 			<> TRUE AND
			REJECT_BIDDING_APPLY	<> TRUE AND
			GIVEUP_BIDDING			<> TRUE AND
			ACTIVE					= TRUE AND
			DELETED					= FALSE;
            
		SELECT COUNT(ID) INTO @PROSPECTIVE_VISITORS 
		FROM COLLECTOR_BIDDING 
		WHERE 
			DISPOSAL_ORDER_ID 	= CUR_ID AND 
			DATE_OF_VISIT 		IS NOT NULL AND
			CANCEL_VISIT 		= FALSE AND
			RESPONSE_VISIT 		= TRUE AND
			DELETED				= FALSE;
            
		SELECT COUNT(ID) INTO @COUNT_BIDDINGS
		FROM COLLECTOR_BIDDING 
		WHERE DISPOSAL_ORDER_ID 	= CUR_ID;   
        
		SELECT COUNT(ID) INTO @UNABLED_BIDDERS 
		FROM COLLECTOR_BIDDING 
		WHERE 
			DISPOSAL_ORDER_ID 	= CUR_ID AND 
			(
				ACTIVE		 			= FALSE OR
				DELETED 				= TRUE OR
				DATE_OF_VISIT 			IS NULL OR
				RESPONSE_VISIT 			= FALSE OR
				RESPONSE_VISIT 			IS NULL OR
				CANCEL_VISIT 			= TRUE OR
				REJECT_BIDDING_APPLY 	= TRUE OR
				GIVEUP_BIDDING 			= TRUE OR
				CANCEL_BIDDING 			= TRUE OR
				REJECT_BIDDING 			= TRUE OR
				DATE_OF_BIDDING			IS NOT NULL
			);
			
		UPDATE SITE_WSTE_DISPOSAL_ORDER 
        SET 
			BIDDERS = @BIDDERS,
            PROSPECTIVE_VISITORS = @PROSPECTIVE_VISITORS,
            PROSPECTIVE_BIDDERS = @COUNT_BIDDINGS - @UNABLED_BIDDERS
        WHERE ID = CUR_ID;
		SET OUT_COUNT = ROW_COUNT();
	END LOOP;   
	CLOSE TEMP_CURSOR;
    
END