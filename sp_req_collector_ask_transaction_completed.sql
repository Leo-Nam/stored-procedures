CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_collector_ask_transaction_completed`(
	IN IN_USER_ID					BIGINT,								/*입렦값 : 폐기물 처리보고서 작성자(USERS.ID)*/
	IN IN_TRANSACTION_ID			BIGINT,								/*입렦값 : 폐기물 처리작업 코드(WSTE_CLCT_TRMT_TRANSACTION.ID)*/
	IN IN_WSTE_CODE					VARCHAR(8),							/*입렦값 : 폐기물코드(WSTE_CODE.CODE)*/
	IN IN_QUANTITY					FLOAT,								/*입렦값 : 폐기물수량*/
	IN IN_COMPLETED_AT				DATETIME,							/*입렦값 : 폐기물 최종처리일자*/
	IN IN_PRICE						INT,								/*입렦값 : 폐기물 처리가격*/
	IN IN_UNIT						ENUM('Kg','m³','식','전체견적가'),		/*입렦값 : 폐기물 처리단위*/
	IN IN_TRMT_METHOD				VARCHAR(4),							/*입렦값 : 폐기물 처리방법(WSTE_TRMT_METHOD.CODE)*/
	IN IN_WSTE_APPEARANCE			INT,								/*입렦값 : 폐기물 성상(WSTE_APPEARANCE.ID)으로서 1:고상, 2:액상*/
	IN IN_IMG_LIST					JSON								/*입렦값 : 폐기물 처리사진*/
)
BEGIN

/*
Procedure Name 	: sp_req_collector_ask_transaction_completed
Input param 	: 10개
Job 			: 폐기물처리보고서를 작성한다
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

	SET @rtn_val 		= NULL;
	SET @msg_txt 		= NULL;
	SET @json_data 		= NULL;
	SET @PUSH_CATEGORY_ID = 25;
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
		CALL sp_req_transaction_exists(
        /*트랜잭션이 존재하는지 검사한다.*/
			IN_TRANSACTION_ID,
            @TRANSACTION_EXISTS
        );
        IF @TRANSACTION_EXISTS = TRUE THEN
        /*트랜잭션이 존재하는 경우*/
			CALL sp_req_site_id_of_transaction_id(
            /*트랜잭션의 양 당사자(배출자와 수거자)의 사이트 등록번호를 반환한다.*/
				IN_TRANSACTION_ID,
                @DISPOSER_SITE_ID,
                @COLLECTOR_SITE_ID
            );
            SELECT AFFILIATED_SITE 
            INTO @USER_SITE_ID 
            FROM USERS 
            WHERE ID = IN_USER_ID;
            IF @USER_SITE_ID > 0 THEN
			/*사이트가 정상(개인사용자는 제외됨)적인 경우*/
				IF @USER_SITE_ID = @COLLECTOR_SITE_ID THEN
				/*사용자가 수거자 소속의 관리자인 경우*/
					CALL sp_req_user_class_by_user_reg_id(
					/*사용자의 권한을 반환한다.*/
						IN_USER_ID,
						@USER_CLASS
					);
					IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
					/*사용자가 수거자 소속의 권한있는 사용자인 경우*/
						SELECT TRANSACTION_STATE_CODE, DISPOSAL_ORDER_ID, VISIT_END_AT
                        INTO @STATE, @DISPOSER_ORDER_ID, @VISIT_END_AT 
                        FROM V_TRANSACTION_STATE
                        WHERE TRANSACTION_ID = IN_TRANSACTION_ID;
                        IF @STATE = 221 THEN
							UPDATE WSTE_CLCT_TRMT_TRANSACTION 
							SET 
								COLLECTOR_REPORTED = TRUE,
								COLLECTOR_REPORTED_AT = @REG_DT
							WHERE ID = IN_TRANSACTION_ID;
							IF ROW_COUNT() = 1 THEN
								INSERT INTO TRANSACTION_REPORT (
									TRANSACTION_ID,
									COLLECTOR_SITE_ID,
									DISPOSER_SITE_ID,
									COLLECTOR_MANAGER_ID,
									TRANSACTION_COMPLETED_AT,
									QUANTITY,
									UNIT,
									PRICE,
									WSTE_CODE,
									CREATED_AT,
									UPDATED_AT,
									DISPOSER_ORDER_ID,
                                    TRMT_METHOD,
                                    WSTE_APPEARANCE
								) VALUES (
									IN_TRANSACTION_ID,
									@COLLECTOR_SITE_ID,
									@DISPOSER_SITE_ID,
									IN_USER_ID,
									IN_COMPLETED_AT,
									IN_QUANTITY,
									IN_UNIT,
									IN_PRICE,
									IN_WSTE_CODE,
									@REG_DT,
									@REG_DT,
									@DISPOSER_ORDER_ID,
                                    IN_TRMT_METHOD,
                                    IN_WSTE_APPEARANCE
								);
								IF ROW_COUNT() = 1 THEN   
									SELECT DISPOSAL_ORDER_ID 
                                    INTO @DISPOSER_ORDER_ID 
                                    FROM WSTE_CLCT_TRMT_TRANSACTION 
                                    WHERE ID = IN_TRANSACTION_ID;
									CALL sp_create_site_wste_photo_information(
										@DISPOSER_ORDER_ID,
                                        IN_TRANSACTION_ID,
										@REG_DT,
										'처리',
										IN_IMG_LIST,
										@rtn_val,
										@msg_txt
									);
									IF @rtn_val = 0 THEN
										IF @VISIT_END_AT IS NOT NULL THEN
                                        /*방문일정이 존재하는 경우*/
											IF @VISIT_END_AT <= @REG_DT THEN
											/*방문일정 이후에 보고서를 작성한 경우에는 정상처리한다.*/
												CALL sp_push_collector_ask_transaction_completed(
													IN_USER_ID,
													@DISPOSER_ORDER_ID,
													NULL,
													IN_TRANSACTION_ID,
													@PUSH_CATEGORY_ID,
													@json_data,
													@rtn_val,
													@msg_txt
												);
												IF @rtn_val = 0 THEN
													SELECT VISIT_END_AT INTO @TRANSACTION_VISIT_END_AT
                                                    FROM WSTE_CLCT_TRMT_TRANSACTION
                                                    WHERE ID = IN_TRANSACTION_ID;
                                                    IF @TRANSACTION_VISIT_END_AT IS NOT NULL THEN
														IF @TRANSACTION_VISIT_END_AT >= @REG_DT THEN
															UPDATE WSTE_CLCT_TRMT_TRANSACTION
															SET VISIT_END_AT = @REG_DT
															WHERE ID = IN_TRANSACTION_ID;
															IF ROW_COUNT() = 0 THEN
																SET @rtn_val = 25409;
																SET @msg_txt = 'failed to set visit end date now';
																SIGNAL SQLSTATE '23000';
															END IF;
                                                        END IF;
                                                    END IF;
                                                ELSE
													SIGNAL SQLSTATE '23000';
												END IF;
											ELSE
											/*방문일정중에 보고서를 작성한 경우에는 예외처리한다.*/
												SET @rtn_val = 25408;
												SET @msg_txt = 'Reports can be submitted during the visit schedule';
												SIGNAL SQLSTATE '23000';
											END IF;
                                        ELSE
                                        /*방문일정이 존재하지 않는 경우에는 정상처리한다.*/
											CALL sp_push_collector_ask_transaction_completed(
												IN_USER_ID,
												@DISPOSER_ORDER_ID,
												NULL,
												IN_TRANSACTION_ID,
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
										SIGNAL SQLSTATE '23000';
									END IF;
								ELSE
									SET @rtn_val = 25405;
									SET @msg_txt = 'Failed to change database record';
									SIGNAL SQLSTATE '23000';
								END IF;
							ELSE
								SET @rtn_val = 25401;
								SET @msg_txt = 'Failed to change database record';
								SIGNAL SQLSTATE '23000';
							END IF;
                        ELSE
							SET @rtn_val = 25406;
							SET @msg_txt = CONCAT('Report can be submitted only in 221 state, but now ', @STATE);
							SIGNAL SQLSTATE '23000';
                        END IF;
					ELSE
					/*사용자가 수거자 소속의 권한있는 사용자가 아닌 경우 예외처리한다.*/
						SET @rtn_val = 25404;
						SET @msg_txt = 'User not authorized';
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*사용자가 수거자 소속의 관리자가 아닌 경우 예외처리한다.*/
					SET @rtn_val = 25403;
					SET @msg_txt = CONCAT('User(', @USER_SITE_ID ,') does not belong to the collector(', @COLLECTOR_SITE_ID, ')');
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사이트가 존재하지 않거나 유효하지 않은(개인사용자의 경우) 경우*/
				SET @rtn_val = 25407;
				SET @msg_txt = 'Not for personal use';
				SIGNAL SQLSTATE '23000';
			END IF;
        ELSE
        /*트랜잭션이 존재하지 않는 경우 예외처리한다.*/
			SET @rtn_val = 25402;
			SET @msg_txt = 'Transaction is not found or invalid';
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END