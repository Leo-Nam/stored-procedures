CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_setup_first_place_schedule`(
	IN IN_DISPOSER_ORDER_ID			BIGINT,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN
	CALL sp_req_policy_direction(
	/*수거자가 배출자의 최종입찰선정에 응답을 할 수 있는 최대의 시간으로서 배출자의 최종낙찰자선정일로부터의 기간을 반환받는다(단위:시간)*/
		'max_selection_duration',
		@max_selection_duration
	);
	
	SET @MAX_DECISION_AT = ADDTIME(
							@REG_DT, 
							CONCAT(
								CAST(@max_selection_duration AS UNSIGNED), 
								':00:00'
							)
						);
						
	SET @MAX_SELECT2_AT = ADDTIME(
							@MAX_DECISION_AT, 
							CONCAT(
								CAST(@max_selection_duration AS UNSIGNED), 
								':00:00'
							)
						);
						
	SET @MAX_DECISION2_AT = ADDTIME(
							@MAX_SELECT2_AT, 
							CONCAT(
								CAST(@max_selection_duration AS UNSIGNED), 
								':00:00'
							)
						);
	
	UPDATE SITE_WSTE_DISPOSAL_ORDER
	SET 
		MAX_SELECT2_AT				= @MAX_SELECT2_AT,
		COLLECTOR_MAX_DECISION_AT 	= @MAX_DECISION_AT,  
		COLLECTOR_MAX_DECISION2_AT 	= @MAX_DECISION2_AT ,
		SELECTED 		= IN_COLLECTOR_BIDDING_ID,
		SELECTED_AT 	= @REG_DT,
		UPDATED_AT 		= @REG_DT
	WHERE ID 			= IN_DISPOSER_ORDER_ID;
    
    IF ROW_COUNT() = 1 THEN
		SELECT FIRST_PLACE, SECOND_PLACE INTO @FIRST_PLACE, @SECOND_PLACE
		FROM SITE_WSTE_DISPOSAL_ORDER
		WHERE ID = IN_DISPOSER_ORDER_ID;
		
		IF @FIRST_PLACE IS NOT NULL THEN
			UPDATE COLLECTOR_BIDDING 
			SET MAX_DECISION_AT = @MAX_DECISION_AT
			WHERE ID = @FIRST_PLACE;
            IF ROW_COUNT() = 1 THEN
				IF @SECOND_PLACE IS NOT NULL THEN
					UPDATE COLLECTOR_BIDDING 
					SET MAX_DECISION_AT = @MAX_DECISION2_AT
					WHERE ID = @SECOND_PLACE;
					IF ROW_COUNT() = 1 THEN
						SET rtn_val 		= 0;
						SET msg_txt 		= 'success';
					ELSE
						SET rtn_val 		= 35703;
						SET msg_txt 		= 'second place record update failed';
					END IF;
				ELSE
					SET rtn_val 		= 0;
					SET msg_txt 		= 'success';
				END IF;
            ELSE
				SET rtn_val 		= 35702;
				SET msg_txt 		= 'first place record update failed';
            END IF;
		ELSE
			SET rtn_val 		= 0;
			SET msg_txt 		= 'success';
		END IF;		
    ELSE
		SET rtn_val 		= 35701;
		SET msg_txt 		= 'emitter record update failed';
    END IF;

END