CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_set_invisible_order`(
	IN IN_USER_ID					BIGINT,
	IN IN_COLLECTOR_BIDDING_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_set_visible_order
Input param 	: 3개
Job 			: 배출자가 삭제처리한 오더에 대하여 수거자가 자신의 화면에 나타나지 않게 한다. 수거자(사업자, 개인은 안됨)에게만 가능한 서비스임
Update 			: 2022.04.04
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
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );    
    IF @rtn_val = 0 THEN
    /*사용자가 유효한 경우에는 정상처리한다.*/	
		SELECT COUNT(ID) INTO @BIDDING_EXISTS
        FROM COLLECTOR_BIDDING
        WHERE ID = IN_COLLECTOR_BIDDING_ID;
        IF @BIDDING_EXISTS = 1 THEN
        /*투찰한 내역이 존재하는 경우 정상처리한다.*/
			SELECT A.COLLECTOR_ID, A.DISPOSAL_ORDER_ID, B.IS_DELETED
            INTO @COLLECTOR_SITE_ID, @DISPOSER_ORDER_ID, @ORDER_DELETED
			FROM COLLECTOR_BIDDING A 
            LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B
            ON A.DISPOSAL_ORDER_ID = B.ID
			WHERE ID = IN_COLLECTOR_BIDDING_ID;
            
            SELECT AFFILEATED_SITE, CLASS INTO @USER_SITE_ID, @USER_CLASS
            FROM USERS
            WHERE ID = IN_USER_ID;
            IF @COLLECTOR_SITE_ID = @USER_SITE_ID THEN
            /*사용자가 수거자 소속인 경우에는 정상처리한다.*/
				IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
                /*사용자에게 권한이 있는 경우 정상처리한다.*/
					IF @ORDER_DELETED = TRUE THEN
                    /*배출자가 자신의 오더를 삭제한 경우 정상처리한다.*/
						UPDATE COLLECTOR_BIDDING
						SET 
							ORDER_VISIBLE = FALSE,
							VISIBLE_CHANGED_AT = @REG_DT,
							UPDATED_AT = @REG_DT
						WHERE ID = IN_COLLECTOR_BIDDING_ID;
                    ELSE
                    /*배출자가 자신의 오더를 삭제하지 않은 경우 예외처리한다.*/
						SET @rtn_val = 36104;
						SET @msg_txt = 'The order is not deleted by the emitter';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*사용자에게 권한이 없는 경우 예외처리한다.*/
					SET @rtn_val = 36103;
					SET @msg_txt = 'users are not authorized';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사용자가 수거자 소속이 아닌 경우에는 예외처리한다.*/
				SET @rtn_val = 36102;
				SET @msg_txt = 'user does not belong to the collector';
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*투찰한 내역이 존재하지 않는 경우 예외처리한다.*/
			SET @rtn_val = 36101;
			SET @msg_txt = 'No bidding history';
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*사용자가 유효하지 않은 경우에는 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END