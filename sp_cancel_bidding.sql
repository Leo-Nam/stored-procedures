CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_cancel_bidding`(
	IN IN_USER_ID					BIGINT,				/*입력값 : 사용자 고유등록번호(USERS.ID)*/
	IN IN_COLLECT_BIDDING_ID		BIGINT				/*입력값 : 입찰 고유등록번호(COLLECTOR_BIDDING.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_cancel_bidding
Input param 	: 3개
Output param 	: 3개
Job 			: 폐기물 수집업자 등의 이전 입찰을 취소한다.
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.29
Version			: 0.0.4
AUTHOR 			: Leo Nam
Change			: COLLECTOR_BIDDING의 CANCEL_BIDDING 칼럼 상태를 TRUE로 변경함으로써 입찰을 포기하는 상태로 전환함(0.0.2)
				: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.3)
				: 서브 프로시저의 데이타 반환타입 통일(0.0.4)
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
    
	SET @PUSH_CATEGORY_ID = 13;
    CALL sp_req_current_time(@REG_DT);
    
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
			IN_COLLECT_BIDDING_ID,
			@DISPOSAL_ORDER_ID
		);
		
		CALL sp_req_bidding_end_date_expired(
		/*입찰마감일이 종료되었는지 검사한다. 종료되었으면 TRUE, 그렇지 않으면 FALSE반환*/
			@DISPOSAL_ORDER_ID,
			@rtn_val,
			@msg_txt
		);
		IF @rtn_val = 0 THEN
		/*입찰마감일이 종료되지 않은 경우*/
            SELECT AFFILIATED_SITE INTO @USER_SITE_ID 
            FROM USERS 
            WHERE ID = IN_USER_ID;
            IF @USER_SITE_ID IS NOT NULL THEN
				SELECT COUNT(ID) 
				INTO @CHK_COUNT 
				FROM COLLECTOR_BIDDING 
				WHERE 
					ID = IN_COLLECT_BIDDING_ID AND
					DATE_OF_BIDDING IS NOT NULL;
				IF @CHK_COUNT= 1 THEN
				/*사이트가 이전에 입찰한 사실이 있는 경우에는 입찰취소가 가능함*/
					SET @PUSH_CATEGORY_ID = 15;
					CALL sp_push_collector_cancel_or_giveup_bidding(
						IN_USER_ID,
						@DISPOSAL_ORDER_ID,
						IN_COLLECT_BIDDING_ID,
						@PUSH_CATEGORY_ID,
						@json_data,
						@rtn_val,
						@msg_txt
					);
					SELECT GIVEUP_BIDDING INTO @GIVEUP_BIDDING 
                    FROM COLLECTOR_BIDDING 
                    WHERE ID = IN_COLLECT_BIDDING_ID;
                    IF @GIVEUP_BIDDING = FALSE THEN
						SELECT CANCEL_BIDDING INTO @CANCEL_BIDDING 
                        FROM COLLECTOR_BIDDING 
                        WHERE ID = IN_COLLECT_BIDDING_ID;
						IF @CANCEL_BIDDING = FALSE THEN
							UPDATE COLLECTOR_BIDDING 
							SET 
								CANCEL_BIDDING 		= TRUE, 
								CANCEL_BIDDING_AT 	= @REG_DT , 
								UPDATED_AT		 	= @REG_DT 
							WHERE ID 				= IN_COLLECT_BIDDING_ID;
							/*입찰신청을 취소사태(비활성상태)로 변경한다.*/
							IF ROW_COUNT() = 0 THEN
							/*데이타베이스 입력에 실패한 경우*/
								SET @rtn_val 		= 23801;
								SET @msg_txt 		= 'db error occurred during bid cancellation';
								SIGNAL SQLSTATE '23000';
							ELSE
							/*데이타베이스 입력에 성공한 경우*/                                
								SELECT BIDDING_RANK INTO @BIDDING_RANK
                                FROM COLLECTOR_BIDDING
                                WHERE ID = IN_COLLECT_BIDDING_ID;
                                IF @BIDDING_RANK <= 2 THEN
									IF @BIDDING_RANK = 1 THEN
										UPDATE SITE_WSTE_DISPOSAL_ORDER
                                        SET 
											COLLECTOR_MAX_DECISION_AT 	= @REG_DT,
											MAX_SELECT_AT 				= @REG_DT,
                                            UPDATED_AT					= @REG_DT
                                        WHERE ID 						= @DISPOSAL_ORDER_ID;
									ELSE
										UPDATE SITE_WSTE_DISPOSAL_ORDER
                                        SET 
											COLLECTOR_MAX_DECISION2_AT 	= @REG_DT,
											MAX_SELECT2_AT 				= @REG_DT,
                                            UPDATED_AT					= @REG_DT
                                        WHERE ID 						= @DISPOSAL_ORDER_ID;
									END IF;
									UPDATE COLLECTOR_BIDDING
									SET 
										MAX_DECISION_AT = @REG_DT,
										UPDATED_AT		= @REG_DT
									WHERE ID = IN_COLLECT_BIDDING_ID;
                                    CALL sp_calc_bidders(
										@DISPOSAL_ORDER_ID
                                    );
									SET @rtn_val 		= 0;
									SET @msg_txt 		= 'Success11122';
                                END IF;
							END IF;
                        ELSE
							SET @rtn_val 		= 23805;
							SET @msg_txt 		= 'already canceled the bidding';
							SIGNAL SQLSTATE '23000';
                        END IF;
                    ELSE
						SET @rtn_val 		= 23804;
						SET @msg_txt 		= 'already given up the bidding';
						SIGNAL SQLSTATE '23000';
                    END IF;
				ELSE
				/*사이트가 이전에 입찰한 사실이 없는 경우에는 입찰권을 포기하게 함*/
					SET @PUSH_CATEGORY_ID = 13;
					CALL sp_push_collector_cancel_or_giveup_bidding(
						IN_USER_ID,
						@DISPOSAL_ORDER_ID,
						IN_COLLECT_BIDDING_ID,
						@PUSH_CATEGORY_ID,
						@json_data,
						@rtn_val,
						@msg_txt
					);
					SELECT CANCEL_BIDDING INTO @CANCEL_BIDDING 
                    FROM COLLECTOR_BIDDING 
                    WHERE ID = IN_COLLECT_BIDDING_ID;
                    IF @CANCEL_BIDDING = FALSE THEN
						SELECT GIVEUP_BIDDING INTO @GIVEUP_BIDDING 
                        FROM COLLECTOR_BIDDING 
                        WHERE ID = IN_COLLECT_BIDDING_ID;
						IF @GIVEUP_BIDDING = FALSE THEN
							UPDATE COLLECTOR_BIDDING 
							SET 
								GIVEUP_BIDDING 		= TRUE, 
								GIVEUP_BIDDING_AT 	= @REG_DT,
                                UPDATED_AT			= @REG_DT
							WHERE ID 				= IN_COLLECT_BIDDING_ID;
							/*입찰신청권한을 포기한다.*/
							IF ROW_COUNT() = 0 THEN
							/*데이타베이스 입력에 실패한 경우*/
								SET @rtn_val 		= 23802;
								SET @msg_txt 		= 'db error occurred during bid cancellation';
								SIGNAL SQLSTATE '23000';
							ELSE
							/*데이타베이스 입력에 성공한 경우*/                             
								SELECT BIDDING_RANK INTO @BIDDING_RANK
                                FROM COLLECTOR_BIDDING
                                WHERE ID = IN_COLLECT_BIDDING_ID;
                                IF @BIDDING_RANK <= 2 THEN
									IF @BIDDING_RANK = 1 THEN
										UPDATE SITE_WSTE_DISPOSAL_ORDER
                                        SET 
											COLLECTOR_MAX_DECISION_AT 	= @REG_DT,
											MAX_SELECT_AT 				= @REG_DT,
                                            UPDATED_AT					= @REG_DT
                                        WHERE ID 						= @DISPOSAL_ORDER_ID;
									ELSE
										UPDATE SITE_WSTE_DISPOSAL_ORDER
                                        SET 
											COLLECTOR_MAX_DECISION2_AT 	= @REG_DT,
											MAX_SELECT2_AT 				= @REG_DT,
                                            UPDATED_AT					= @REG_DT
                                        WHERE ID 						= @DISPOSAL_ORDER_ID;
									END IF;
									UPDATE COLLECTOR_BIDDING
									SET 
										MAX_DECISION_AT = @REG_DT,
										UPDATED_AT		= @REG_DT
									WHERE ID = IN_COLLECT_BIDDING_ID;
                                    CALL sp_calc_bidders(
										@DISPOSAL_ORDER_ID
                                    );
									SET @rtn_val 		= 0;
									SET @msg_txt 		= 'Success11122765';
                                END IF;
							END IF;
                        ELSE
							SET @rtn_val 		= 23807;
							SET @msg_txt 		= 'already given up the bidding';
							SIGNAL SQLSTATE '23000';
                        END IF;
                    ELSE
						SET @rtn_val 		= 23806;
						SET @msg_txt 		= 'already canceled the bidding';
						SIGNAL SQLSTATE '23000';
                    END IF;
				END IF;
            ELSE
				SET @rtn_val 		= 23803;
				SET @msg_txt 		= 'user site does not exist';
				SIGNAL SQLSTATE '23000';
            END IF;
		ELSE
		/*입찰마감일이 종료된 경우 예외처리한다.*/
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
    /*사용자가 존재하지 않거나 유효하지 않은 경우*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
    CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END