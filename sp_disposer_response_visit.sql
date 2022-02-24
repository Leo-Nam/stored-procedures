CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_disposer_response_visit`(
	IN IN_USER_ID					BIGINT,						/*입력값 : 취소신청을 하는 사용자의 고유등록번호(USERS.ID)*/
	IN IN_COLLECTOR_BIDDING_ID		BIGINT,						/*입력값 : sp_req_disposal_order_details에서 반환된 업체정보 JSON데이타의 ID(COLLECTOR_BIDDING_ID)임*/
	IN IN_RESPONSE					TINYINT						/*입력값 : 수락인 경우 TRUE, 거절인 경우 FALSE*/
)
BEGIN

/*
Procedure Name 	: sp_disposer_reject_visit
Input param 	: 2개
Job 			: 배출자가 수거자의 방문신청을 응답(수락/거절)한다.
Update 			: 2022.01.28
Version			: 0.0.2
AUTHOR 			: Leo Nam
				: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.2)
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
    /*사용자가 존재하는 사용자인 경우 정상처리한다.*/
		CALL sp_req_site_id_of_user_reg_id(
		/*사용자가 소속하고 있는 사이트의 고유등록번호를 반환한다.*/
			IN_USER_ID,
			@USER_SITE_ID,
			@rtn_val,
			@msg_txt
		);
		IF @USER_SITE_ID IS NOT NULL THEN
		/*사이트가 유효한 경우 경우*/
			CALL sp_req_disposer_site_id_of_collector_bidding_id(
			/*입찰신청을 한 배출자의 사이트 등록번호를 반환한다.*/
				IN_COLLECTOR_BIDDING_ID,
				@DISPOSER_SITE_ID
			);
			
			IF @USER_SITE_ID = @DISPOSER_SITE_ID THEN
			/*사용자가 배출자 사이트의 소속인 경우에는 정상처리한다.*/
				CALL sp_req_user_class_by_user_reg_id(
				/*사용자의 권한(CLASS)를 반환한다.*/
					IN_USER_ID,
					@USER_CLASS
				);
				IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
				/*사용자에게 권한이 있는 경우 정상처리한다.*/
					UPDATE COLLECTOR_BIDDING SET RESPONSE_VISIT = FALSE, RESPONSE_VISIT_AT = @REG_DT WHERE ID = IN_COLLECTOR_BIDDING_ID;
					/*사용자가 해당 수거자의 방문에 대하여 거절의사를 표시한다.*/
					IF ROW_COUNT() = 1 THEN
					/*정보변경에 성공한 경우*/
						SET @rtn_val = 0;
						SET @msg_txt = 'Success';
					ELSE
					/*정보변경에 실패한 경우 예외처리한다.*/
						SET @rtn_val = 24404;
						SET @msg_txt = 'User does not have permission';
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*사용자에게 권한이 없는 경우 예외처리한다.*/
					SET @rtn_val = 24403;
					SET @msg_txt = 'User does not have permission';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사용자가 배출자 사이트의 소속이 아닌 경우에는 예외처리한다.*/
				SET @rtn_val = 24402;
				SET @msg_txt = 'User is not a member of the site';
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
		/*사이트가 존재하지 않거나 유효하지 않은(개인사용자의 경우) 경우*/
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
    /*사용자가 존재하지 않는 사용자인 경우 예외처리한다.*/
        SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
    
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END