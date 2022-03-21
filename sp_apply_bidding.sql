CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_apply_bidding`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 입찰을 시도하는 사용자 아이디(USERS.ID)*/
    IN IN_DISPOSAL_ORDER_ID		BIGINT,				/*입력값 : 폐기물배출신청 등록고유번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
    IN IN_BID_AMOUNT			FLOAT,				/*입력값 : 폐기물처리견적가 총액*/
    IN IN_TRMT_METHOD			VARCHAR(4),			/*입력값 : 폐기물 처리방법*/
    IN IN_BIDDING_DETAILS		JSON				/*입력값 : 폐기물 수집운반 및 처리에 대한 입찰내역서*/
)
BEGIN

/*
Procedure Name 	: sp_apply_bidding
Input param 	: 3개
Job 			: 수거자 등에서 폐기물 처리를 위한 입찰내역 등록
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.29
Version			: 0.0.5
AUTHOR 			: Leo Nam
Change			: STATUS_HISTORY 테이블 사용 중지(0.0.2) / COLLECTOR_BIDDING 테이블에서 방문 및 입찰 정보 통합관리 시작
				: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.4)
				: 서브 프로시저의 데이타 반환타입 통일(0.0.5)
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		/*ROLLBACK;*/
        COMMIT;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
	
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
	CALL sp_req_user_exists_by_id(
		IN_USER_ID, 
		TRUE, 
		@rtn_val,
		@msg_txt
	);
	/*IN_USER_ID가 이미 등록되어 있는 사용자인지 체크한다. 등록되어 있는 경우에는 @USER_EXISTS = 1, 그렇지 않은 경우에는 @USER_EXISTS = 0을 반환한다.*/
	/*이미 등록되어 있는 사용자인 경우에는 관리자(member.admin)인지 검사한 후 member.admin인 경우에는 사업자 생성권한을 부여하고 그렇지 않은 경우에는 예외처리한다.*/
	/*등록되어 있지 않은 경우에는 신규사업자 생성으로 간주하고 정상처리 진행한다.*/
	
	IF @rtn_val = 0 THEN
    /*입찰을 신청하는 사용자가 유효한 경우*/
		CALL sp_req_site_id_of_user_reg_id(
        /*사용자가 소속한 사이트의 고유등록번호를 반환한다.*/
			IN_USER_ID,
            @USER_SITE_ID,
			@rtn_val,
			@msg_txt
        );
        IF @rtn_val = 0 THEN
        /*사이트가 유효한 사업자의 사이트인 경우*/
			CALL sp_req_site_already_bid(
			/*입찰신청을 하려는 사이트가 이미 입찰을 했는지 검사한다.*/
				@USER_SITE_ID,
				IN_DISPOSAL_ORDER_ID,
				@rtn_val,
				@msg_txt
			);
			IF @rtn_val = 0 THEN
			/*사이트가 이미 입찰한 내역이 존재하지 않는 경우*/
				CALL sp_req_user_class_by_user_reg_id(
				/*사용자의 권한을 반환한다.*/
					IN_USER_ID,
					@USER_CLASS
				);
				IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
				/*사용자가 입찰을 신청할 권한이 있는경우*/
					CALL sp_req_is_site_collector(
					/*사이트가 수집운반 등의 폐기물 처리권한이 있는지 검사한다.*/
						@USER_SITE_ID,
						@rtn_val,
						@msg_txt
					);
					IF @rtn_val = 0 THEN
					/*사이트가 수집운반 등의 폐기물 처리권한이 있는 경우*/
						CALL sp_get_duty_to_apply_for_visit(
						/*폐기물 배출신청 사이트에 방문의무가 있는지 여부를 확인한다.*/
							IN_DISPOSAL_ORDER_ID,
							@rtn_val,
							@msg_txt
						);
						IF @rtn_val = 0 THEN
						/*폐기물 배출신청 사이트에 방문의무가 있는 경우*/
							CALL sp_req_visit_date_expired(
							/*방문종료일이 마감되었는지 확인한다.*/
								IN_DISPOSAL_ORDER_ID,
								@rtn_val,
								@msg_txt
							);
							IF @rtn_val = 0 THEN
							/*방문종료일이 마감되었으면 입찰가능상태로서 정상입찰을 진행한다.*/
								CALL sp_req_apply_for_visit(
								/*방문의무가 있는 사이트에 방문신청을 한 사실이 있는지에 대한 여부 확인*/
									@USER_SITE_ID,
									IN_DISPOSAL_ORDER_ID,
									@COLLECTOR_BIDDING_ID,
									@rtn_val,
									@msg_txt
								);
								IF @rtn_val = 0 THEN
								/*방문신청을 한 사실이 있다면*/
									CALL sp_req_is_visit_request_rejected(
									/*배출자로부터 방문거절을 당했는지 확인한다.*/
										@COLLECTOR_BIDDING_ID,
										IN_DISPOSAL_ORDER_ID,
										@rtn_val,
										@msg_txt
									);
									IF @rtn_val = 0 THEN
									/*배출자로부터 방문거절을 당하지 않았다면 정상처리한다.*/
										CALL sp_req_is_visit_request_already_not_canceled(
										/*수거자가 자신의 방문신청에 대하여 이미 취소한 사실이 없는지 검사한다.*/
											@COLLECTOR_BIDDING_ID,
											IN_DISPOSAL_ORDER_ID,
											@rtn_val,
											@msg_txt
										);
                                        IF @rtn_val = 0 THEN
                                        /*수거자가 자신의 방문신청에 대하여 이미 취소한 사실이 없는 경우 정상처리한다.*/
											CALL sp_req_bidding_end_date_expired(
											/*입찰마감일이 종료되었는지 검사한다. 종료되었으면 TRUE, 그렇지 않으면 FALSE반환*/
												IN_DISPOSAL_ORDER_ID,
												@rtn_val,
												@msg_txt
											);
											IF @rtn_val = 0 THEN
											/*입찰마감일이 종료되지 않은 경우*/
												CALL sp_insert_collector_wste_lists(
												/*수거자 등이 입력한 입찰정보를 데이타베이스에 저장한다.*/
													@COLLECTOR_BIDDING_ID,
													IN_DISPOSAL_ORDER_ID,
													@REG_DT,
													IN_BIDDING_DETAILS,
													@rtn_val,
													@msg_txt
												);
												IF @rtn_val = 0 THEN
												/*데이타베이스 입력에 성공한 경우*/
													UPDATE COLLECTOR_BIDDING 
													SET 
														DATE_OF_BIDDING 		= @REG_DT, 
														BID_AMOUNT 				= IN_BID_AMOUNT,  
                                                        /*BID_AMOUNT를 폐기물 견적에서 단가와 수량을 곱한 후 합산한 금액으로 sp_insert_collector_wste_lists의 실행으로 계산을 하고 있으나 
                                                        앱 사용측면에서 페기물 리스트를 업로드 하는것과는 별개로 전체 금액을 입력하고 있으므로 위의 계산결과와는 별개로 BID_AMOUNT통하여 
                                                        입력받은 전체 금액을 데이타베이스에 입력하고 있다. 추후 견적관련 서비스를 수정하게 되면 이 부분은 삭제되어야 한다.*/
														TRMT_METHOD 			= IN_TRMT_METHOD, 
														UPDATED_AT 				= @REG_DT 
													WHERE 
														ID = @COLLECTOR_BIDDING_ID;
													IF ROW_COUNT() = 1 THEN
													/*데이타 입력에 성공하였다면*/
                                                        CALL sp_calc_max_decision_at(
                                                        /*수거자가 배출자의 낙찰통보에 대하여 최종결심할 수 있는 최대시간을 확정한다.*/
															IN_DISPOSAL_ORDER_ID,
                                                            @COLLECTOR_BIDDING_ID
                                                        );
														CALL sp_calc_bidders(
															IN_DISPOSAL_ORDER_ID
														);
														CALL sp_calc_bidding_rank(
															IN_DISPOSAL_ORDER_ID
														);
														SET @rtn_val 		= 0;
														SET @msg_txt 		= 'Success1';
													ELSE
													/*데이타 입력에 실패하였다면 예외처리한다.*/
														SET @rtn_val 		= 23401;
														SET @msg_txt 		= 'Failed to change bid request record';
														SIGNAL SQLSTATE '23000';
													END IF;
												ELSE
												/*데이타베이스 입력에 실패한 경우*/
													SIGNAL SQLSTATE '23000';
												END IF;
											ELSE
											/*입찰마감일이 종료된 경우 예외처리한다.*/
												SIGNAL SQLSTATE '23000';
											END IF;
                                        ELSE
                                        /*수거자가 자신의 방문신청에 대하여 이미 취소한 사실이 존재하는 경우 예외처리한다.*/
											SIGNAL SQLSTATE '23000';
                                        END IF;
									ELSE
									/*배출자로부터 방문거절을 당했다면 예외처리한다.*/
										SIGNAL SQLSTATE '23000';
									END IF;
								ELSE
								/*방문신청을 한 사실이 없는 경우 예외처리한다.*/
									SIGNAL SQLSTATE '23000';
								END IF;
							ELSE
							/*방문종료일이 마감되지 않았으면 입찰가능상태가 아니므로 예외처리한다.*/
								SIGNAL SQLSTATE '23000';
							END IF;
						ELSE
						/*폐기물 배출신청 사이트에 방문의무가 없는 경우*/
							CALL sp_req_collect_bidding_max_id(
								@COLLECTOR_BIDDING_ID
							);
							INSERT INTO COLLECTOR_BIDDING (
								ID, 
								COLLECTOR_ID, 
								DISPOSAL_ORDER_ID, 
								ACTIVE, 
								STATUS_CODE, 
								DATE_OF_BIDDING, 
								BID_AMOUNT, 
								TRMT_METHOD, 
								CREATED_AT, 
								UPDATED_AT
							) VALUES (
								@COLLECTOR_BIDDING_ID, 
								@USER_SITE_ID, 
								IN_DISPOSAL_ORDER_ID, 
								TRUE, 
								2, 
								@REG_DT, 
								IN_BID_AMOUNT, 
								IN_TRMT_METHOD, 
								@REG_DT, 
								@REG_DT
							);
							IF ROW_COUNT() = 1 THEN
							/*데이타베이스 입력에 성공한 경우*/
								INSERT INTO FINAL_BIDDER_MANAGEMENT (
									DISPOSER_ORDER_ID,
                                    COLLECTOR_BIDDING_ID
                                ) VALUES (
									@COLLECTOR_BIDDING_ID, 
									IN_DISPOSAL_ORDER_ID
                                );
                                IF ROW_COUNT() = 1 THEN
									CALL sp_calc_bidders(
										IN_DISPOSAL_ORDER_ID
									);
									SET @rtn_val 		= 0;
									SET @msg_txt 		= 'Success2';
                                ELSE
									SET @rtn_val 		= 23404;
									SET @msg_txt 		= 'Failed to create final bidder management rocord';
									SIGNAL SQLSTATE '23000';
                                END IF;
							ELSE
							/*데이타베이스 입력에 실패한 경우*/
								SET @rtn_val 		= 23402;
								SET @msg_txt 		= 'Failed to create bid record';
								SIGNAL SQLSTATE '23000';
							END IF;
						END IF;
					ELSE
					/*사이트가 수집운반 등의 폐기물 처리권한이 없는 경우에는 예외처리한다.*/
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*사용자가 입찰을 신청할 권한이 없는경우 예외처리한다.*/
					SET @rtn_val 		= 23403;
					SET @msg_txt 		= 'The user does not have the right to apply for a bid';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사이트가 이미 입찰한 내역이 존재하는 경우 예외처리한다.*/
				SIGNAL SQLSTATE '23000';
			END IF;
        ELSE
        /*사이트가 유효한 사업자의 사이트가 아닌 경우*/
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*입찰을 신청하는 사용자가 존재하지 않거나 유효하지 않은 경우*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END