CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_change_user_pwd`(
	IN IN_USER_ID				BIGINT,										/*입력값 : 사용자 고유등록번호(USERS.ID)*/
	IN IN_PWD					VARCHAR(50)									/*입력값 : 사용자 변경할 암호*/
)
BEGIN

/*
Procedure Name 	: sp_req_change_user_pwd
Input param 	: 2개
Job 			: 입력받은 암호를 해당사용자의 새로운 암호로 업데이트를 한다. 성공인면 0, 그렇지 않으면 예외코드를 반환한다.
Update 			: 2022.01.30
Version			: 0.0.4
AUTHOR 			: Leo Nam
Change			: 사용자 타입구분 폐지(전화번호는 유일한 키 => 전화번호가 중복되지 않으므로 사용자 타입을 구분할 필요 없음)(0.0.2)
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
		UPDATE USERS SET PWD = IN_PWD, UPDATED_AT = @REG_DT WHERE ID = IN_USER_ID;
		/*사용자 암호를 변경한다.*/
		
		IF ROW_COUNT() = 1 THEN
		/*사용자 암호 변경에 성공한 경우*/
			SET @rtn_val = 0;
			SET @msg_txt = 'Password changed successfully';
		ELSE
		/*사용자 암호 변경에 실패한 경우*/
			SET @rtn_val = 21301;
			SET @msg_txt = 'Password change failed';
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