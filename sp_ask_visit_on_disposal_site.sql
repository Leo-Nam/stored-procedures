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

	SET @PUSH_CATEGORY_ID = 3;
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/

    
	CALL sp_req_is_user_collector(
	/*USER가 소속한 사이트가 수집운반업 등 폐기물을 처리할 자격이 있는지 검사한다.*/
		IN_USER_ID,					/*방문요청을 하는 사용자의 고유등록번호(USERS.ID)*/
		@rtn_val,
		@msg_txt
	);
	IF @rtn_val = 0 THEN
	/*USER가 소속한 사이트가 수집운반업 등 폐기물을 처리할 자격이 있는 경우*/   
		/*폐기물 배출 요청 내역이 존재하는지 검사한다.*/
		SELECT COUNT(ID) 
        INTO @DISPOSAL_ORDER_EXISTS 
        FROM SITE_WSTE_DISPOSAL_ORDER 
        WHERE 
			ACTIVE 	= TRUE AND 
            ID 		= IN_DISPOSER_ORDER_ID;
		IF @DISPOSAL_ORDER_EXISTS = 1 THEN
		/*폐기물 배출 요청 내역이 존재하는 경우*/
			CALL sp_req_site_id_of_disposal_order_id(
				IN_DISPOSER_ORDER_ID,
				@DISPOSER_SITE_ID
			);
            SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
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
					CALL sp_req_visit_date_on_disposal_order(
						IN_DISPOSER_ORDER_ID,
						@DISPOSAL_VISIT_START_AT,
						@DISPOSAL_VISIT_END_AT
					);
					SET IN_VISIT_AT = @DISPOSAL_VISIT_END_AT;
					
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
							CALL sp_push_new_visitor_come(
								IN_USER_ID,
								IN_DISPOSER_ORDER_ID,
                                @PUSH_CATEGORY_ID,
								@json_data,
								@rtn_val,
								@msg_txt
							);
                            IF @rtn_val = 0 THEN
								CALL sp_calc_bidder_and_prospective_visitors(
									IN_DISPOSER_ORDER_ID
								);
							ELSE
								SIGNAL SQLSTATE '23000';
                            END IF;
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
							CALL sp_push_new_visitor_come(
								IN_USER_ID,
								IN_DISPOSER_ORDER_ID,
                                @PUSH_CATEGORY_ID,
								@json_data,
								@rtn_val,
								@msg_txt
							);
                            IF @rtn_val = 0 THEN
								CALL sp_calc_bidder_and_prospective_visitors(
									IN_DISPOSER_ORDER_ID
								);
							ELSE
								SIGNAL SQLSTATE '23000';
                            END IF;
						ELSE
						/*정상적으로 입력되지 않은 경우*/
							SIGNAL SQLSTATE '23000';
						END IF;
					END IF;
				ELSE
				/*수집운반업자등이 방문신청을 할 수 없는 경우*/
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*방문신청을 하는 사이트가 자신이 배출한 사이트인 경우에는 예외처리한다.*/
				SET @rtn_val 		= 23109;
				SET @msg_txt 		= 'Requests for visits are not allowed for self-bidding cases';
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
    
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END