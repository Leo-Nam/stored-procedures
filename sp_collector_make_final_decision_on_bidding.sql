CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_collector_make_final_decision_on_bidding`(
	IN IN_USER_ID					BIGINT,				/*입력값 : 사용자 고유등록번호(USERS.ID)*/
	IN IN_COLLECTOR_BIDDING_ID		BIGINT,				/*입력값 : 입찰 고유등록번호(COLLECTOR_BIDDING.ID)*/
	IN IN_FINAL_DECISION			TINYINT				/*입력값 : 최종입찰에 대한 거절여부 결정(TRUE:수락, FALSE:거절)*/
)
BEGIN

/*
Procedure Name 	: sp_collector_make_final_decision_on_bidding
Input param 	: 3개
Job 			: 폐기물 수집운반업자가 배출자로부터 최종 낙찰자로 선정된 이후 최종결정을 한다.
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.27
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.2)
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  

    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
	CALL sp_req_user_exists_by_id(
	/*생성자가 존재하는지 체크한다.*/
		IN_USER_ID, 
		TRUE, 
		@rtn_val,
		@msg_txt
	);
	/*등록을 요청하는 사용자의 USER_ID가 이미 등록되어 있는 경우에는 @USER_EXISTS = 1, 그렇지 않은 경우에는 @USER_EXISTS = 0이 됨*/ 		
	IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우*/
		CALL sp_req_disposal_id_of_collector_bidding_id(
			IN_COLLECTOR_BIDDING_ID,
			@DISPOSAL_ORDER_ID
		);
		CALL sp_req_site_id_of_user_reg_id(
		/*사용자 고유등록번호로 사용자가 소속한 사이트의 고유등록번호를 반환한다.*/
			IN_USER_ID,
			@USER_SITE_ID,
			@rtn_val,
			@msg_txt
		);
		IF @rtn_val = 0 THEN
		/*사이트가 정상(개인사용자는 제외됨)적인 경우*/
			CALL sp_req_is_site_final_bidder(
			/*사이트가 배출자로부터 최종 선택을 받은 사이트인지 검사한다.*/
				@USER_SITE_ID,
				@IS_USER_SITE_FINAL_BIDDER
			);
			IF @IS_USER_SITE_FINAL_BIDDER = TRUE THEN
			/*사이트가 배출자로부터 최종 낙찰자로 선정된 경우*/
				UPDATE COLLECTOR_BIDDING 
				SET 
					MAKE_DECISION 		= IN_FINAL_DECISION, 
					MAKE_DECISION_AT 	= @REG_DT,
					UPDATED_AT 			= @REG_DT  
				WHERE ID = IN_COLLECTOR_BIDDING_ID;
				/*최종처리결정에 대한 거부권(TRUE:수락, FALSE:거부)을 행사한다.*/
				IF ROW_COUNT() = 1 THEN
				/*데이타베이스 입력에 성공한 경우*/
					SELECT BIDDING_RANK, COLLECTOR_ID INTO @BIDDING_RANK, @COLLECTOR_ID 
                    FROM COLLECTOR_BIDDING 
                    WHERE ID = IN_COLLECTOR_BIDDING_ID;
                    
					IF @BIDDING_RANK = 1 THEN
						CALL sp_req_policy_direction(
						/*수거자가 배출자의 최종입찰선정에 응답을 할 수 있는 최대의 시간으로서 배출자의 최종낙찰자선정일로부터의 기간을 반환받는다(단위:시간)*/
							'max_selection_duration',
							@max_selection_duration
						);
						SET @COLLECTOR_MAX_DECISION2_AT = ADDTIME(
															@REG_DT, 
															CONCAT(
																CAST(@max_selection_duration AS UNSIGNED), 
																':00:00'
															)
														);
						UPDATE SITE_WSTE_DISPOSAL_ORDER 
						SET 
							COLLECTOR_MAX_DECISION2_AT 			= @COLLECTOR_MAX_DECISION2_AT ,
							COLLECTOR_SELECTION_CONFIRMED 		= IN_FINAL_DECISION,  
							COLLECTOR_SELECTION_CONFIRMED_AT 	= @REG_DT,
                            COLLECTOR_BIDDING_ID				= IF(IN_FINAL_DECISION = TRUE, IN_COLLECTOR_BIDDING_ID, NULL),
                            SUCCESS_BIDDER						= IF(IN_FINAL_DECISION = TRUE, @COLLECTOR_ID, NULL),
							UPDATED_AT 							= @REG_DT
						WHERE ID 								= @DISPOSAL_ORDER_ID;
						IF ROW_COUNT() = 1 THEN
							CALL sp_calc_bidder_and_prospective_visitors(
								@DISPOSAL_ORDER_ID
							);
							IF IN_FINAL_DECISION = TRUE THEN
							/*최종결정을 수락한 경우에는 CLCT_TRMT_TRANSACTION에 이미 생성되어 있는 작업을 UPDATE한다.*/
								UPDATE WSTE_CLCT_TRMT_TRANSACTION
								SET
									ACCEPT_ASK_END			= IN_FINAL_DECISION,
									ACCEPT_ASK_END_AT		= @REG_DT,
									VISIT_END_AT			= IF(VISIT_END_AT IS NULL, NULL, @REG_DT),
									COLLECTOR_ID 			= @COLLECTOR_ID,
									COLLECTOR_BIDDING_ID 	= IN_COLLECTOR_BIDDING_ID,
									UPDATED_AT 				= @REG_DT
								WHERE 
									DISPOSAL_ORDER_ID 	= @DISPOSAL_ORDER_ID AND
                                    IN_PROGRESS			= TRUE;
								IF ROW_COUNT() = 1 THEN
								/*WSTE_CLCT_TRMT_TRANSACTION에 이미 생성되어 있는 작업사항 중 수거자결정 내용 변경에 성공한 경우*/
									CALL sp_create_chat_room(
										IN_USER_ID,
										@DISPOSAL_ORDER_ID,
										IN_COLLECTOR_BIDDING_ID,
										1,
										118,
										@rtn_val,
										@msg_txt                                
									);
									IF @rtn_val = 0 THEN
										SET @PUSH_CATEGORY_ID = 23;
										CALL sp_push_collector_make_final_decision(
											IN_USER_ID,
											@DISPOSAL_ORDER_ID,
											IN_COLLECTOR_BIDDING_ID,
											NULL,
											@PUSH_CATEGORY_ID,
											@json_data,
											@rtn_val,
											@msg_txt
										);
										IF @rtn_val > 0 THEN
											SIGNAL SQLSTATE '23000';
										END IF;
                                    ELSE
										SIGNAL SQLSTATE '23000';
                                    END IF;
								ELSE
								/*WSTE_CLCT_TRMT_TRANSACTION에 이미 생성되어 있는 작업사항 중 수거자결정 내용 변경에 실패한 경우 예외처리한다.*/
									SET @rtn_val 		= 24102;
									SET @msg_txt 		= 'Failed to change job information';
									SIGNAL SQLSTATE '23000';
								END IF;
							ELSE
								SET @PUSH_CATEGORY_ID = 24;
								CALL sp_push_collector_make_final_decision(
									IN_USER_ID,
									@DISPOSAL_ORDER_ID,
									IN_COLLECTOR_BIDDING_ID,
									NULL,
									@PUSH_CATEGORY_ID,
									@json_data,
									@rtn_val,
									@msg_txt
								);
								IF @rtn_val > 0 THEN
									SIGNAL SQLSTATE '23000';
								END IF;
							END IF;
						ELSE
							SET @rtn_val 		= 24104;
							SET @msg_txt 		= 'Failed to change emitter record';
							SIGNAL SQLSTATE '23000';
						END IF;
                    ELSE
						IF @BIDDING_RANK = 2 THEN
							UPDATE SITE_WSTE_DISPOSAL_ORDER 
							SET 
								COLLECTOR_SELECTION_CONFIRMED2 		= IN_FINAL_DECISION,  
								COLLECTOR_SELECTION_CONFIRMED2_AT 	= @REG_DT,
								COLLECTOR_BIDDING_ID				= IF(IN_FINAL_DECISION = TRUE, IN_COLLECTOR_BIDDING_ID, NULL),
								SUCCESS_BIDDER						= IF(IN_FINAL_DECISION = TRUE, @COLLECTOR_ID, NULL),
								UPDATED_AT 							= @REG_DT
							WHERE ID 								= @DISPOSAL_ORDER_ID;
							IF ROW_COUNT() = 1 THEN
								IF IN_FINAL_DECISION = TRUE THEN
								/*최종결정을 수락한 경우에는 CLCT_TRMT_TRANSACTION에 이미 생성되어 있는 작업을 UPDATE한다.*/
									UPDATE WSTE_CLCT_TRMT_TRANSACTION
									SET
										ACCEPT_ASK_END			= IN_FINAL_DECISION,
										ACCEPT_ASK_END_AT		= @REG_DT,
                                        VISIT_END_AT			= IF(VISIT_END_AT IS NULL, NULL, @REG_DT),
										COLLECTOR_ID 			= @COLLECTOR_ID,
										COLLECTOR_BIDDING_ID 	= IN_COLLECTOR_BIDDING_ID,
										UPDATED_AT 				= @REG_DT
									WHERE 
										DISPOSAL_ORDER_ID 	= @DISPOSAL_ORDER_ID AND
										IN_PROGRESS			= TRUE;
									IF ROW_COUNT() = 1 THEN
									/*WSTE_CLCT_TRMT_TRANSACTION에 이미 생성되어 있는 작업사항 중 수거자결정 내용 변경에 성공한 경우*/
										CALL sp_create_chat_room(
											IN_USER_ID,
											@DISPOSAL_ORDER_ID,
											IN_COLLECTOR_BIDDING_ID,
											1,
											118,
											@rtn_val,
											@msg_txt                                
										);
										IF @rtn_val = 0 THEN
											SET @PUSH_CATEGORY_ID = 23;
											CALL sp_push_collector_make_final_decision(
												IN_USER_ID,
												@DISPOSAL_ORDER_ID,
												IN_COLLECTOR_BIDDING_ID,
												NULL,
												@PUSH_CATEGORY_ID,
												@json_data,
												@rtn_val,
												@msg_txt
											);
											IF @rtn_val > 0 THEN
												SIGNAL SQLSTATE '23000';
											END IF;
										ELSE
											SIGNAL SQLSTATE '23000';
                                        END IF;
									ELSE
									/*WSTE_CLCT_TRMT_TRANSACTION에 이미 생성되어 있는 작업사항 중 수거자결정 내용 변경에 실패한 경우 예외처리한다.*/
										SET @rtn_val 		= 24107;
										SET @msg_txt 		= 'Failed to change job information';
										SIGNAL SQLSTATE '23000';
									END IF;
								ELSE
									SET @PUSH_CATEGORY_ID = 24;
									CALL sp_push_collector_make_final_decision(
										IN_USER_ID,
										@DISPOSAL_ORDER_ID,
										IN_COLLECTOR_BIDDING_ID,
										NULL,
										@PUSH_CATEGORY_ID,
										@json_data,
										@rtn_val,
										@msg_txt
									);
                                    IF @rtn_val > 0 THEN
										SIGNAL SQLSTATE '23000';
                                    END IF;
								END IF;
							ELSE
								SET @rtn_val 		= 24106;
								SET @msg_txt 		= 'Failed to change emitter record';
								SIGNAL SQLSTATE '23000';
							END IF;
						ELSE
							SET @rtn_val 		= 24105;
							SET @msg_txt 		= 'Failed to change emitter record';
							SIGNAL SQLSTATE '23000';
						END IF;
                    END IF;
				ELSE
				/*데이타베이스 입력에 실패한 경우*/
					SET @rtn_val 		= 24101;
					SET @msg_txt 		= 'db error occurred during bid cancellation';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사이트가 배출자로부터 최종 낙찰자로 선정되지 경우*/
				SET @rtn_val 		= 24103;
				SET @msg_txt 		= 'Only the site selected as the final successful bidder can accept or reject';
				SIGNAL SQLSTATE '23000';
			END IF;
        ELSE
		/*사이트가 정상(개인사용자는 제외됨)적이지 않은 경우*/
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*사용자가 존재하지 않거나 유효하지 않은 경우*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END