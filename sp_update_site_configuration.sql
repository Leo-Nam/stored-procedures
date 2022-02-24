CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_site_configuration`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 사용자 고유등록번호(USERS.ID)*/
    IN IN_SITE_ID				BIGINT,				/*입력값 : 사이트 고유등록번호(COMP_SITE.ID)*/
    IN IN_KEY					VARCHAR(20),		/*입력값 : 변경하고자 하는 환경설정키(PUSH, NOTICE, COLLECTOR)*/
    IN IN_VALUE					TINYINT			/*입력값 : 변경하고자 하는 환경설정키의 값*/
)
BEGIN

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
		CALL sp_req_site_id_of_user_reg_id(
        /*사용자가 소속하고 있는 사이트의 고유등록번호를 반환한다.*/
			IN_USER_ID,
            @USER_SITE_ID,
			@rtn_val,
			@msg_txt
        );
		IF @USER_SITE_ID IS NOT NULL THEN
		/*사이트가 유효한 경우*/
			IF @USER_SITE_ID = IN_SITE_ID THEN
			/*사이트가 사용자가 소속하고 있는 사이트인 경우*/
				CALL sp_req_user_class_by_user_reg_id(
				/*사용자의 권한을 반환한다.*/
					IN_USER_ID,
					@USER_CLASS
				);
				IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
				/*사용자가 권한이 있는 경우*/
					IF IN_KEY = 'COLLECTOR' THEN
						CALL sp_req_is_site_collector(
						/*사이트가 수집운반등의 허가가 있는지 검사한다.*/
							IN_SITE_ID,
							@rtn_val,
							@msg_txt
						);
						IF @rtn_val = 0 THEN
						/*사이트가 수집운반업의 허가를 가지고 있는 경우*/
							SET @IS_ABLE_TO_UPDATE = TRUE;
						ELSE
						/*사이트가 수집운반업의 허가를 가지고 있지 않은 경우 예외처리한다.*/
							SET @IS_ABLE_TO_UPDATE = FALSE;
						END IF;
					ELSE
						SET @IS_ABLE_TO_UPDATE = TRUE;
					END IF;
					
					IF @IS_ABLE_TO_UPDATE = TRUE THEN
					/*설정변경권한이 있는 경우*/
						SET @SQL_STMT = CONCAT('UPDATE SITE_CONFIGURATION SET ', IN_KEY, ' = ', IN_VALUE, ', UPDATED_AT = ', @REG_DT);
						PREPARE dquery FROM @SQL_STMT;
						EXECUTE dquery;
						IF ROW_COUNT() = 1 THEN
						/*데이타를 성공적으로 변경한 경우*/
							SET @rtn_val = 0;
							SET @msg_txt = 'Data change success';
						ELSE
						/*데이타 변경에 실패한 경우 예외처리한다.*/
							SET @rtn_val = 25901;
							SET @msg_txt = 'Failed to change data';
							SIGNAL SQLSTATE '23000';
						END IF;
					ELSE
					/*설정변경권한이 없는 경우 예외처리한다.*/
						SET @rtn_val = 25902;
						SET @msg_txt = 'No permission to change environment settings';
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*사용자가 권한이 없는 경우 예외처리한다.*/
					SET @rtn_val = 25903;
					SET @msg_txt = 'User does not have permission to change configuration settings';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사이트가 사용자가 소속하고 있지 않은 사이트인 경우 예외처리한다.*/
				SET @rtn_val = 25904;
				SET @msg_txt = 'User is not a member of the site';
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