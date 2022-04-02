CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_select_collector_without_handler`(
	IN IN_COLLECTOR_BIDDING_ID				BIGINT,
    IN IN_DISPOSER_ORDER_ID					BIGINT,
	IN IN_DISCHARGED_END_AT					DATETIME,
    IN IN_REG_DT							DATETIME,
    IN IN_RANK								INT,
    OUT rtn_val								INT,
    OUT msg_txt								VARCHAR(200)
)
BEGIN
	SET @SELECTED_AT = IN_REG_DT;
/*
	CALL sp_req_policy_direction(
		'max_decision_duration',
		@max_decision_duration
	);
    SET @MAX_DECISION_AT = ADDTIME(@SELECTED_AT, CONCAT(CAST(@max_decision_duration AS UNSIGNED), ':00:00'));
    SET @MAX_SELECT2_AT = ADDTIME(@MAX_DECISION_AT, CONCAT(CAST(@max_decision_duration AS UNSIGNED), ':00:00'));
    SET @MAX_DECISION2_AT = ADDTIME(@MAX_SELECT2_AT, CONCAT(CAST(@max_decision_duration AS UNSIGNED), ':00:00'));
*/    
    IF IN_RANK = 1 THEN
    
		UPDATE SITE_WSTE_DISPOSAL_ORDER 
		SET 
			SELECTED = IN_COLLECTOR_BIDDING_ID, 
            SELECTED_AT = @SELECTED_AT,
            UPDATED_AT = @SELECTED_AT
        WHERE ID = IN_DISPOSER_ORDER_ID;
    
		CALL sp_setup_first_place_schedule(
			IN_DISPOSER_ORDER_ID,
			@SELECTED_AT,
			rtn_val,
			msg_txt
		);    
    ELSE
    
		UPDATE SITE_WSTE_DISPOSAL_ORDER 
        SET 
			SELECTED2 = IN_COLLECTOR_BIDDING_ID, 
            SELECTED2_AT = @SELECTED_AT,
            UPDATED_AT = @SELECTED_AT
        WHERE ID = IN_DISPOSER_ORDER_ID;
        
		CALL sp_setup_second_place_schedule(
			IN_DISPOSER_ORDER_ID,
			@SELECTED_AT,
			rtn_val,
			msg_txt
		);   
        
    END IF;
	IF rtn_val = 0 THEN
		UPDATE COLLECTOR_BIDDING 
		SET 
			SELECTED = TRUE, 
			SELECTED_AT = @SELECTED_AT,
            UPDATED_AT = @SELECTED_AT
		WHERE ID = IN_COLLECTOR_BIDDING_ID;
		/*수거자가 배출자의 최종입찰선정에 응답을 할 수 있는 최대의 시간으로서 배출자의 최종낙찰자선정일에 합산하여 MAX_DECISION_AT을 결정한다.*/
		IF ROW_COUNT() = 1 THEN
/*        
			IF IN_RANK = 1 THEN
				SELECT SECOND_PLACE INTO @SECOND_PLACE 
                FROM SITE_WSTE_DISPOSAL_ORDER 
                WHERE ID = IN_DISPOSER_ORDER_ID;
				IF @SECOND_PLACE IS NOT NULL THEN
					UPDATE COLLECTOR_BIDDING 
					SET 
						MAX_DECISION_AT = @MAX_DECISION2_AT,
						UPDATED_AT = @SELECTED_AT
					WHERE ID = @SECOND_PLACE;
				END IF;
            END IF;
*/            
			SELECT COUNT(ID) INTO @TRANSACTION_COUNT 
            FROM WSTE_CLCT_TRMT_TRANSACTION 
            WHERE 
				DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND 
                IN_PROGRESS = 1;
                
			IF @TRANSACTION_COUNT > 1 THEN
				SET rtn_val = 35105;
				SET msg_txt = '2 or more transactions exist';
            ELSE
				IF @TRANSACTION_COUNT = 1 THEN
					UPDATE WSTE_CLCT_TRMT_TRANSACTION 
					SET 
						COLLECT_ASK_END_AT = IN_DISCHARGED_END_AT,
						UPDATED_AT = @SELECTED_AT 
					WHERE 
						DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND 
						IN_PROGRESS = 1;
                        
					IF ROW_COUNT() = 1 THEN
						SET rtn_val = 0;
						SET msg_txt = 'success';
                    ELSE
						SET rtn_val = 35104;
						SET msg_txt = 'Failed to save transaction';
                    END IF;
				ELSE
					SET rtn_val = 35103;
					SET msg_txt = 'transaction does not exist';
                END IF;
            END IF;
		ELSE
			SET rtn_val = 35102;
			SET msg_txt = 'Failed to determine the maximum successful bid acceptance date of the collector';
		END IF;
	ELSE
		SET rtn_val = 35101;
		SET msg_txt = 'Failure to record collector selection information';
	END IF;

END