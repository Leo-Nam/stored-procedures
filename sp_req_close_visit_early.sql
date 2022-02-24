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
		SET @json_data 		= NULL;
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
		CALL sp_req_site_id_of_disposal_order_id(
        /*DISPOSAL ORDER 의 배출자 사이트 아이디를 구한다.*/
			IN_DISPOSER_ORDER_ID,
            @DISPOSER_SITE_ID
        );
        
        CALL sp_req_site_id_of_user_reg_id(
        /*사용자가 소속한 사이트의 아이디를 구한다.*/
			IN_USER_ID,
            @USER_SITE_ID,
			@rtn_val,
			@msg_txt
        );
        
		IF @USER_SITE_ID IS NOT NULL THEN
		/*사이트가 유효한 경우*/
			IF @DISPOSER_SITE_ID = @USER_SITE_ID THEN
			/*사용자가 정보변경 대상이 되는 사이트에 소속한 관리자인 경우*/
				CALL sp_req_user_class_by_user_reg_id(
				/*사용자의 권한을 구한다.*/
					IN_USER_ID,
					@USER_CLASS
				);
				IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
				/*관리자가 정보를 변경할 권한이 있는 경우*/
					UPDATE SITE_WSTE_DISPOSAL_ORDER 
                    SET 
						VISIT_EARLY_CLOSING 		= TRUE, 
                        VISIT_EARLY_CLOSED_AT 		= @REG_DT 
                    WHERE ID 						= IN_DISPOSER_ORDER_ID;
					IF ROW_COUNT() = 1 THEN
					/*정보가 성공적으로 변경되었다면*/
						CALL sp_req_policy_direction(
                        /*조기마감이 된 배출신청에 등록된 입찰마감일자를 반환한다.*/
							'bidding_end_date_after_the_visit_early_closing',
                            @policy_direction
                        );
                        SET @PERIOD_UNTIL_BIDDING_END_DATE = CAST(@policy_direction AS UNSIGNED);
                        /*정책으로 결정된 시간을 @PERIOD_UNTIL_BIDDING_END_DATE에 저장한다.*/
                        UPDATE SITE_WSTE_DISPOSAL_ORDER 
                        SET BIDDING_END_AT = IF(
								BIDDING_END_AT <= ADDTIME(
									@REG_DT, 
									CONCAT(@PERIOD_UNTIL_BIDDING_END_DATE, ':00')
								), 
								BIDDING_END_AT, 					
                                /*조건을 만족하는 경우로서 입찰마감일이 현재일로부터 정책으로 결정된 시간 이내인 경우에는 현재 설정된 입찰마감일을 그대로 사용하도록 한다.*/
								ADDTIME(
									@REG_DT, 
									CONCAT(@PERIOD_UNTIL_BIDDING_END_DATE, ':00')
								)				
                                /*조건을 만족하지 않는 경우로서 입찰마감일이 현재일로부터 정책으로 결정된 시간 이후인 경우에는 현재 시간으로부터 정책으로 결정된 시간 이후의 시간으로 입찰마감일을 변경한다.*/
							), VISIT_END_AT = @REG_DT
                        WHERE ID = IN_DISPOSER_ORDER_ID;
                        IF ROW_COUNT() = 1 THEN
                        /*정상적으로 업데이트가 완료된 경우에는 정상처리한다.*/
							SET @rtn_val = 0;
							SET @msg_txt = 'Success';
                        ELSE
                        /*정상적으로 업데이트가 완료되지 않은 경우에는 예외처리한다.*/
							SET @rtn_val = 24304;
							SET @msg_txt = 'Failed to change bid deadline';
							SIGNAL SQLSTATE '23000';
                        END IF;
					ELSE
					/*정보변경에 실패했다면 예외처리한다.*/
						SET @rtn_val = 24301;
						SET @msg_txt = 'failure to close early in DB';
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*관리자가 정보를 변경할 권한이 없는 경우*/
					SET @rtn_val = 24302;
					SET @msg_txt = 'User does not have permission to change information';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사용자가 정보변경 대상이 되는 사이트에 소속한 관리자가 아닌 경우 예외처리한다.*/
				SET @rtn_val = 24303;
				SET @msg_txt = 'The user is not an administrator of the site';
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
		/*사이트가 존재하지 않거나 유효하지 않은 경우*/
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