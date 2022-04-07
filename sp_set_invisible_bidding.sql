CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_set_invisible_bidding`(
	IN IN_USER_ID					BIGINT,
	IN IN_COLLECTOR_BIDDING_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_set_invisible_bidding
Input param 	: 2개
Job 			: 수거자가 자신의 bidding을 화면에서 보이지 않도록 처리한다.
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
			SELECT A.COLLECTOR_ID
            INTO @COLLECTOR_SITE_ID
			FROM COLLECTOR_BIDDING
			WHERE ID = IN_COLLECTOR_BIDDING_ID;
            
            SELECT AFFILIATED_SITE, CLASS INTO @USER_SITE_ID, @USER_CLASS
            FROM USERS
            WHERE ID = IN_USER_ID;
            IF @COLLECTOR_SITE_ID = @USER_SITE_ID THEN
            /*사용자가 수거자 소속인 경우에는 정상처리한다.*/
				IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
                /*사용자에게 권한이 있는 경우 정상처리한다.*/
					UPDATE COLLECTOR_BIDDING
					SET 
						BIDDING_VISIBLE = FALSE,
						BIDDING_VISIBLE_CHANGED_AT = @REG_DT,
						UPDATED_AT = @REG_DT
					WHERE ID = IN_COLLECTOR_BIDDING_ID;
                ELSE
                /*사용자에게 권한이 없는 경우 예외처리한다.*/
					SET @rtn_val = 36203;
					SET @msg_txt = 'users are not authorized';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사용자가 수거자 소속이 아닌 경우에는 예외처리한다.*/
				SET @rtn_val = 36202;
				SET @msg_txt = 'user does not belong to the collector';
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*투찰한 내역이 존재하지 않는 경우 예외처리한다.*/
			SET @rtn_val = 36201;
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