CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_cancel_visit`(
	IN IN_USER_ID				BIGINT,					/*방문요청신청자(USERS.ID)*/
	IN IN_DISPOSER_ORDER_ID		BIGINT					/*폐기물 배출 내역 고유등록번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_req_cancel_visit
Input param 	: 2개
Output param 	: 2개
Job 			: 배출자의 방문신청 취소
Update 			: 2022.02.21
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
		IN_USER_ID,			/*사용자의 고유등록번호*/
        TRUE,					/*ACTIVE가 TRUE인 상태(활성화 상태)인 사용자에 한정*/
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
    /*요청자의 고유등록번호가 존재하는 경우*/    
		CALL sp_req_disposal_order_exists(
		/*폐기물 배출 요청 내역이 존재하는지 검사한다.*/
			IN_DISPOSER_ORDER_ID,
			@DISPOSAL_ORDER_EXISTS
		);
		IF @DISPOSAL_ORDER_EXISTS > 0 THEN
		/*폐기물 배출 요청 내역이 존재하는 경우*/
			SELECT COUNT(ID) INTO @CHK_COUNT 
			FROM ASK_VISIT_SITE
			WHERE 
				DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND
				ASKER_ID = IN_USER_ID;
			/*방문신청을 하는자가 기존에 방문신청을 한 사실 있는지 확인한다.*/
			
			IF @CHK_COUNT < 2 THEN
			/*재 방문 신청이 아닌 경우*/
				SELECT COUNT(ID) INTO @CHK_COUNT 
				FROM ASK_VISIT_SITE
				WHERE 
					DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND
					ASKER_ID = IN_USER_ID AND
					ACTIVE = TRUE;
				/*방문신청을 하는자가 기존에 방문신청을 한 사실 있는지 확인한다.*/
				IF @CHK_COUNT = 1 THEN
				/*만일 기존에 방문신청한 내역이 있는 경우*/
					UPDATE ASK_VISIT_SITE
					SET 
						ACTIVE		 		= FALSE,
						UPDATED_AT 			= @REG_DT
					WHERE 
						DISPOSAL_ORDER_ID 	= IN_DISPOSER_ORDER_ID AND
						ASKER_ID 			= IN_USER_ID AND
						ACTIVE				= TRUE;
					/*해당 방문신청내역을 변경처리한다.*/
					
					IF ROW_COUNT() = 1 THEN
					/*방문신청 정보 변경과정이 성공적으로 마무리 되었다면*/
						SET @rtn_val = 0;
						SET @msg_txt = 'success';
					ELSE
					/*방문신청 정보 변경과정에 오류가 발생하였다면 예외처리한다.*/
						SET @rtn_val = 23301;
						SET @msg_txt = 'Failed to cancel visit request';
                        SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*만일 기존에 방문신청한 내역이 없는 경우*/
					SET @rtn_val = 23302;
					SET @msg_txt = 'no application history to cancel the visit request';
                    SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*방문신청을 2회 한 경우*/
				SET @rtn_val = 23303;
				SET @msg_txt = 'A re-application for a visit cannot be canceled';
                SIGNAL SQLSTATE '23000';
			END IF;
        ELSE
		/*폐기물 배출 요청 내역이 존재하지 않는 경우*/
			SET @rtn_val = 23304;
			SET @msg_txt = 'No Waste Discharge Requests';
			SIGNAL SQLSTATE '23000';
        END IF;
	ELSE
    /*요청자의 고유등록번호가 존재하지 않는 경우*/   
        SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
	SET @json_data = NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END