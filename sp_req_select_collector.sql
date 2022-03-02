CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_select_collector`(
	IN IN_USER_ID					BIGINT,
	IN IN_COLLECTOR_BIDDING_ID		BIGINT,
	IN IN_DISPOSER_ORDER_ID			BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_select_collector
Input param 	: 3개
Job 			: 최종낙찰업체에 대한 선정결정을 한다.
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
					SELECT DISPOSAL_ORDER_ID, WINNER 
                    INTO @COLLECTOR_DISPOSAL_ORDER_ID, @WINNER 
                    FROM COLLECTOR_BIDDING 
                    WHERE ID = IN_COLLECTOR_BIDDING_ID;
                    
                    IF @COLLECTOR_DISPOSAL_ORDER_ID IS NOT NULL THEN
                    /*입찰에 참여한 수거자의 입찰등록번호가 존재하는 경우 정상처리한다.*/
						IF @COLLECTOR_DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID THEN
                        /*배출자의 폐기물 입찰에 등록한 수거자의 입찰정보인 경우 정상처리한다.*/
							IF @WINNER = TRUE THEN
                            /*수거자가 최종낙찰자격을 갖추었다면 정상처리한다.*/
								UPDATE COLLECTOR_BIDDING SET SELECTED = TRUE, SELECTED_AT = @REG_DT WHERE ID = IN_COLLECTOR_BIDDING_ID;
								IF ROW_COUNT() = 1 THEN
								/*정보가 성공적으로 변경되었다면*/
									UPDATE SITE_WSTE_DISPOSAL_ORDER SET SELECTED = IN_COLLECTOR_BIDDING_ID, SELECTED_AT = @REG_DT WHERE ID = IN_DISPOSER_ORDER_ID;
									IF ROW_COUNT() = 1 THEN
										SET @rtn_val = 0;
										SET @msg_txt = 'success';
									ELSE
										SET @rtn_val = 24604;
										SET @msg_txt = 'Failure to record collector selection information';
										SIGNAL SQLSTATE '23000';
									END IF;
								ELSE
								/*정보변경에 실패했다면 예외처리한다.*/
									SET @rtn_val = 24601;
									SET @msg_txt = 'Failed to select final collector';
									SIGNAL SQLSTATE '23000';
								END IF;
                            ELSE
                            /*수거자가 최종낙찰자격을 갖추지 못한경우에는 예외처리한다.*/
								SET @rtn_val = 24607;
								SET @msg_txt = 'Collector is ineligible for successful bid selection';
								SIGNAL SQLSTATE '23000';
                            END IF;
                        ELSE
                        /*배출자의 폐기물 입찰에 등록한 수거자의 입찰정보가 아닌 경우 예외처리한다.*/
							SET @rtn_val = 24606;
							SET @msg_txt = 'Collectors bidding information does not exist';
							SIGNAL SQLSTATE '23000';
                        END IF;
                    ELSE
                    /*입찰에 참여한 수거자의 입찰등록번호가 존재하지 않는 경우 예외처리한다.*/
						SET @rtn_val = 24605;
						SET @msg_txt = 'Collectors bidding information does not exist';
						SIGNAL SQLSTATE '23000';
                    END IF;
				ELSE
				/*관리자가 정보를 변경할 권한이 없는 경우*/
					SET @rtn_val = 24602;
					SET @msg_txt = 'User does not have permission to change information';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사용자가 정보변경 대상이 되는 사이트에 소속한 관리자가 아닌 경우 예외처리한다.*/
				SET @rtn_val = 24603;
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