CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_reject_bidding`(
	IN IN_USER_ID				BIGINT,				/*수거자의 입찰자격박탈을 신청하는 배출자의 관리자 고유등록번호(USERS.ID)*/
	IN IN_DISPOSER_ORDER_ID		BIGINT,				/*사용자의 배출신청번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
    IN IN_COLLECTOR_BIDDING_ID	BIGINT				/*수거자의 투찰신청번호(COLLECTOR_BIDDING.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_req_reject_bidding
Input param 	: 3개
Job 			: 배출자가 수거자의 투찰신청에 대하여 거절한다
Update 			: 2022.03.19
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
    /*사용자가 존재하면서 활성화된 상태인지 검사한다.*/
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우 정상처리한다.*/
		SELECT AFFILIATED_SITE INTO @USER_SITE_ID 
        FROM USERS 
        WHERE ID = IN_USER_ID;
        IF @USER_SITE_ID > 0 THEN
        /*사용자가 사이트에 소속한 경우(사업자의 관리자인 경우)에는 정상처리한다.*/
			SELECT SITE_ID INTO @DISPOSER_SITE_ID 
            FROM SITE_WSTE_DISPOSAL_ORDER 
            WHERE ID = IN_DISPOSER_ORDER_ID;
			IF @USER_SITE_ID = @DISPOSER_SITE_ID THEN
            /*사용자가 배출자 사이트에 소속한 경우에는 정상처리한다.*/
				CALL sp_req_user_class_by_user_reg_id(
                /*사용자의 권한을 반환한다.*/
					IN_USER_ID,
                    @USER_CLASS
                );
                IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
                /*사용자가 업무처리권한을 가진 경우 정상처리한다.*/
					SELECT COUNT(ID) INTO @COLLECTOR_ALREADY_BID 
                    FROM COLLECTOR_BIDDING 
                    WHERE 
						ID = IN_COLLECTOR_BIDDING_ID AND
						DATE_OF_BIDDING IS NOT NULL;
                    IF @COLLECTOR_ALREADY_BID = 1 THEN
                    /*수거자가 투찰을 한 경우에는 정상처리한다.*/
						UPDATE COLLECTOR_BIDDING 
						SET 
							REJECT_BIDDING 		= TRUE, 
							REJECT_BIDDING_AT 	= @REG_DT 
						WHERE ID = IN_COLLECTOR_BIDDING_ID;
						/*수거자의 투찰신청을 거절한다.*/
						IF ROW_COUNT() = 1 THEN
						/*배출자가 수거자의 투찰신청을 성공적으로 거절한 경우*/
							CALL sp_calc_bidding_rank(
								IN_DISPOSER_ORDER_ID
							);
							SET @rtn_val = 0;
							SET @msg_txt = 'Success';
						ELSE
						/*배출자가 수거자의 투찰신청을 성공적으로 거절하지 못한 경우*/
							SET @rtn_val = 34306;
							SET @msg_txt = 'Failed to reject the collector bidding application';
							SIGNAL SQLSTATE '23000';
						END IF;
                    ELSE
                    /*수거자가 투찰을 하지 않은 경우에는 예외처리한다.*/
						SET @rtn_val = 34307;
						SET @msg_txt = 'Collector did not bid';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*사용자가 업무처리권한을 가지지 않은 경우 예외처리한다.*/
					SET @rtn_val = 34305;
					SET @msg_txt = 'User not authorized';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사용자가 배출자 사이트에 소속되지 않은 경우에는 예외처리한다.*/
				SET @rtn_val = 34304;
				SET @msg_txt = 'The user is not affiliated with the disposer site';
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*사용자가 사이트에 소속되지 않은 경우(개인사용자인 경우)*/
			SELECT COUNT(ID) INTO @USER_DISPOSAL_ORDER_EXISTS 
            FROM SITE_WSTE_DISPOSAL_ORDER 
            WHERE 
				DISPOSER_ID 	= IN_USER_ID AND 
                ID 				= IN_DISPOSER_ORDER_ID;
            IF @USER_DISPOSAL_ORDER_EXISTS = 1 THEN
            /*사용자가 배출신청정보의 소유자인 경우 정상처리한다.*/
				SELECT COUNT(ID) INTO @COLLECTOR_APPLICATION_EXISTS 
                FROM COLLECTOR_BIDDING 
                WHERE 
					DISPOSAL_ORDER_ID 	= IN_DISPOSER_ORDER_ID AND 
                    ID 					= IN_COLLECTOR_BIDDING_ID;
                IF @COLLECTOR_APPLICATION_EXISTS = 1 THEN
                /*수거자의 입찰정보가 존재하는 경우 정상처리한다.*/
					SELECT COUNT(ID) INTO @COLLECTOR_ALREADY_BID 
                    FROM COLLECTOR_BIDDING 
                    WHERE 
						ID = IN_COLLECTOR_BIDDING_ID AND
						DATE_OF_BIDDING IS NOT NULL;
                    IF @COLLECTOR_ALREADY_BID = 1 THEN
                    /*수거자가 투찰을 한 경우에는 정상처리한다.*/
						UPDATE COLLECTOR_BIDDING 
						SET 
							REJECT_BIDDING 		= TRUE, 
							REJECT_BIDDING_AT 	= @REG_DT 
						WHERE ID = IN_COLLECTOR_BIDDING_ID;
						/*수거자의 투찰신청을 거절한다.*/
						IF ROW_COUNT() = 1 THEN
						/*배출자가 수거자의 투찰신청을 성공적으로 거절한 경우*/
							CALL sp_calc_bidding_rank(
								IN_DISPOSER_ORDER_ID
							);
							SET @rtn_val = 0;
							SET @msg_txt = 'Success';
						ELSE
						/*배출자가 수거자의 투찰신청을 성공적으로 거절하지 못한 경우*/
							SET @rtn_val = 34303;
							SET @msg_txt = 'Failed to reject the collector bidding application';
							SIGNAL SQLSTATE '23000';
						END IF;
                    ELSE
                    /*수거자가 투찰을 하지 않은 경우에는 예외처리한다.*/
						SET @rtn_val = 34308;
						SET @msg_txt = 'Collector did not bid';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*수거자의 입찰정보가 존재하지 않는 경우 예외처리한다.*/
					SET @rtn_val = 34302;
					SET @msg_txt = 'Collector bidding information does not exist';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사용자가 배출신청정보의 소유자가 아닌 경우 예외처리한다.*/
				SET @rtn_val = 34301;
				SET @msg_txt = 'The user is not a discharge applicant';
				SIGNAL SQLSTATE '23000';
            END IF;
        END IF;
    ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END