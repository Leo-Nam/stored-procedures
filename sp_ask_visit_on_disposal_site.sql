CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_ask_visit_on_disposal_site`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 방문요청자(수거자 사이트의 관리자)의 고유등록번호(USER.ID)*/
	IN IN_DISPOSER_ORDER_ID		BIGINT,				/*입력값 : 배출 신청 고유등록번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
	IN IN_VISIT_AT				DATETIME			/*입력값 : 방문요청을 하는 자의 방문예정일*/
)
BEGIN

/*
Procedure Name 	: sp_ask_visit_on_disposal_site
Input param 	: 3개
Job 			: 배출자의 배출지에 대한 방문요청 등록
Update 			: 2022.01.27
Version			: 0.0.5
AUTHOR 			: Leo Nam
Change			: 현재시간을 구하여 필요한 sp에 입력자료로 넘김(0.0.2)
				: STATUS_HISTORY에 입력하는 기능 추가(0.0.2)
				: STATUS_HISTORY에 입력하는 기능 삭제(0.0.3)
				: sp_req_ask_visit을 이용하여 ASK_VISIT_SITE 테이블에 입력하는 방법 삭제(ASK_VISIT_SITE 더이상 사용하지 않음/모든 일정 COLLECTOR_BIDDING으로 통합관리)(0.0.3)
				: status code 기록기능 삭제(칼럼 비활성화 할 예정)(0.0.4)
				: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.5)
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
    
	IF DATE(IN_VISIT_AT) >= DATE(@REG_DT) THEN
	/*방문신청날짜가 현재날짜보다 하루이상 과거의 날짜인 아닌경우에는 정상처리한다.*/
		CALL sp_req_user_exists_by_id(
			IN_USER_ID,				/*사용자의 고유등록번호*/
			TRUE,					/*ACTIVE가 TRUE인 상태(활성화 상태)인 사용자에 한정*/
			@rtn_val,
			@msg_txt
		);
		
		IF @rtn_val = 0 THEN
		/*요청자의 고유등록번호가 존재하는 경우*/
			CALL sp_req_is_user_collector(
			/*USER가 소속한 사이트가 수집운반업 등 폐기물을 처리할 자격이 있는지 검사한다.*/
				IN_USER_ID,					/*방문요청을 하는 사용자의 고유등록번호(USERS.ID)*/
				@rtn_val,
				@msg_txt
			);
			IF @rtn_val = 0 THEN
			/*USER가 소속한 사이트가 수집운반업 등 폐기물을 처리할 자격이 있는 경우*/        
				CALL sp_req_disposal_order_exists(
				/*폐기물 배출 요청 내역이 존재하는지 검사한다.*/
					IN_DISPOSER_ORDER_ID,
					@DISPOSAL_ORDER_EXISTS
				);
				IF @DISPOSAL_ORDER_EXISTS > 0 THEN
				/*폐기물 배출 요청 내역이 존재하는 경우*/
					CALL sp_req_site_id_of_disposal_order_id(
						IN_DISPOSER_ORDER_ID,
						@DISPOSER_SITE_ID
					);
					CALL sp_req_site_id_of_user_reg_id(
					/*사용자(수거자의 관리자)가 소속한 사이트의 고유등록번호를 반환한다.*/
						IN_USER_ID,
						@USER_SITE_ID,
						@rtn_val,
						@msg_txt
					);
					IF @USER_SITE_ID <> @DISPOSER_SITE_ID THEN
					/*방문신청을 하는 사이트가 자신이 배출한 사이트가 아닌 다른 사이트인 경우에는 정상처리한다.*/
						CALL sp_req_collector_can_ask_visit(
						/*수집운반업자 등이 방문신청을 할수 있는지 검사한다.*/
							IN_DISPOSER_ORDER_ID,
							@COLLECTOR_CAN_ASK_VISIT,
							@rtn_val,
							@msg_txt
						);
						IF @rtn_val = 0 THEN
						/*수집운반업자등이 방문신청을 할 수 있는 경우*/
							CALL sp_req_visit_date_expired(
							/*방문마감일정이 남아 있는지 확인한다.*/
								IN_DISPOSER_ORDER_ID,
								@rtn_val,
								@msg_txt
							);
							IF @rtn_val > 0 THEN
							/*배출자가 결정한 방문마감일이 아직 남아 있는 경우*/
								CALL sp_req_is_visit_schedule_close_early(
								/*사이트가 방문조기마감이 되었는지 확인한다.*/
									IN_DISPOSER_ORDER_ID,
									@rtn_val,
									@msg_txt
								);
								IF @rtn_val = 0 THEN
								/*사이트의 방문일정이 조기 마감되지 않았다면*/
									CALL sp_req_visit_date_on_disposal_order(
										IN_DISPOSER_ORDER_ID,
										@DISPOSAL_VISIT_START_AT,
										@DISPOSAL_VISIT_END_AT
									);
									IF @DISPOSAL_VISIT_END_AT IS NOT NULL THEN
									/*배출자의 방문요청이 존재하는 경우*/
										IF @DISPOSAL_VISIT_START_AT IS NOT NULL THEN
										/*배출자의 방문요청이 기간으로서 시작일자가 존재하는 경우*/
											IF DATE(IN_VISIT_AT) = DATE(@DISPOSAL_VISIT_START_AT) THEN
											/*방문신청일과 방문시작일이 같은 날짜인 경우-2022.03.16추가함*/
											/*방문예정일에 시간이 정해지지 않은 날짜만 있는 경우에는 시간이 00:00:00.000000으로 정해지기 때문에 방문예정일자와 배출자가 정한 방문시작일의 날짜가 같다면 수거자의 방문예정일자에 배출자의 방문시작일에 포함된 시간을 자동으로 붙혀주어서 당일 방문신청에 시간이 없더라도 신청가등하도록 한다.*/
												SET @DISPOSAL_VISIT_START_TIME = TIME(@DISPOSAL_VISIT_START_AT);
												SET IN_VISIT_AT = CAST(CONCAT(DATE(IN_VISIT_AT), ' ', @DISPOSAL_VISIT_START_TIME) AS DATETIME);
											END IF;
											IF IN_VISIT_AT < @DISPOSAL_VISIT_START_AT THEN
											/*수거자의 방문신청일자가 배출자가 정한 방문시작일 이전인 경우에는 예외처리한다.*/
												SET @rtn_val 		= 23102;
												SET @msg_txt 		= 'The date of request for visit is before the possible start date of visit';
												SIGNAL SQLSTATE '23000';
											ELSE
											/*수거자의 방문신청일자가 배출자가 정한 방문시작일 이후인 경우에는 정상처리한다.*/
												IF IN_VISIT_AT > @DISPOSAL_VISIT_END_AT THEN
												/*수거자의 방문신청일자가 배출자가 정한 방문종료일 이후인 경우에는 예외처리한다.*/
													SET @rtn_val 		= 23103;
													SET @msg_txt 		= 'The visit request date is after the visit end date';
													SIGNAL SQLSTATE '23000';
												ELSE
												/*수거자의 방문신청일자가 배출자가 정한 방문종료일 이전인 경우에는 정상처리한다.*/
													SELECT COUNT(ID) INTO @CHK_COUNT 
													FROM COLLECTOR_BIDDING 
													WHERE 
														COLLECTOR_ID = IN_USER_ID AND 
														DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND 
														ACTIVE = TRUE;
													/*기존에 입력된 데이타가 존재하는지 확인한다.*/
													IF @CHK_COUNT = 1 THEN
													/*기존 데이타가 존재한다면 데이타를 업데이트 처리한다.*/
														UPDATE COLLECTOR_BIDDING 
														SET 
															DATE_OF_VISIT = IN_VISIT_AT,
															UPDATED_AT = @REG_DT
														WHERE 
															COLLECTOR_ID = IN_USER_ID AND 
															DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND 
															ACTIVE = TRUE;
														IF ROW_COUNT() = 1 THEN
														/*정상적으로 변경완료된 경우*/
															SET @rtn_val 		= 0;
															SET @msg_txt 		= 'Success';
														ELSE
														/*정상적으로 변경되지 않은 경우*/
															SET @rtn_val 		= 23104;
															SET @msg_txt 		= 'Error in processing the request for visit by the collector';
															SIGNAL SQLSTATE '23000';
														END IF;
													ELSE
													/*기존 데이타가 존재하지 않는다면 새로운 레코드를 생성한다.*/
														CALL sp_create_collector_bidding(
															@USER_SITE_ID, 
															IN_DISPOSER_ORDER_ID, 
															TRUE, 
															IN_VISIT_AT, 
															@REG_DT,
															@rtn_val,
															@msg_txt
														);
														IF @rtn_val = 0 THEN
														/*정상적으로 입력완료된 경우*/
															SET @rtn_val 		= 0;
															SET @msg_txt 		= 'Success77';
														ELSE
														/*정상적으로 입력되지 않은 경우*/
															SIGNAL SQLSTATE '23000';
														END IF;
													END IF;
												END IF;
											END IF;
										ELSE
										/*배출자의 방문요청이 기간이 아니어서 시작일자가 존재하지 않는 경우*/
											IF IN_VISIT_AT > @DISPOSAL_VISIT_END_AT THEN
											/*수거자의 방문신청일자가 배출자가 정한 방문종료일 이후인 경우에는 예외처리한다.*/
												SET @rtn_val 		= 23110;
												SET @msg_txt 		= 'The visit request date is after the visit end date';
												SIGNAL SQLSTATE '23000';
											ELSE
											/*수거자의 방문신청일자가 배출자가 정한 방문종료일 이전인 경우에는 정상처리한다.*/
												IF IN_VISIT_AT > @REG_DT THEN
												/*수거자가 지정한 방문신청일자가 현재보다 이후인 경우 정상처리한다.*/
													UPDATE COLLECTOR_BIDDING 
													SET 
														DATE_OF_VISIT = IN_VISIT_AT,
														UPDATED_AT = @REG_DT
													WHERE 
														COLLECTOR_ID = IN_USER_ID AND 
														DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND 
														ACTIVE = TRUE;
													IF ROW_COUNT() = 1 THEN
													/*정상적으로 변경완료된 경우*/
														SET @rtn_val 		= 0;
														SET @msg_txt 		= 'Success';
													ELSE
													/*정상적으로 변경되지 않은 경우*/
														SET @rtn_val 		= 23112;
														SET @msg_txt 		= 'Failed to register the date of visit';
														SIGNAL SQLSTATE '23000';
													END IF;
												ELSE
												/*수거자가 지정한 방문신청일자가 현재보다 이전인 경우 예외처리한다.*/
													SET @rtn_val 		= 23108;
													SET @msg_txt 		= 'Visit request date cannot be in the past';
													SIGNAL SQLSTATE '23000';
												END IF;
											END IF;
										END IF;
									ELSE
									/*배출자의 방문요청이 존재하지 않는 경우*/
										SET @rtn_val 		= 23107;
										SET @msg_txt 		= 'There is no visit request from the emitter';
										SIGNAL SQLSTATE '23000';
									END IF;
								ELSE
								/*사이트의 방문일정이 조기 마감되었다면 예외처리한다.*/
									SIGNAL SQLSTATE '23000';
								END IF;
							ELSE
							/*배출자가 결정한 방문마감일이 초과한 경우*/
								SET @rtn_val 		= 23106;
								SET @msg_txt 		= 'Visitation schedule has ended early';
								SIGNAL SQLSTATE '23000';
							END IF;
						ELSE
						/*수집운반업자등이 방문신청을 할 수 없는 경우*/
							SIGNAL SQLSTATE '23000';
						END IF;
					ELSE
					/*방문신청을 하는 사이트가 자신이 배출한 사이트인 경우에는 예외처리한다.*/
						SET @rtn_val 		= 23109;
						SET @msg_txt 		= 'cannot apply for a visit to your own discharge application';
						SIGNAL SQLSTATE '23000';
					END IF;
					
				ELSE
				/*폐기물 배출 요청 내역이 존재하지 않는 경우 예외처리한다.*/
					SET @rtn_val 		= 23105;
					SET @msg_txt 		= 'Waste Discharge Request does not exist';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*USER가 소속한 사이트가 수집운반업 등 폐기물을 처리할 자격이 없는 경우*/
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
		/*요청자의 고유등록번호가 존재하지 않는 경우에는 예외처리한다.*/
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
	/*방문신청날짜가 현재날짜보다 하루이상 과거의 날짜인 경우에는 예외처리한다.*/
		SET @rtn_val 		= 23111;
		SET @msg_txt 		= 'Impossible to apply for a visit on a date before the present';
		SIGNAL SQLSTATE '23000';
	END IF;
    
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END