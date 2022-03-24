CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_disposer_change_discharged_end_at`(
	IN IN_USER_ID						BIGINT,			/*입력값: 배출업체 관리자 아이디(USERS.ID)*/
	IN IN_DISPOSER_ORDER_ID				BIGINT,			/*입력값: 폐기물 입찰등록번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
	IN IN_TRANSACTION_ID				BIGINT,			/*입력값: 폐기물 수거단위작업 코드(WSTE_CLCT_TRMT_TRANSACTION.ID)*/
	IN IN_DISCHARGED_AT					DATETIME		/*입력값: 배출업체가 변경 또는 결정하고자 하는 처리예정일자*/
)
BEGIN

/*
Procedure Name 	: sp_disposer_change_discharged_end_at
Input param 	: 3개
Job 			: 폐기물 배출업체 또는 사용자가 폐기물 처리예정일을 변경 또는 결정한다.
Update 			: 2022.03.25
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
    
	CALL sp_req_user_exists_by_id(
    /*DISPOSER가 존재하면서 활성화된 상태인지 검사한다.*/
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );	
    
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우 정상처리한다*/
		SELECT COUNT(ID) INTO @TRANSACTION_EXISTS FROM WSTE_CLCT_TRMT_TRANSACTION WHERE ID = IN_TRANSACTION_ID;
		IF @TRANSACTION_EXISTS = 1 THEN
		/*트랜잭션이 존재하는 경우 정상처리한다.*/    
			CALL sp_req_site_id_of_transaction_id(
			/*트랜잭션의 양 당사자(배출자와 수거자)의 사이트 등록번호를 반환한다.*/
				IN_TRANSACTION_ID,
				@DISPOSER_SITE_ID,
				@COLLECTOR_SITE_ID
			);
			SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
			SELECT DISPOSAL_ORDER_ID INTO @TRANSACTION_DISPOSER_ORDER_ID FROM WSTE_CLCT_TRMT_TRANSACTION WHERE ID = IN_TRANSACTION_ID;
			IF @TRANSACTION_DISPOSER_ORDER_ID = IN_DISPOSER_ORDER_ID THEN
			/*폐기물등록정보와 연결된 트랜잭션인 경우 정상처리한다.*/
				IF @USER_SITE_ID = 0 THEN
				/*개인사용자인 경우*/
					SELECT DISPOSER_ID INTO @DISPOSER_ID FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = IN_DISPOSER_ORDER_ID;
					IF @DISPOSER_ID = IN_USER_ID THEN
					/*사용자가 배출등록자와 동일한 경우 정상처리한다.*/
						CALL sp_req_current_time(@REG_DT);
						UPDATE WSTE_CLCT_TRMT_TRANSACTION 
						SET 
							COLLECT_ASK_END_AT = IN_DISCHARGED_AT,
							UPDATED_AT = @REG_DT
						WHERE ID = IN_TRANSACTION_ID;
						IF ROW_COUNT() = 1 THEN
							SET @rtn_val 		= 0;
							SET @msg_txt 		= 'success';
						ELSE
							SET @rtn_val 		= 34907;
							SET @msg_txt 		= 'failed to update record';
							SIGNAL SQLSTATE '23000';
						END IF;
					ELSE
					/*사용자가 배출등록자와 동일하지 않은 경우 예외처리한다.*/
						SET @rtn_val 		= 34906;
						SET @msg_txt 		= 'Users are not waste discharger';
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*사업자사용자인 경우*/
					SELECT SITE_ID INTO @DISPOSER_SITE_ID FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = IN_DISPOSER_ORDER_ID;
					IF @USER_SITE_ID = @DISPOSER_SITE_ID THEN
					/*사용자가 폐기물배출사이트의 소속인 경우에는 정상처리한다.*/
						SELECT CLASS INTO @USER_CLASS FROM USERS WHERE ID = IN_USER_ID;
						IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
						/*사용자에게 권한이 있는 경우에는 정상처리한다.*/
							CALL sp_req_current_time(@REG_DT);
							UPDATE WSTE_CLCT_TRMT_TRANSACTION 
							SET 
								COLLECT_ASK_END_AT = IN_DISCHARGED_AT,
								UPDATED_AT = @REG_DT
							WHERE ID = IN_TRANSACTION_ID;
							IF ROW_COUNT() = 1 THEN
								SET @rtn_val 		= 0;
								SET @msg_txt 		= 'success';
							ELSE
								SET @rtn_val 		= 34905;
								SET @msg_txt 		= 'failed to update record';
								SIGNAL SQLSTATE '23000';
							END IF;
						ELSE
						/*사용자에게 권한이 없는 경우에는 예외처리한다.*/
							SET @rtn_val 		= 34904;
							SET @msg_txt 		= 'User not authorized';
							SIGNAL SQLSTATE '23000';
						END IF;
					ELSE
					/*사용자가 폐기물배출사이트의 소속이 아닌 경우에는 예외처리한다.*/
						SET @rtn_val 		= 34903;
						SET @msg_txt 		= 'Users does not belong to the site';
						SIGNAL SQLSTATE '23000';
					END IF;
				END IF;
			ELSE
			/*폐기물등록정보와 연결되지 않은 트랜잭션인 경우 예외처리한다.*/
				SET @rtn_val 		= 34902;
				SET @msg_txt 		= 'different transaction than the waste registry';
				SIGNAL SQLSTATE '23000';
			END IF;
            
        ELSE
		/*트랜잭션이 존재하지 않는 경우 예외처리한다.*/
			SET @rtn_val 		= 34901;
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