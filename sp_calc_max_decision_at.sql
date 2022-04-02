CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_max_decision_at`(
	IN IN_DISPOSER_ORDER_ID		BIGINT,
    IN IN_COLLECTOR_BIDDING_ID	BIGINT,
    IN IN_REG_DT				DATETIME
)
BEGIN

    /*SELECT ID INTO @COLLECTOR_BIDDING_ID FROM COLLECTOR_BIDDING WHERE DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID;*/
	CALL sp_req_policy_direction(
	/*수거자가 배출자의 최종입찰선정에 응답을 할 수 있는 최대의 시간으로서 배출자의 최종낙찰자선정일로부터의 기간을 반환받는다(단위:시간)*/
		'max_selection_duration',
		@max_selection_duration
	);
        
	IF IN_COLLECTOR_BIDDING_ID IS NOT NULL THEN
		IF IN_COLLECTOR_BIDDING_ID = @COLLECTOR_BIDDING_ID THEN
			SELECT COUNT(ID) INTO @rec_count 
            FROM COLLECTOR_BIDDING 
            WHERE 
				DATE_OF_BIDDING 				IS NOT NULL AND 
                ID 								= IN_COLLECTOR_BIDDING_ID;
                
			IF @rec_count = 1 THEN
				SELECT B.BIDDING_END_AT INTO @BIDDING_END_AT 
                FROM COLLECTOR_BIDDING A 
                INNER JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID 
                WHERE A.ID = IN_COLLECTOR_BIDDING_ID;
     
				SET @MAX_SELECT_AT = ADDTIME(
										@BIDDING_END_AT, 
										CONCAT(
											CAST(@max_selection_duration AS UNSIGNED), 
											':00:01'
										)
									);
                
				SET @MAX_DECISION_AT = ADDTIME(
										@MAX_SELECT_AT, 
										CONCAT(
											CAST(@max_selection_duration AS UNSIGNED), 
											':00:01'
										)
									);
									
				SET @MAX_SELECT2_AT = ADDTIME(
										@MAX_DECISION_AT, 
										CONCAT(
											CAST(@max_selection_duration AS UNSIGNED), 
											':00:01'
										)
									);
                                    
				SET @MAX_DECISION2_AT = ADDTIME(
										@MAX_SELECT2_AT, 
										CONCAT(
											CAST(@max_selection_duration AS UNSIGNED), 
											':00:01'
										)
									);
                
				UPDATE COLLECTOR_BIDDING 
                SET 
					MAX_DECISION_AT 			= @MAX_DECISION_AT, 
                    UPDATED_AT 					= IN_REG_DT 
                WHERE ID 						= IN_COLLECTOR_BIDDING_ID;
                
				UPDATE SITE_WSTE_DISPOSAL_ORDER 
                SET 
					MAX_SELECT_AT				= @MAX_SELECT_AT,
					MAX_SELECT2_AT				= @MAX_SELECT2_AT,
					COLLECTOR_MAX_DECISION_AT 	= @MAX_DECISION_AT,  
                    COLLECTOR_MAX_DECISION2_AT 	= @MAX_DECISION2_AT , 
                    UPDATED_AT 					= IN_REG_DT 
                WHERE ID 						= IN_DISPOSER_ORDER_ID;
            
				SELECT FIRST_PLACE, SECOND_PLACE INTO @FIRST_PLACE, @SECOND_PLACE
				FROM SITE_WSTE_DISPOSAL_ORDER
				WHERE ID = IN_DISPOSER_ORDER_ID;
				
				IF @FIRST_PLACE IS NOT NULL THEN
					UPDATE COLLECTOR_BIDDING 
					SET MAX_DECISION_AT = @MAX_DECISION_AT
					WHERE ID = @FIRST_PLACE;
				END IF;
				
				IF @SECOND_PLACE IS NOT NULL THEN
					UPDATE COLLECTOR_BIDDING 
					SET MAX_DECISION_AT = @MAX_DECISION2_AT
					WHERE ID = @SECOND_PLACE;
				END IF;
			END IF;
		END IF;
	ELSE
		SELECT BIDDING_END_AT INTO @BIDDING_END_AT 
		FROM SITE_WSTE_DISPOSAL_ORDER
		WHERE ID = IN_DISPOSER_ORDER_ID;
 
		SET @MAX_SELECT_AT = ADDTIME(
								@BIDDING_END_AT, 
								CONCAT(
									CAST(@max_selection_duration AS UNSIGNED), 
									':00:02'
								)
							);
		
		SET @MAX_DECISION_AT = ADDTIME(
								@MAX_SELECT_AT, 
								CONCAT(
									CAST(@max_selection_duration AS UNSIGNED), 
									':00:02'
								)
							);
							
		SET @MAX_SELECT2_AT = ADDTIME(
								@MAX_DECISION_AT, 
								CONCAT(
									CAST(@max_selection_duration AS UNSIGNED), 
									':00:02'
								)
							);
							
		SET @MAX_DECISION2_AT = ADDTIME(
								@MAX_SELECT2_AT, 
								CONCAT(
									CAST(@max_selection_duration AS UNSIGNED), 
									':00:02'
								)
							);
/*            
		UPDATE COLLECTOR_BIDDING 
		SET 
			MAX_DECISION_AT 			= @MAX_DECISION_AT, 
			UPDATED_AT 					= IN_REG_DT 
		WHERE ID 						= IN_COLLECTOR_BIDDING_ID;
*/            
		UPDATE SITE_WSTE_DISPOSAL_ORDER 
		SET 
			MAX_SELECT_AT				= @MAX_SELECT_AT,
			MAX_SELECT2_AT				= @MAX_SELECT2_AT,
			COLLECTOR_MAX_DECISION_AT 	= @MAX_DECISION_AT,  
			COLLECTOR_MAX_DECISION2_AT 	= @MAX_DECISION2_AT , 
			UPDATED_AT 					= IN_REG_DT 
		WHERE ID = IN_DISPOSER_ORDER_ID;
		
		SELECT FIRST_PLACE, SECOND_PLACE INTO @FIRST_PLACE, @SECOND_PLACE
		FROM SITE_WSTE_DISPOSAL_ORDER
		WHERE ID = IN_DISPOSER_ORDER_ID;
		
		IF @FIRST_PLACE IS NOT NULL THEN
			UPDATE COLLECTOR_BIDDING 
			SET MAX_DECISION_AT = @MAX_DECISION_AT
			WHERE ID = @FIRST_PLACE;
		END IF;
		
		IF @SECOND_PLACE IS NOT NULL THEN
			UPDATE COLLECTOR_BIDDING 
			SET MAX_DECISION_AT = @MAX_DECISION2_AT
			WHERE ID = @SECOND_PLACE;
		END IF;
	END IF;
    
END