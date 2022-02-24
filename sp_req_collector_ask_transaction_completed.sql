CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_collector_ask_transaction_completed`(
	IN IN_USER_ID							BIGINT,				/*입력값 : 사용자 고유등록번호(USERS.ID)*/
    IN IN_TRANSACTION_ID					BIGINT				/*입력값 : 트랜잭션 고유등록번호*/
)
BEGIN

/*
Procedure Name 	: sp_req_collector_ask_transaction_completed
Input param 	: 2개
Job 			: 폐기물 처리자가 폐기물 처리 트랜잭션을 완료했음을 보고한다.
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.25
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
            CALL sp_req_site_id_of_user_reg_id(
            /*사용자가 소속하고 있는 사이트의 등록번호를 반환한다.*/
				IN_USER_ID,
                @USER_SITE_ID,
				@rtn_val,
				@msg_txt
            );
        
			IF @rtn_val = 0 THEN
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
						UPDATE WSTE_CLCT_TRMT_TRANSACTION SET WSTE_CLCT_TRMT_TRANSACTION = @REG_DT WHERE ID = IN_TRANSACTION_ID;
						/*트랜잭션 레코드의 완료일자를 현재로 변경한다.*/
						IF ROW_COUNT() = 1 THEN
						/*레코드 변경에 성공한 경우*/
							SET @rtn_val = 0;
							SET @msg_txt = 'Transaction completed successfully';
						ELSE
						/*레코드 변경에 실패한 경우 예외처리한다.*/
							SET @rtn_val = 25401;
							SET @msg_txt = 'Failed to change database record';
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
					SET @msg_txt = 'User does not belong to the collector';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사이트가 존재하지 않거나 유효하지 않은(개인사용자의 경우) 경우*/
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
    
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END