CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_rate_site`(
	IN IN_USER_ID					BIGINT,
    IN IN_SITE_ID					BIGINT,
    IN IN_SCORE						INT,
    IN IN_DESC						VARCHAR(255)
)
BEGIN

/*
Procedure Name 	: sp_req_rate_site
Input param 	: 2개
Job 			: 서비스 사용후 상대 사업자를 평가한다.
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
		INSERT INTO SITE_EVALUATION (USER_ID, SITE_ID, SCORE, DESCRIPTION, CREATED_AT) VALUES (IN_USER_ID, IN_SITE_ID, IN_SCORE, IN_DESC, @REG_DT);
        IF ROW_COUNT() = 1 THEN
        /*평가 내용이 정상적으로 저장된 경우*/
			SET @rtn_val = 0;
			SET @msg_txt = 'database save success';
        ELSE
        /*평가 내용의 저장에 오류가 발생한 경우 예외처리한다.*/
			SET @rtn_val = 24801;
			SET @msg_txt = 'An error occurred while saving the database';
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