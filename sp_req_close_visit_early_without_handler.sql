CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_close_visit_early_without_handler`(
	IN IN_USER_ID				BIGINT,
    IN IN_DISPOSER_ORDER_ID		BIGINT,
    IN IN_REG_DT				DATETIME,
    OUT rtn_val					INT,
    OUT msg_txt					VARCHAR(200),
    OUT json_data				JSON
)
BEGIN
	CALL sp_req_user_class_by_user_reg_id(
	/*사용자의 권한을 구한다.*/
		IN_USER_ID,
		@USER_CLASS
	);
	IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
	/*관리자가 정보를 변경할 권한이 있는 경우*/
		SELECT COUNT(ID) INTO @COUNT_OF_REQUEST_OF_VISIT 
		FROM COLLECTOR_BIDDING 
		WHERE 
			DATE_OF_VISIT IS NOT NULL AND 			/*방문승낙을 받은 업체가 존재하는 경우*/
			DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID;
		/*방문신청한 업체수를 계산하여 @COUNT_OF_REQUEST_OF_VISIT을 통하여 반환한다.*/
		
		IF @COUNT_OF_REQUEST_OF_VISIT > 0 THEN
		/*방문신청한 업체가 1이상 존재하는 경우*/
			SELECT PROSPECTIVE_VISITORS INTO @PROSPECTIVE_VISITORS 
			FROM SITE_WSTE_DISPOSAL_ORDER 
			WHERE 
				ID = IN_DISPOSER_ORDER_ID;
			/*방문승낙 받은 업체수를 계산하여 @COUNT_OF_VISIT_CONFIRMED을 통하여 반환한다.*/
			IF @PROSPECTIVE_VISITORS > 0 THEN
			/*방문승낙 받은 업체가 1이상 존재하는 경우*/
				SELECT VISIT_START_AT INTO @VISIT_START_AT FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = IN_DISPOSER_ORDER_ID;
				IF @VISIT_START_AT <= IN_REG_DT THEN
				/*방문시작이 된 경우에는 정상처리한다.*/
					CALL sp_req_policy_direction(
					/*조기마감이 된 배출신청에 등록된 입찰마감일자를 반환한다.*/
						'duration_bidding_end_date_after_the_visit_closing',
						@duration_bidding_end_date_after_the_visit_closing
					);
                    
					UPDATE SITE_WSTE_DISPOSAL_ORDER 
					SET 
						VISIT_EARLY_CLOSING 		= TRUE, 
						VISIT_EARLY_CLOSED_AT 		= IN_REG_DT, 
						BIDDING_END_AT 	= ADDTIME(IN_REG_DT, CONCAT(@duration_bidding_end_date_after_the_visit_closing, ':00:00')),
					/*	BIDDING_END_AT 	= IF(BIDDING_END_AT <= ADDTIME(IN_REG_DT, CONCAT(@PERIOD_UNTIL_BIDDING_END_DATE, ':00')), */
					/*						BIDDING_END_AT, 				*/	
											/*조건을 만족하는 경우로서 입찰마감일이 현재일로부터 정책으로 결정된 시간 이내인 경우에는 현재 설정된 입찰마감일을 그대로 사용하도록 한다.*/
					/*						ADDTIME(IN_REG_DT, CONCAT(@PERIOD_UNTIL_BIDDING_END_DATE, ':00'))		*/		
											/*조건을 만족하지 않는 경우로서 입찰마감일이 현재일로부터 정책으로 결정된 시간 이후인 경우에는 현재 시간으로부터 정책으로 결정된 시간 이후의 시간으로 입찰마감일을 변경한다.*/
					/*					), */
						VISIT_END_AT 	= IN_REG_DT,
						UPDATED_AT 		= IN_REG_DT
					WHERE ID 			= IN_DISPOSER_ORDER_ID;
                    
                    SELECT ID INTO @TRANSACTION_ID
                    FROM WSTE_CLCT_TRMT_TRANSACTION
                    WHERE 
						DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND
                        IN_PROGRESS = TRUE;
					
                    UPDATE WSTE_CLCT_TRMT_TRANSACTION
                    SET VISIT_END_AT = IN_REG_DT
                    WHERE ID = @TRANSACTION_ID;
                    
					CALL sp_calc_max_decision_at(
					/*배출자가 입찰을 조기종료함으로써 모든 수거자의 최대결심일자를 변경적용한다.*/
						IN_DISPOSER_ORDER_ID,
						NULL,
						IN_REG_DT
					);
					CALL sp_retrieve_sites_that_can_bid(
						IN_DISPOSER_ORDER_ID,
						rtn_val,
						msg_txt,
						json_data
					);
				ELSE
				/*방문시작이 되지 않은 경우에는 예외처리한다.*/
					SET json_data = NULL;
					SET rtn_val = 35804;
					SET msg_txt = 'The visit date has not arrived yet';
				END IF;
			ELSE
			/*방문승낙 받은 업체가 존재하지 않는 경우 예외처리한다.*/
				SET json_data = NULL;
				SET rtn_val = 35803;
				SET msg_txt = 'no company that has been approved to visit';
			END IF;
		ELSE
		/*방문신청한 업체가 존재하지 않는 경우에는 예외처리한다.*/
			SET json_data = NULL;
			SET rtn_val = 35802;
			SET msg_txt = 'The company requested to visit does not exist';
		END IF;
	ELSE
	/*관리자가 정보를 변경할 권한이 없는 경우*/
		SET json_data = NULL;
		SET rtn_val = 35801;
		SET msg_txt = 'User does not have permission to change information';
	END IF;

END