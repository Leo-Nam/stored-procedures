CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_login`(
	IN IN_USER_REG_ID		VARCHAR(50),		/*입력값 : 사용자 아이디*/
	IN IN_PWD				VARCHAR(100)		/*입력값 : 사용자 등록 전화번호*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_login
Input param 	: 2개
Job 			: 사용자 로그인기능으로서 사용자의 아이디와 암호로 해당사용자가 존재하는지 여부를 반환
Update 			: 2022.02.19
Version			: 0.0.6
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;
	START TRANSACTION;
    /*트랜잭션 시작*/
    
	CALL sp_req_user_exists(
		IN_USER_REG_ID,
		TRUE,
		@rtn_val, 
		@msg_txt
	);
	
	IF @rtn_val = 0 THEN
		SELECT COUNT(ID) 
		INTO @USER_LOGIN_SUCCESS 
		FROM USERS 
		WHERE 
			USER_ID = IN_USER_REG_ID AND 
			ACTIVE = TRUE;	
								
		IF @USER_LOGIN_SUCCESS = 1 THEN
			SELECT COUNT(ID) 
			INTO @PWD_MATCH
			FROM USERS 
			WHERE 
				USER_ID = IN_USER_REG_ID AND 
				ACTIVE = TRUE AND 
				PWD = IN_PWD;	
			SELECT COUNT(ID) INTO @USER_EXISTS FROM USERS WHERE USER_ID = IN_USER_REG_ID;
			IF @USER_EXISTS = 1 THEN
			/*로그인 정보와 일치하는 사용자가 존재하는 경우 정상처리한다.*/
				SELECT AFFILIATED_SITE INTO @USER_SITE FROM USERS WHERE USER_ID = IN_USER_REG_ID;
                IF @USER_SITE = 0 THEN
                /*사용자가 개인회원인 경우*/
					CALL sp_req_user_class(
						IN_USER_REG_ID,
                        @USER_CLASS
                    );
                    IF @USER_CLASS < 200 THEN
						SET @USER_TYPE_CODE = 1; 
                    ELSE
						SET @USER_TYPE_CODE = 2; 
                    END IF;
                ELSE
                /*사용자가 사업자 소속의 관리자인 경우*/
					SELECT USER_TYPE INTO @USER_TYPE FROM V_USERS WHERE USER_ID = IN_USER_REG_ID;
					IF @USER_TYPE IS NOT NULL THEN
					/*소속한 사이트(개인인경우는 0)가 정상적으로 분류된 경우*/
						IF @USER_TYPE = 'collector' THEN
							SET @USER_TYPE_CODE = 3;
						ELSE
							SET @USER_TYPE_CODE = 2;
						END IF;
					ELSE
					/*소속한 사이트(개인인경우는 0)가 분류되지 않은 경우*/
						SET @rtn_val = 22102;
						SET @msg_txt = 'Affiliation site industry classification error';
						SIGNAL SQLSTATE '23000';
					END IF;
                END IF;
                
				UPDATE USERS SET USER_CURRENT_TYPE = @USER_TYPE_CODE WHERE USER_ID = IN_USER_REG_ID;
                
                IF ROW_COUNT() = 1 THEN
                /*사용자 정보가 성공적으로 변경된 경우 정상처리한다.*/       
					SELECT JSON_OBJECT(
						'ID', 							ID, 
						'USER_ID', 						USER_ID, 
						'PWD', 							PWD, 
						'USER_NAME', 					USER_NAME, 
						'TRMT_BIZ_CODE', 				TRMT_BIZ_CODE, 
						'SITE_ID', 						AFFILIATED_SITE, 
						'COMP_ID', 						BELONG_TO, 
						'FCM', 							FCM, 
						'CLASS', 						CLASS, 
						'PHONE', 						PHONE,			/*0.0.4에서 추가 PHONE추가*/
						'USER_TYPE', 					USER_TYPE,
						'USER_CURRENT_TYPE', 			USER_CURRENT_TYPE_NM,
						'PWD_MATCH', 					@PWD_MATCH
					) 
					INTO @json_data 
					FROM V_USERS 
					WHERE 
						USER_ID 		= IN_USER_REG_ID AND 
						ACTIVE 			= TRUE;
						
					SET @rtn_val = 0;
					SET @msg_txt = 'success';
                ELSE
                /*사용자 정보변경에 실패한 경우 예외처리한다.*/
					SET @rtn_val = 22104;
					SET @msg_txt = 'Failed to change users current status';
					SIGNAL SQLSTATE '23000';
                END IF;
            
            
			ELSE
			/*로그인 정보와 일치하는 사용자가 존재하지 않는 경우 예외처리한다.*/
				SET @rtn_val = 22103;
				SET @msg_txt = 'user not found';
				SIGNAL SQLSTATE '23000';
			END IF;
					
		ELSE
			SET @json_data 		= NULL;
			SET @rtn_val = 22101;
			SET @msg_txt = 'Login ID do not match';
			SIGNAL SQLSTATE '23000';
		END IF;
	ELSE
		SET @json_data 		= NULL;
		SIGNAL SQLSTATE '23000';
	END IF;  
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END