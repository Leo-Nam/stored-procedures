CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_reject_bidding_apply`(
	IN IN_USER_ID				BIGINT,				/*수거자의 입찰자격박탈을 신청하는 배출자의 관리자 고유등록번호(USERS.ID)*/
	IN IN_DISPOSER_ORDER_ID		BIGINT,				/*사용자의 배출신청번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
    IN IN_COLLECTOR_BIDDING_ID	BIGINT				/*수거자의 입찰자격박탈을 당할 입찰신청번호(COLLECTOR_BIDDING.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_req_reject_bidding_apply
Input param 	: 3개
Job 			: 배출자가 수거자의 입찰자격을 박탈한다
Update 			: 2022.03.19
Version			: 0.0.2
AUTHOR 			: Leo Nam
Changes			: 입찰자격을 박탈할 때 전체 입찰자를 계산한다.(sp_calc_bidding_rank 실행)(0.0.2)
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
        /*사용자가 사이트에 소속한 경우에는 정상처리한다.*/
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
					UPDATE COLLECTOR_BIDDING 
                    SET 
						REJECT_BIDDING_APPLY 		= TRUE, 
                        REJECT_BIDDING_APPLY_AT 	= @REG_DT 
                    WHERE ID = IN_COLLECTOR_BIDDING_ID;
                    /*수거자의 입찰자격을 박탈한다.*/
                    IF ROW_COUNT() = 1 THEN
                    /*배출자가 수거자의 입찰자격을을 성공적으로 박탈한 경우*/
						CALL sp_calc_bidding_rank(
							IN_DISPOSAL_ORDER_ID
						);
						SET @rtn_val = 0;
						SET @msg_txt = 'Success';
                    ELSE
                    /*배출자가 수거자의 입찰자격을을 성공적으로 박탈하지 못한 경우*/
						SET @rtn_val = 34103;
						SET @msg_txt = 'Failed to disqualify collectors from bidding';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*사용자가 업무처리권한을 가지지 않은 경우 예외처리한다.*/
					SET @rtn_val = 34102;
					SET @msg_txt = 'User not authorized';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사용자가 배출자 사이트에 소속되지 않은 경우에는 예외처리한다.*/
				SET @rtn_val = 34101;
				SET @msg_txt = 'The user is not affiliated with the disposer site';
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*사용자가 사이트에 소속되지 않은 경우에는 예외처리한다.*/
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
					UPDATE COLLECTOR_BIDDING 
                    SET 
						REJECT_BIDDING_APPLY 		= TRUE, 
                        REJECT_BIDDING_APPLY_AT 	= @REG_DT 
                    WHERE ID = IN_COLLECTOR_BIDDING_ID;
                    /*수거자의 입찰자격을 박탈한다.*/
                    IF ROW_COUNT() = 1 THEN
                    /*배출자가 수거자의 입찰자격을을 성공적으로 박탈한 경우*/
						CALL sp_calc_bidding_rank(
							IN_DISPOSAL_ORDER_ID
						);
						SET @rtn_val = 0;
						SET @msg_txt = 'Success';
                    ELSE
                    /*배출자가 수거자의 입찰자격을을 성공적으로 박탈하지 못한 경우*/
						SET @rtn_val = 34106;
						SET @msg_txt = 'Failed to disqualify collectors from bidding';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*수거자의 입찰정보가 존재하지 않는 경우 예외처리한다.*/
					SET @rtn_val = 34105;
					SET @msg_txt = 'Collector bidding information does not exist';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사용자가 배출신청정보의 소유자가 아닌 경우 예외처리한다.*/
				SET @rtn_val = 34104;
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