CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_user`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 사용자계정을 생성하는 사용자의 아이디*/
	IN IN_USER_REG_ID 			VARCHAR(50),		/*입력값 : 생성할 사용자아이디*/
	IN IN_PWD 					VARCHAR(100),		/*입력값 : 생성할 사용자암호*/
	IN IN_USER_NAME 			VARCHAR(20),		/*입력값 : 생성할 사용자이름*/
	IN IN_PHONE 				VARCHAR(20),		/*입력값 : 생성할 사용자 등록 핸드폰 번호*/
	IN IN_CLASS 				INT,				/*입력값 : 생성할 사용자 클래스 ID로서 USERS_CLASS에 등록된 ID를 참조함, NULL인 경우에는 201(member.admin)으로 등록된다.*/
	IN IN_SITE_ID				BIGINT,				/*입력값 : 사업자의 관리자가 하부 조직을 만드는 경우에 입력되는 사이트의 고유번호(COMP_SITE.ID)값으로서 개인회원등록의 경우에는 NULL값을 입력받게 됨*/
	IN IN_DEPARTMENT			VARCHAR(20),		/*입력값 : 소속부서*/
	IN IN_SOCIAL_NO				VARCHAR(20),		/*입력값 : 주민등록번호*/
	IN IN_AGREE_TERMS			TINYINT				/*입력값 : 약관동의여부(동의시 1)*/
    )
BEGIN

/*
Procedure Name 	: sp_create_user
Input param 	: 9개
Job 			: 사용자 생성
Update 			: 2022.02.01
Version			: 0.0.10
AUTHOR 			: Leo Nam
Changes			: sp_req_super_permission의 변경에 따른 변경 적용
				: 입력변수 중 IN_COMP_ID를 IN_SITE_ID로 변경적용함(0.0.7)
				: CREATOR의 식별자를 기존 아이디에서 고유등록번호로 변경(0.0.8)
				: 일부 불필요한 로직 삭제(0.0.8)
				: FCM, JWT 입력부분 삭제(0.0.9)
				: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.9)
				: 유효성 검사 적용(0.0.10)
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;  
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    IF IN_USER_REG_ID IS NOT NULL AND LENGTH(IN_USER_REG_ID) > 0 THEN
    /*사용자 아이디를 입력한 경우*/
		CALL sp_req_user_exists(
        /*사용자 아이디가 중복되었는지 검사한다.*/
			IN_USER_REG_ID,
            NULL,   
			@rtn_val,
			@msg_txt
        );
        IF @rtn_val > 0 THEN
        /*중복된 사용자가 존재하지 않는 경우*/
			IF IN_PWD IS NOT NULL THEN
            /*사용자 암호를 입력한 경우*/
				IF IN_USER_NAME IS NOT NULL THEN
                /*사용자 이름을 입력한 경우*/
					IF IN_PHONE IS NOT NULL THEN
                    /*전화번호를 입력한 경우*/
						CALL sp_req_use_same_phone(
                        /*전화번호의 이중등록을 검사한다.*/
							IN_PHONE, 
							0, 
							TRUE, 
							@rtn_val, 
							@msg_txt                            
                        );
                        IF @rtn_val = 0 THEN
                        /*전화번호가 이중등록되지 않은 경우*/
							IF IN_CLASS IS NULL THEN
								SET IN_CLASS = 201;
                            END IF;
							IF IN_SITE_ID IS NULL THEN
								SET IN_SITE_ID = 0;
                            END IF;
							CALL sp_create_user_without_handler(
								IN_USER_ID,				/*입력값 : 사용자계정을 생성하는 사용자의 아이디*/
								IN_USER_REG_ID,			/*입력값 : 생성할 사용자아이디*/
								IN_PWD,					/*입력값 : 생성할 사용자암호*/
								IN_USER_NAME,			/*입력값 : 생성할 사용자이름*/
								IN_PHONE,				/*입력값 : 생성할 사용자 등록 핸드폰 번호*/
								IN_CLASS,				/*입력값 : 생성할 사용자 클래스 ID로서 USERS_CLASS에 등록된 ID를 참조함, NULL인 경우에는 201(member.admin)으로 등록된다.*/
								IN_SITE_ID,				/*입력값 : 사업자의 관리자가 하부 조직을 만드는 경우에 입력되는 사이트의 고유번호(COMP_SITE.ID)값으로서 개인회원등록의 경우에는 NULL값을 입력받게 됨*/
								IN_DEPARTMENT,			/*입력값 : 소속부서*/
								IN_SOCIAL_NO,			/*입력값 : 주민등록번호*/
								IN_AGREE_TERMS,			/*입력값 : 약관동의여부*/
								@OUT_USER_REG_ID,		/*출력값 : 사용자 등록이 완료된 후 등록사용자에게 부여된 고유등록번호*/
								@rtn_val,				/*출력값 : 처리결과 반환값*/
								@msg_txt				/*출력값 : 처리결과 문자열*/
							);
							
							IF @rtn_val = 0 THEN
							/*사용자 생성에 성공한 경우*/
								SELECT JSON_ARRAYAGG(JSON_OBJECT('user_reg_id', @OUT_USER_REG_ID)) INTO @json_data;
							ELSE
							/*사용자 생성에 실패한 경우*/
								SET @json_data 		= NULL;
								SIGNAL SQLSTATE '23000';
							END IF;
                        ELSE
                        /*전화번호가 이중등록된 경우에는 예외처리한다.*/
							SET @json_data 		= NULL;
							SIGNAL SQLSTATE '23000';
                        END IF;
                    ELSE
                    /*전화번호를 입력하지 않은 경우* 예외처리한다.*/
						SET @rtn_val = 24205;
						SET @msg_txt = 'No phone number entered';
						SET @json_data 		= NULL;
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*사용자 이름을 입력하지 않은 경우 예외처리한다.*/
					SET @rtn_val = 24204;
					SET @msg_txt = 'No user name entered';
					SET @json_data 		= NULL;
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사용자 암호를 입력하지 않은 경우 예외처리한다.*/
				SET @rtn_val = 24203;
				SET @msg_txt = 'No user password entered';
				SET @json_data 		= NULL;
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*중복된 사용자가 존재하는 경우 예외처리한다.*/   
			SET @rtn_val = 24202;
			SET @msg_txt = 'Duplicate User ID';
			SET @json_data 		= NULL;
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*사용자 아이디를 입력하지 않은 경우 예외처리한다.*/      
		SET @rtn_val = 24201;
		SET @msg_txt = 'Do not enter user ID';
		SET @json_data 		= NULL;
		SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END