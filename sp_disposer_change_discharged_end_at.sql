CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_disposer_change_discharged_end_at`(
	IN IN_USER_ID						BIGINT,			/*입력값: 배출업체 관리자 아이디(USERS.ID)*/
	IN IN_DISPOSER_ORDER_ID				BIGINT,			/*입력값: 폐기물 입찰등록번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
	IN IN_COLLECTOR_BIDDING_ID			BIGINT,			/*입력값: 수거업체 투찰번호(COLLECTOR_BIDDING.ID)*/
	IN IN_DISCHARGED_AT					DATETIME		/*입력값: 배출업체가 변경 또는 결정하고자 하는 처리예정일자*/
)
BEGIN

/*
Procedure Name 	: sp_disposer_change_discharged_end_at
Input param 	: 4개
Job 			: 폐기물 배출업체 또는 사용자가 폐기물 처리예정일을 변경 또는 결정한다.
Update 			: 2022.03.25
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/		
    
	CALL sp_req_user_exists_by_id(
    /*DISPOSER가 존재하면서 활성화된 상태인지 검사한다.*/
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );	
    
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우 정상처리한다*/
		SELECT AFFILIATED_SITE 
		INTO @USER_SITE_ID 
		FROM USERS 
		WHERE ID = IN_USER_ID;
        
		IF @USER_SITE_ID = 0 THEN
		/*개인사용자인 경우*/
			SELECT DISPOSER_ID, COLLECTOR_ID
			INTO @DISPOSER_ID, @COLLECTOR_ID
			FROM SITE_WSTE_DISPOSAL_ORDER 
			WHERE ID = IN_DISPOSER_ORDER_ID;
			IF @DISPOSER_ID = IN_USER_ID THEN
			/*사용자가 배출등록자와 동일한 경우 정상처리한다.*/
				CALL sp_disposer_change_discharged_end_at_without_handler(
					IN_DISPOSER_ORDER_ID,
					IN_COLLECTOR_BIDDING_ID,
					IN_DISCHARGED_AT,
					@rtn_val,
					@msg_txt
				);
			ELSE
			/*사용자가 배출등록자와 동일하지 않은 경우 예외처리한다.*/
				SET @rtn_val 		= 34903;
				SET @msg_txt 		= 'Users are not waste discharger';
			END IF;
		ELSE
		/*사업자사용자인 경우*/
			SELECT SITE_ID INTO @DISPOSER_SITE_ID FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = IN_DISPOSER_ORDER_ID;
			IF @USER_SITE_ID = @DISPOSER_SITE_ID THEN
			/*사용자가 폐기물배출사이트의 소속인 경우에는 정상처리한다.*/
				SELECT CLASS INTO @USER_CLASS FROM USERS WHERE ID = IN_USER_ID;
				IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
				/*사용자에게 권한이 있는 경우에는 정상처리한다.*/
					CALL sp_disposer_change_discharged_end_at_without_handler(
						IN_DISPOSER_ORDER_ID,
						IN_COLLECTOR_BIDDING_ID,
						IN_DISCHARGED_AT,
						@rtn_val,
						@msg_txt
					);
				ELSE
				/*사용자에게 권한이 없는 경우에는 예외처리한다.*/
					SET @rtn_val 		= 34902;
					SET @msg_txt 		= 'User not authorized';
				END IF;
			ELSE
			/*사용자가 폐기물배출사이트의 소속이 아닌 경우에는 예외처리한다.*/
				SET @rtn_val 		= 34901;
				SET @msg_txt 		= 'Users does not belong to the site';
			END IF;
		END IF;	
    END IF; 
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);	
END