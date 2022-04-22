CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_close_bidding_early`(
	IN IN_USER_ID					BIGINT,
	IN IN_DISPOSER_ORDER_ID			BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_close_bidding_early
Input param 	: 2개
Job 			: 입찰일정을 조기마감한다.
Update 			: 2022.01.24
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
        
		IF @rtn_val = 0 OR @USER_SITE_ID = 0 THEN
		/*사이트가 정상(개인사용자는 제외됨)적인 경우*/
			IF @DISPOSER_SITE_ID = @USER_SITE_ID THEN
			/*사용자가 정보변경 대상이 되는 사이트에 소속한 관리자인 경우*/
				CALL sp_req_user_class_by_user_reg_id(
				/*사용자의 권한을 구한다.*/
				IN_USER_ID,
				@USER_CLASS
				);
				IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
				/*관리자가 정보를 변경할 권한이 있는 경우*/
					CALL sp_req_have_bidding_record(
                    /*수거자가 입찰한 기록이 있는지 검사한다.*/
						IN_DISPOSER_ORDER_ID,
                        @rtn_val,
                        @msg_txt
                    );
                    IF @rtn_val = 0 THEN
                    /*수거자가 입찰한 기록이 존재하는 경우 정상처리한다.*/
						/*SELECT COUNT(ID) INTO @COUNT_OF_REQUEST_OF_BIDDING FROM COLLECTOR_BIDDING WHERE DATE_OF_BIDDING IS NOT NULL AND DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID;*/
						/*입찰신청한 업체수를 계산하여 @COUNT_OF_REQUEST_OF_BIDDING을 통하여 반환한다.*/
						
						/*IF @COUNT_OF_REQUEST_OF_BIDDING > 0 THEN*/
						/*입찰신청한 업체가 1이상 존재하는 경우*/
							UPDATE SITE_WSTE_DISPOSAL_ORDER 
							SET 
								BIDDING_EARLY_CLOSING 		= TRUE, 
								BIDDING_EARLY_CLOSED_AT 	= @REG_DT, 
								BIDDING_END_AT 				= @REG_DT
							WHERE ID = IN_DISPOSER_ORDER_ID;
							IF ROW_COUNT() = 1 THEN
							/*정보가 성공적으로 변경되었다면*/
								CALL sp_calc_max_decision_at(
								/*배출자가 입찰을 조기종료함으로써 모든 수거자의 최대결심일자를 변경적용한다.*/
									IN_DISPOSER_ORDER_ID,
                                    NULL,
                                    @REG_DT
                                );
								CALL sp_calc_bidding_rank(
									IN_DISPOSER_ORDER_ID
								);
								CALL sp_calc_bidder_and_prospective_visitors(
									IN_DISPOSER_ORDER_ID
								);
								SET @PUSH_CATEGORY_ID = 18;
								CALL sp_push_disposer_close_bidding_early(
									IN_USER_ID,
									IN_DISPOSER_ORDER_ID,
									@PUSH_CATEGORY_ID,
									@json_data,
									@rtn_val,
									@msg_txt
								);
								IF @rtn_val > 0 THEN
									SIGNAL SQLSTATE '23000';
								END IF;
							ELSE
							/*정보변경에 실패했다면 예외처리한다.*/
								SET @rtn_val = 24501;
								SET @msg_txt = 'failure to close early';
								SIGNAL SQLSTATE '23000';
							END IF;
                        /*ELSE*/
						/*입찰신청한 업체가 존재하지 않는 경우*/
						/*	SET @rtn_val = 24504;
							SET @msg_txt = 'The company requested to bid does not exist';
                        END IF;*/
                    ELSE
                    /*수거자가 입찰한 기록이 존재하지 않는 경우 예외처리한다.*/
						SIGNAL SQLSTATE '23000';
                    END IF;
				ELSE
				/*관리자가 정보를 변경할 권한이 없는 경우*/
					SET @rtn_val = 24502;
					SET @msg_txt = 'User does not have permission to change information';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사용자가 정보변경 대상이 되는 사이트에 소속한 관리자가 아닌 경우 예외처리한다.*/
				SET @rtn_val = 24503;
				SET @msg_txt = 'The user is not an administrator of the site';
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
		/*사이트가 존재하지 않거나 유효하지 않은(개인사용자의 경우) 경우*/
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
    /*사용자가 유효하지 않은 경우에는 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END