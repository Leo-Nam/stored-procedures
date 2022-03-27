CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_collector_response_to_discharged_end_at`(
	IN IN_USER_ID						BIGINT,			/*입력값: 수거업체 관리자 아이디(USERS.ID)*/
	IN IN_TRANSACTION_ID				BIGINT,			/*입력값: 폐기물 수거단위작업 코드(WSTE_CLCT_TRMT_TRANSACTION.ID)*/
	IN IN_RESPONSE						TINYINT			/*입력값: 배출업체의 최종처리일 요청에 대한 수거업체의 응답으로서 수락인 경우에는 TRUE, 거절인 경우에는 FALSE*/
)
BEGIN

/*
Procedure Name 	: sp_collector_response_to_discharged_end_at
Input param 	: 3개
Job 			: 폐기물 수거업체가 배출업체가 결정한 폐기물 최종처리일자까지 폐기물을 수거할지의 여부를 결정 통보한다.
Update 			: 2022.03.24
Version			: 0.0.1
AUTHOR 			: Leo Nam
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
	CALL sp_req_user_exists_by_id(
    /*DISPOSER가 존재하면서 활성화된 상태인지 검사한다.*/
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );	
    
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우 정상처리한다*/
		SELECT COUNT(ID) 
        INTO @TRANSACTION_EXISTS 
        FROM WSTE_CLCT_TRMT_TRANSACTION 
        WHERE ID = IN_TRANSACTION_ID;
        IF @TRANSACTION_EXISTS = 1 THEN
        /*트랜잭션이 존재한다면 정상처리한다.*/
			CALL sp_req_current_time(@REG_DT);
			UPDATE WSTE_CLCT_TRMT_TRANSACTION 
			SET 
				ACCEPT_ASK_END = IN_RESPONSE,
				ACCEPT_ASK_END_AT = @REG_DT,
				UPDATED_AT = @REG_DT
			WHERE ID = IN_TRANSACTION_ID;
			IF ROW_COUNT() = 1 THEN
				IF IN_RESPONSE IS NOT NULL THEN
					IF IN_RESPONSE = TRUE THEN
					/*수거업체가 배출자의 수거요청일을 받아들이면서 수락하는 경우에는 계약이 정상적으로 처리되는 것이므로 
					WSTE_CLCT_TRMT_TRANSACTION의 COLLECT_ASK_END_AT에 수거요청일을 기록하고 IN_PROCESS를 TRUE로 처리한다.
					다만 기존에 같은 DISPOSAL_ORDER_ID와 COLLECTOR_BIDDING_ID을 공유하는 트랜잭션 중에서 IN_PROCESS = TRUE가 있는 경우에는
					예외처리해야한다.*/
						SELECT DISPOSAL_ORDER_ID, COLLECTOR_BIDDING_ID, COLLECTOR_SITE_ID 
						INTO @DISPOSAL_ORDER_ID, @COLLECTOR_BIDDING_ID, @COLLECTOR_SITE_ID 
						FROM WSTE_CLCT_TRMT_TRANSACTION 
						WHERE ID = IN_TRANSACTION_ID;
						
						SELECT COUNT(ID) 
						INTO @TRANSACTION_COUNT 
						FROM WSTE_CLCT_TRMT_TRANSACTION 
						WHERE 
							DISPOSAL_ORDER_ID = @DISPOSAL_ORDER_ID AND 
							COLLECTOR_BIDDING_ID = @COLLECTOR_BIDDING_ID AND 
							IN_PROGRESS = TRUE;
						
						SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
                        IF @USER_SITE_ID > 0 THEN
						/*사용자가 사업자의 소속관리자인 경우 정상처리한다.*/
							IF @TRANSACTION_COUNT = 0 THEN
							/*현재 작업이 활성화된 트랜잭션이 존재하지 않는다면 정상처리한다.*/
								IF @COLLECTOR_SITE_ID IS NOT NULL THEN
								/*기존거래인 경우*/
									SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
									IF @USER_SITE_ID = @COLLECTOR_SITE_ID THEN
									/*사용자가 소속한 사이트가 기존거래 사이트인 경우 정상처리한다.*/
										SELECT CLASS INTO @USER_CLASS FROM USERS WHERE ID = IS_USER_ID;
										IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
										/*사용자에게 권한이 있는 경우 정상처리한다.*/
											UPDATE WSTE_CLCT_TRMT_TRANSACTION 
											SET 
												IN_PROGRESS = IN_RESPONSE,
												ACCEPT_ASK_END = IN_RESPONSE,
												ACCEPT_ASK_END_AT = @REG_DT
											WHERE ID = IN_TRANSACTION_ID;
											IF ROW_COUNT() = 1 THEN
											/*수거자의 최종승낙절차가 성공적으로 완료된 경우에는 정상처리한다.*/
												SET @rtn_val 		= 0;
												SET @msg_txt 		= 'success';
											ELSE
											/*수거자의 최종승낙절차에 오류가 발생한 경우에는 예외처리한다.*/
												SET @rtn_val 		= 34811;
												SET @msg_txt 		= 'failed to update record';
												SIGNAL SQLSTATE '23000';
											END IF;
										ELSE
										/*사용자에게 권한이 없는 경우 예외처리한다.*/
											SET @rtn_val 		= 34810;
											SET @msg_txt 		= 'users not authorized';
											SIGNAL SQLSTATE '23000';
										END IF;
									ELSE
									/*사용자가 소속한 사이트가 기존거래 사이트가 아닌 경우 예외처리한다.*/
										SET @rtn_val 		= 34809;
										SET @msg_txt 		= 'users not belong to the site';
										SIGNAL SQLSTATE '23000';
									END IF;
								ELSE
								/*입찰거래인 경우*/
									SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
									SELECT COLLECTOR_ID INTO @COLLECTOR_ID FROM COLLECTOR_BIDDING WHERE ID = @COLLECTOR_BIDDING_ID;
									IF @USER_SITE_ID = @COLLECTOR_ID THEN
									/*사용자가 수집업체의 소속인 경우에는 정상처리한다.*/
										IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
										/*사용자에게 권한이 있는 경우 정상처리한다.*/
											UPDATE WSTE_CLCT_TRMT_TRANSACTION 
											SET 
												IN_PROGRESS = IN_RESPONSE,
												ACCEPT_ASK_END = IN_RESPONSE,
												ACCEPT_ASK_END_AT = @REG_DT
											WHERE ID = IN_TRANSACTION_ID;
											IF ROW_COUNT() = 1 THEN
											/*수거자의 최종승낙절차가 성공적으로 완료된 경우에는 정상처리한다.*/
												SET @rtn_val 		= 0;
												SET @msg_txt 		= 'success';
											ELSE
											/*수거자의 최종승낙절차에 오류가 발생한 경우에는 예외처리한다.*/
												SET @rtn_val 		= 34808;
												SET @msg_txt 		= 'failed to update record';
												SIGNAL SQLSTATE '23000';
											END IF;
                                        ELSE
										/*사용자에게 권한이 없는 경우 예외처리한다.*/
											SET @rtn_val 		= 34807;
											SET @msg_txt 		= 'users not authorized';
											SIGNAL SQLSTATE '23000';
                                        END IF;
									ELSE
									/*사용자가 수집업체의 소속이 아닌 경우에는 예외처리한다.*/
										SET @rtn_val 		= 34806;
										SET @msg_txt 		= 'Not available for individual users';
										SIGNAL SQLSTATE '23000';
									END IF;
								END IF;
							ELSE
							/*현재 작업이 종료되지 않은 트랜잭선이 존재하는 경우에는 예외처리한다.*/
								SET @rtn_val 		= 34805;
								SET @msg_txt 		= 'A transaction currently in progress already exists';
								SIGNAL SQLSTATE '23000';
							END IF;
                        ELSE
						/*사용자가 개인인 경우 예외처리한다.*/
							SET @rtn_val 		= 34804;
							SET @msg_txt 		= 'Not available for individual users';
							SIGNAL SQLSTATE '23000';
                        END IF;
					ELSE
					/*수거업체가 배출자의 수거요청일을 거부하면서 거절하는 경우에는 계약이 체결되지 않는 상태로서 정상처리한다.*/
						SET @rtn_val 		= 0;
						SET @msg_txt 		= 'success';
					END IF;
				ELSE
				/*IN_RESPONSE가 NULL인 경우에는 예외처리한다*/
					SET @rtn_val 		= 34803;
					SET @msg_txt 		= 'Response must be TRUE or FALSE but NULL';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
				SET @rtn_val 		= 34802;
				SET @msg_txt 		= 'failed to update record';
				SIGNAL SQLSTATE '23000';
			END IF;
        ELSE
        /*트랜잭션이 존재하지 않는다면 예외처리한다.*/
			SET @rtn_val 		= 34801;
			SET @msg_txt 		= 'transaction does not exist';
			SIGNAL SQLSTATE '23000';
        END IF;
	ELSE
		SIGNAL SQLSTATE '23000';
    END IF;   
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END