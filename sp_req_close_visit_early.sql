CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_close_visit_early`(
	IN IN_USER_ID					BIGINT,
	IN IN_DISPOSER_ORDER_ID			BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_close_visit_early
Input param 	: 2개
Job 			: 방문일정을 조기마감한다.
Update 			: 2022.02.14
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data = NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
	
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
	CALL sp_req_user_exists_by_id(
    /*DISPOSER가 존재하면서 활성화된 상태인지 검사한다.*/
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
    /*사용자가 유효한 경우에는 정상처리한다.*/
        
        SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
        
        IF @USER_SITE_ID = 0 THEN
        /*개인사용자인 경우*/
			SELECT DISPOSER_ID INTO @DISPOSER_ID
            FROM SITE_WSTE_DISPOSAL_ORDER
            WHERE ID = IN_DISPOSER_ORDER_ID;
            IF @DISPOSER_ID = IN_USER_ID THEN
            /*배출자가 자신인 경우*/
				CALL sp_req_close_visit_early_without_handler(
					IN_USER_ID,
                    IN_DISPOSER_ORDER_ID,
                    @REG_DT,
                    @rtn_val,
                    @msg_txt,
                    @json_data
                );
                IF @rtn_val = 0 THEN
					CALL sp_push_disposer_close_visit_early(
						IN_DISPOSER_ORDER_ID,
						@PUSH_INFO
					);
					SELECT JSON_ARRAYAGG(
						JSON_OBJECT(
							'PUSH_INFO'	, @PUSH_INFO
						)
					);
					SET @rtn_val = 0;
					SET @msg_txt = 'success';
				ELSE
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*배출자가 자신이 아닌 경우 예외처리한다.*/
				SET @rtn_val = 24302;
				SET @msg_txt = 'The user is not an owner of the disposal order';
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*사업자의 관리자인 경우*/
			CALL sp_req_site_id_of_disposal_order_id(
			/*DISPOSAL ORDER 의 배출자 사이트 아이디를 구한다.*/
				IN_DISPOSER_ORDER_ID,
				@DISPOSER_SITE_ID
			);
            IF @USER_SITE_ID = @DISPOSER_SITE_ID THEN
            /*자신이 소속한 사이트가 배출한 오더인 경우*/
				CALL sp_req_close_visit_early_without_handler(
					IN_USER_ID,
                    IN_DISPOSER_ORDER_ID,
                    @REG_DT,
                    @rtn_val,
                    @msg_txt,
                    @json_data
                );
                IF @rtn_val = 0 THEN
					CALL sp_push_disposer_close_visit_early(
						IN_DISPOSER_ORDER_ID,
						@PUSH_INFO
					);
					SELECT JSON_ARRAYAGG(
						JSON_OBJECT(
							'PUSH_INFO'	, @PUSH_INFO
						)
					);
					SET @rtn_val = 0;
					SET @msg_txt = 'success';
				ELSE
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
			/*사용자가 정보변경 대상이 되는 사이트에 소속한 관리자가 아닌 경우 예외처리한다.*/
				SET @rtn_val = 24301;
				SET @msg_txt = 'The user is not an administrator of the site';
				SIGNAL SQLSTATE '23000';
            END IF;
        END IF;
    ELSE
    /*사용자가 유효하지 않은 경우에는 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END