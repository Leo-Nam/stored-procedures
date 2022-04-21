CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_change_read_state_of_history`(
	IN IN_USER_ID					BIGINT,
	IN IN_HISTORY_ID				BIGINT
)	
BEGIN

/*
Procedure Name 	: sp_req_change_read_state_of_history
Input param 	: 3개
Job 			: 히스토리의 읽음 상태를 변경한다.
Update 			: 2022.04.19
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
		SELECT COUNT(ID) INTO @HISTORY_COUNT
        FROM PUSH_HISTORY
        WHERE ID = IN_HISTORY_ID;
        
		IF @HISTORY_COUNT = 1 THEN
		/*히스토리가 존재하는 경우 정상처리한다*/			
			SELECT IS_DELETED, IS_READ, USER_ID 
            INTO @IS_DELETED, @IS_READ, @PUSH_USER_ID
			FROM PUSH_HISTORY
			WHERE 
				ID = IN_HISTORY_ID AND
				IS_DELETED = FALSE;
			IF @IS_DELETED = FALSE THEN
            /*푸시 히스토리를 삭제하지 않은 경우 정상처리한다.*/
				IF @IS_READ = FALSE THEN
				/*푸시 히스토리를 읽지 않은 경우에는 정상처리한다.*/
					IF @PUSH_USER_ID = IN_USER_ID THEN
					/*푸시를 읽을수 있는 사용자인 경우에는 정상처리한다*/
						UPDATE PUSH_HISTORY 
						SET 
							IS_READ 		= TRUE, 
							IS_READ_AT 		= @REG_DT
						WHERE ID = IN_HISTORY_ID;
						IF ROW_COUNT() = 1 THEN
						/*정보가 성공적으로 변경되었다면*/
							SET @rtn_val = 0;
							SET @msg_txt = 'success';
						ELSE
						/*정보변경에 실패했다면 예외처리한다.*/
							SET @rtn_val = 38305;
							SET @msg_txt = 'Failed to update the record';
							SIGNAL SQLSTATE '23000';
						END IF;
					ELSE
					/*푸시를 읽을수 없는 사용자인 경우에는 예외처리한다*/
						SET @rtn_val = 38304;
						SET @msg_txt = 'user not authorized';
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*푸시 히스토리를 이미 읽은 경우에는 예외처리한다.*/
					SET @rtn_val = 38303;
					SET @msg_txt = 'push history already read';
					SIGNAL SQLSTATE '23000';
				END IF;
            ELSE
            /*푸시 히스토리를 이미 삭제한 경우 예외처리한다.*/
				SET @rtn_val = 38302;
				SET @msg_txt = 'push history already deleted';
				SIGNAL SQLSTATE '23000';
            END IF;
		ELSE
		/*히스토리가 존재하는 경우 예외처리한다*/
			SET @rtn_val = 38301;
			SET @msg_txt = 'push history does not exist';
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