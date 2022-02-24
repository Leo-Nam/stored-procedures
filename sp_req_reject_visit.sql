CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_reject_visit`(
	IN IN_USER_ID				BIGINT,				/*방문거절을 신청하는 배출자의 관리자 고유등록번호(USERS.ID)*/
	IN IN_DISPOSER_SITE_ID		BIGINT,				/*방문거절을 신청하는 사이트의 고유등록번호(COMP_SITE.ID)*/
    IN IN_COLLECTOR_BIDDING_ID	BIGINT				/*방문거절을 당할 입찰신청번호(COLLECTOR_BIDDING.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_req_reject_visit
Input param 	: 2개
Job 			: 배출자가 수거자의 방문신청을 거절한다.
Update 			: 2022.02.07
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

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
		CALL sp_req_site_id_of_user_reg_id(
        /*사용자가 소속된 사이트의 고유등록번호를 반환한다.*/
			IN_USER_ID,
            @SITE_ID,
            @rtn_val,
            @msg_txt
        );
        IF @rtn_val = 0 THEN
        /*사용자가 사이트에 소속한 경우에는 정상처리한다.*/
			IF @SITE_ID = IN_DISPOSER_SITE_ID THEN
            /*사용자가 배출자 사이트에 소속한 경우에는 정상처리한다.*/
				CALL sp_req_user_class_by_user_reg_id(
                /*사용자의 권한을 반환한다.*/
					IN_USER_ID,
                    @USER_CLASS
                );
                IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
                /*사용자가 업무처리권한을 가진 경우 정상처리한다.*/
					UPDATE COLLECTOR_BIDDING SET RESPONSE_VISIT = FALSE WHERE ID = IN_COLLECTOR_BIDDING_ID;
                    /*수거자의 방문신청을 거절한다.*/
                    IF ROW_COUNT() = 1 THEN
                    /*배출자가 수거자의 방문신청을 성공적으로 처리한 경우*/
						SET @rtn_val = 0;
						SET @msg_txt = 'Success';
                    ELSE
                    /*배출자가 수거자의 방문신청을 성공적으로 처리하지 못한 경우*/
						SET @rtn_val = 29903;
						SET @msg_txt = 'Failure to reject the collector request for visitation';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*사용자가 업무처리권한을 가지지 않은 경우 예외처리한다.*/
					SET @rtn_val = 29902;
					SET @msg_txt = 'User not authorized';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사용자가 배출자 사이트에 소속되지 않은 경우에는 예외처리한다.*/
				SET @rtn_val = 29901;
				SET @msg_txt = 'The user is not affiliated with the disposer site';
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*사용자가 사이트에 소속되지 않은 경우에는 예외처리한다.*/
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
	
END