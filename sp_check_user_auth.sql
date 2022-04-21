CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_user_auth`(
	IN IN_USER_REG_ID		VARCHAR(200),
	IN IN_USER_NAME			VARCHAR(20),
    IN IN_PHONE				VARCHAR(20)
)
BEGIN

/*
Procedure Name 	: sp_check_user_auth
Input param 	: 3개
Job 			: 사용자의 등록여부를 반환한다
Update 			: 2022.04.19
AUTHOR 			: Leo Nam
*/
    
	SELECT COUNT(ID) INTO @USER_COUNT
    FROM USERS
    WHERE USER_ID = IN_USER_REG_ID;
    
    IF @USER_COUNT = 1 THEN
    /*사용자 등록아이디가 존재하는 경우 정상처리한다.*/
		SELECT COUNT(ID) INTO @USER_COUNT
		FROM USERS
		WHERE 
			USER_ID = IN_USER_REG_ID AND
            USER_NAME = IN_USER_NAME;
        
		IF @USER_COUNT = 1 THEN
		/*사용자 이름이 일치하는 경우 정상처리한다*/	
			SELECT COUNT(ID) INTO @USER_COUNT
			FROM USERS
			WHERE 
				USER_ID = IN_USER_REG_ID AND
				USER_NAME = IN_USER_NAME AND
				PHONE = IN_PHONE;
			IF @USER_COUNT = 1 THEN
            /*사용자 등록 연락처가 일치하는 경우 정상처리한다.*/
				SET @rtn_val = 0;
				SET @msg_txt = 'success';
            ELSE
            /*사용자 등록 연락처가 일치하지 않는 경우 예외처리한다.*/
				SET @rtn_val = 38303;
				SET @msg_txt = 'user phone does not exist';
            END IF;
		ELSE
		/*사용자 이름이 일치하지 않는 경우 예외처리한다*/		
			SET @rtn_val = 38402;
			SET @msg_txt = 'user name does not match';
		END IF;
    ELSE
    /*사용자 등록아이디가 존재하지 않는 경우 예외처리한다.*/
		SET @rtn_val = 38401;
		SET @msg_txt = 'user ID does not exist';
    END IF;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END