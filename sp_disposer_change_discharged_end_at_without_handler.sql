CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_disposer_change_discharged_end_at_without_handler`(
    IN IN_DISPOSER_ORDER_ID				BIGINT,
	IN IN_COLLECTOR_BIDDING_ID			BIGINT,
	IN IN_DISCHARGED_AT					DATETIME,
    OUT rtn_val							INT,
    OUT msg_txt							VARCHAR(200)
)
BEGIN
	CALL sp_req_current_time(@REG_DT);
	SELECT COUNT(ID) INTO @TRANSACTION_COUNT
	FROM WSTE_CLCT_TRMT_TRANSACTION
	WHERE DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID;
	IF @TRANSACTION_COUNT > 0 THEN
		SELECT COUNT(ID) INTO @TRANSACTION_COUNT_IN_PROGRESS
		FROM WSTE_CLCT_TRMT_TRANSACTION
		WHERE 
			DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND
			IN_PROGRESS = TRUE;
            
		IF @TRANSACTION_COUNT_IN_PROGRESS = 0 THEN
			SET rtn_val 		= 35209;
			SET msg_txt 		= 'transaction in progress does not exist';
		ELSE
			IF @TRANSACTION_COUNT_IN_PROGRESS = 1 THEN
				SELECT ID INTO @TRANSACTION_ID
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE 
					DISPOSAL_ORDER_ID 	= IN_DISPOSER_ORDER_ID AND
					IN_PROGRESS 		= TRUE;
                    
				UPDATE WSTE_CLCT_TRMT_TRANSACTION 
				SET 
					COLLECT_ASK_END_AT 	= IN_DISCHARGED_AT,
					UPDATED_AT 			= @REG_DT
				WHERE ID 				= @TRANSACTION_ID;
				IF ROW_COUNT() = 1 THEN   
					SELECT BIDDING_RANK 
					INTO @BIDDING_RANK 
					FROM COLLECTOR_BIDDING
					WHERE ID = IN_COLLECTOR_BIDDING_ID;  
					
					IF @BIDDING_RANK = 1 THEN
						CALL sp_setup_first_place_schedule(
							IN_DISPOSER_ORDER_ID,
							rtn_val,
							msg_txt
						);
					ELSE
						IF @BIDDING_RANK = 2 THEN
							SELECT SELECTED INTO @FIRST_SELECTED
							FROM SITE_WSTE_DISPOSAL_ORDER
							WHERE ID = IN_DISPOSER_ORDER_ID;
							
							IF @FIRST_SELECTED > 0 THEN
								SELECT COLLECTOR_SELECTION_CONFIRMED
								INTO @COLLECTOR_SELECTION_CONFIRMED
								FROM SITE_WSTE_DISPOSAL_ORDER
								WHERE ID = IN_DISPOSER_ORDER_ID;
								
								IF @COLLECTOR_SELECTION_CONFIRMED IS NOT NULL THEN
									IF @COLLECTOR_SELECTION_CONFIRMED = TRUE THEN
										SET rtn_val 		= 35208;
										SET msg_txt 		= 'The bid has already been awarded to the 1st place bidder';
									ELSE
										CALL sp_setup_second_place_schedule(
											IN_DISPOSER_ORDER_ID,
											rtn_val,
											msg_txt
										);
									END IF;
								ELSE
									CALL sp_setup_second_place_schedule(
										IN_DISPOSER_ORDER_ID,
                                        rtn_val,
                                        msg_txt
                                    );
								END IF;
							ELSE
								SET rtn_val 		= 35205;
								SET msg_txt 		= 'should request from the 1st priority site';
							END IF;
						ELSE
							SET rtn_val 		= 35204;
							SET msg_txt 		= 'sites with 3rd place or less';
						END IF;
					END IF;
				ELSE
					SET rtn_val 		= 35203;
					SET msg_txt 		= 'failed to update record';
				END IF;
			ELSE
				SET rtn_val 		= 35202;
				SET msg_txt 		= 'Must have 1 active transaction';
			END IF;
		END IF;
	ELSE
		SET rtn_val 		= 35201;
		SET msg_txt 		= 'transaction does not exist';
	END IF;
    
    

END