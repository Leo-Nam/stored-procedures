CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_transaction_report`(
	IN IN_USER_ID					BIGINT,						/*입렦값 : 폐기물 처리보고서 작성자(USERS.ID)*/
	IN IN_TRANSACTION_ID			BIGINT						/*입렦값 : 폐기물 처리작업 코드(WSTE_CLCT_TRMT_TRANSACTION.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_req_transaction_report
Input param 	: 8개
Job 			: 폐기물처리보고서를 열람한다
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
            SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
			SELECT DISPOSAL_ORDER_ID INTO @TRANSACTION_DISPOSER_ORDER_ID FROM WSTE_CLCT_TRMT_TRANSACTION WHERE ID = IN_TRANSACTION_ID;
            IF @USER_SITE_ID = 0 THEN
            /*개인배출자인 경우*/
				SELECT DISPOSER_ID INTO @DISPOSER_ID FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = @TRANSACTION_DISPOSER_ORDER_ID;
                IF @DISPOSER_ID = IN_USER_ID THEN
                /*사용자에게 권한이 있는 경우 정상처리한다.*/
					SELECT ID INTO @TRANSACTION_REPORT_ID FROM TRANSACTION_REPORT WHERE TRANSACTION_ID = IN_TRANSACTION_ID;
					CALL sp_req_transaction_report_without_handler(
						@TRANSACTION_REPORT_ID,
                        @rtn_val,
                        @msg_txt,
                        @json_data
                    );
                    IF @rtn_val > 0 THEN
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*사용자에게 권한이 없는 경우 예외처리한다.*/
					SET @rtn_val = 35001;
					SET @msg_txt = 'User not authorized';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사업자배출자인 경우*/
				IF @DISPOSER_SITE_ID = @USER_SITE_ID THEN
                /*사용자가 배출자 사이트의 관리자인 경우 정상처리한다.*/
					SELECT CLASS INTO @USER_CLASS FROM USERS WHERE ID = IN_USER_ID;
                    IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
                    /*사용자에게 권한이 있는 경우 정상처리한다.*/
						SELECT ID INTO @TRANSACTION_REPORT_ID FROM TRANSACTION_REPORT WHERE TRANSACTION_ID = IN_TRANSACTION_ID;
						CALL sp_req_transaction_report_without_handler(
							@TRANSACTION_REPORT_ID,
							@rtn_val,
							@msg_txt,
							@json_data
						);
						IF @rtn_val > 0 THEN
							SIGNAL SQLSTATE '23000';
						END IF;
                    ELSE
					/*사용자에게 권한이 없는 경우 예외처리한다.*/
						SET @rtn_val = 35002;
						SET @msg_txt = 'User not authorized';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*사용자가 배출자 사이트의 관리자가 아닌 경우 예외처리한다.*/
					SET @rtn_val = 35003;
					SET @msg_txt = 'User does not belong to the emitter';
					SIGNAL SQLSTATE '23000';
                END IF;
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