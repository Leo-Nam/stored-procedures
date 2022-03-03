CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_user_without_handler`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 사용자계정을 생성하는 사용자의 아이디*/
	IN IN_USER_REG_ID 			VARCHAR(50),		/*입력값 : 생성할 사용자아이디*/
    IN IN_PWD 					VARCHAR(100),		/*입력값 : 생성할 사용자암호*/
    IN IN_USER_NAME 			VARCHAR(20),		/*입력값 : 생성할 사용자이름*/
    IN IN_PHONE 				VARCHAR(20),		/*입력값 : 생성할 사용자 등록 핸드폰 번호*/
    IN IN_CLASS 				INT,				/*입력값 : 생성할 사용자 클래스 ID로서 USERS_CLASS에 등록된 ID를 참조함, NULL인 경우에는 201(member.admin)으로 등록된다.*/
    IN IN_SITE_ID				BIGINT,				/*입력값 : 사용자가 속하게 될 사이트의 고유등록번호*/
    IN IN_DEPARTMENT			VARCHAR(20),		/*입력값 : 소속부서*/
	IN IN_SOCIAL_NO				VARCHAR(20),		/*입력값 : 주민등록번호*/
	IN IN_AGREE_TERMS			TINYINT,			/*입력값 : 약관동의여부(동의시 1)*/
    OUT OUT_USER_ID				BIGINT,				/*출력값 : 사용자 등록이 완료된 후 등록사용자에게 부여된 고유등록번호*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)		/*출력값 : 처리결과 문자열*/
    )
BEGIN

/*
Procedure Name 	: sp_create_user_without_handler
Input param 	: 9개
Output param 	: 3개
Job 			: USERS테이블에 입력 PARAM값을 INSERT 하는 작업을 수행(COMMIT)하며 중도에 에러발생시 예외처리 코드 반환함
				: 사용자 등록은 기본적으로 개인사용자가 개인회원으로 등록하는 경우에 사용된다.
				: 또한 사업자의 mypage에서 super user(member.admin:201)가 조직내 관리자(member.manager:202) 또는 조직내 업무에 필요한 다른 직원(member.employee:299)을 등록하는 경우에도 사용된다.
                : 예외 또는 에러에 대한 handler가 없는 로직임
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.02.16
Version			: 0.1.0
AUTHOR 			: Leo Nam
Changes			: 사이트에 등록할 수 있는 사용자 제한규정(정책사항)을 적용함
				: 사용자 생성자의 사이트 사용자 생성 권한 체크 로직 수정(0.0.3)
				: 등록사용자에 대한 담당자 자동 배정 로직 추가(0.0.5)
				: CREATOR의 식별자를 USERS.USER_ID에서 USERS.ID로 변경(0.0.6)
				: CREATOR_REG_ID가 NULL로 입력될때에는 개인사용자가 스스로 자신을 개인회원으로 등록하는 것으로 간주하고 CREATOR와 등록할 아이디를 동일시 한다.(0.0.7)
				: 사용자 타입에 system(치움서비스 관리자)타입 추가(0.0.7)
				: 생성자 유효성 체크 로직 일부 수정(0.0.8)
				: FCM, JWT 입력부분 삭제(0.0.9)
				: 주민번호 입력부분 추가(0.1.0)
*/

    DECLARE LOG_POLICY			VARCHAR(50);	/*트랜잭션 전체(INSERT, UPDATE, DELETE, DROP)에 대한 트랜잭션 발생시 로그(sys_log)할지 여부를 저장하는 변수 선언*/
    DECLARE JOB_TXT				VARCHAR(100);	/*변경사항에 대한 내용을 저장할 변수 선언*/
    
	SET rtn_val = -1;
	SET msg_txt = 'Nothing happened2';			
    
    CALL sp_req_current_time(
		@REG_DT
	);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
    CALL sp_req_user_max_id(
		@USER_MAX_ID
    );
    
    SET OUT_USER_ID = @USER_MAX_ID;
    /*등록된 사용자 중에서 가장 큰 고유번호(ID) + 1을 반환한다.*/
    
    IF IN_SITE_ID = 0 AND IN_CLASS = 201 THEN
		SET @USER_TYPE = 'user';
    ELSE
		IF IN_CLASS < 200 THEN
			SET @USER_TYPE = 'system';
        ELSE
			SET @USER_TYPE = 'company';
        END IF;
    END IF;   
    
	CALL sp_req_user_exists(
	/*생성할 사용자 아이디가 이미 존재하는지 체크한다.*/
		IN_USER_REG_ID, 
		TRUE, 
		@rtn_val, 
		@msg_txt
	);
	/*등록하고자 하는 사용자의 USER_ID가 이미 등록되어 있는 경우에는 @USER_EXISTS = 1, 그렇지 않은 경우에는 @USER_EXISTS = 0이 됨*/	
        
	IF @rtn_val <> 0 THEN
	/*등록사용자가 존재하지 않는 경우에는 정상처리함*/
			
		CALL sp_req_use_same_phone(
			IN_PHONE, 
			IN_SITE_ID, 
			TRUE, 
			@rtn_val, 
			@msg_txt
		);
        
        IF @rtn_val = 0 THEN
        /*같은 번호로 등록된 핸드폰이 없다면*/
			CALL sp_req_user_exists_by_id(
			/*생성자가 존재하는지 체크한다.*/
				IN_USER_ID, 
				TRUE, 
				@rtn_val,
				@msg_txt
			);
			/*등록을 요청하는 사용자의 USER_ID가 이미 등록되어 있는 경우에는 @USER_EXISTS = 1, 그렇지 않은 경우에는 @USER_EXISTS = 0이 됨*/ 		
			IF @rtn_val = 0 THEN
			/*CREATOR가 존재하는 경우*/				
				CALL sp_req_whether_user_can_be_added(
				/*현재 사이트에 사용자를 추가할 수 있는지 여부를 반환한다.*/
					IN_SITE_ID,
					TRUE,
					@rtn_val,
					@msg_txt
				);					
				IF @rtn_val = 0 THEN
				/*사이트에 사용자 추가가 가능한 경우*/
					CALL sp_req_user_class_by_user_reg_id(
						IN_USER_ID,
						@CREATOR_CLASS
					);
					
					SELECT AFFILIATED_SITE INTO @CREATOR_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
					
					CALL sp_check_auth_to_create_user(
						IN_CLASS,
						IN_SITE_ID,
						@CREATOR_CLASS,
						@CREATOR_SITE_ID,
						@TARGET_SITE_ID,
						@rtn_val,
						@msg_txt
					);
					IF @rtn_val = 0 THEN
					/*사용자를 추가할 권한이 있는 경우는 정상처리한다.*/
						CALL sp_insert_user(
							@USER_MAX_ID, 
							IN_USER_REG_ID, 
							IN_PWD, 
							IN_USER_NAME, 
							IN_PHONE, 
							@TARGET_SITE_ID, 
							IN_SITE_ID, 
							IN_CLASS, 
							IN_DEPARTMENT, 
							IN_SOCIAL_NO, 
							IN_AGREE_TERMS, 
							@REG_DT, 
							@REG_DT, 
							@rtn_val,
							@msg_txt
						);
						IF @rtn_val = 0 THEN
						/*사용자 입력에 성공한 경우*/
							CALL sp_cs_confirm_account(
							/*등록된 사용자에게 CS의 담당자가 배정된다.*/
								@USER_MAX_ID,
								IN_SITE_ID,
								IN_CLASS,
								@USER_TYPE,
								@rtn_val,
								@msg_txt
							);
							IF @rtn_val = 0 THEN
							/*담당자가 성공적으로 배정된 경우*/
								SET rtn_val = 0;
								SET msg_txt = 'Success';
							ELSE
							/*담당자배정에 실패한 경우*/
								SET rtn_val = @rtn_val;
								SET msg_txt = @msg_txt;
							END IF;
						ELSE
						/*사용자 입력에 실패한 경우에는 예외처리한다.*/
							SET rtn_val = @rtn_val;
							SET msg_txt = @msg_txt;
						END IF;
					ELSE
					/*사용자를 추가할 권한이 없는 경우는 예외처리한다.*/
						SET rtn_val = @rtn_val;
						SET msg_txt = @msg_txt;
					END IF;
				ELSE
				/*사이트에 사용자 추가가 불가능한 경우*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
				END IF;
			ELSE
			/*CREATOR가 존재하지 않는 경우-개인사용자*/		
				CALL sp_insert_user(
					@USER_MAX_ID, 
					IN_USER_REG_ID, 
					IN_PWD, 
					IN_USER_NAME, 
					IN_PHONE, 
					0, 
					0, 
					IN_CLASS, 
					NULL, 
					IN_SOCIAL_NO, 
					IN_AGREE_TERMS, 
					@REG_DT, 
					@REG_DT, 
					@rtn_val,
					@msg_txt
				);
				IF @rtn_val = 0 THEN
				/*사용자 입력에 성공한 경우*/
					CALL sp_cs_confirm_account(
					/*등록된 사용자에게 CS의 담당자가 배정된다.*/
						@USER_MAX_ID,
						IN_SITE_ID,
						IN_CLASS,
						@USER_TYPE,
						@rtn_val,
						@msg_txt
					);
					IF @rtn_val = 0 THEN
					/*담당자가 성공적으로 배정된 경우*/
						SET rtn_val = 0;
						SET msg_txt = 'Success';
					ELSE
					/*담당자배정에 실패한 경우*/
						SET rtn_val = @rtn_val;
						SET msg_txt = @msg_txt;
					END IF;
				ELSE
				/*사용자 입력에 실패한 경우에는 예외처리한다.*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
				END IF;
			END IF;
		ELSE
        /*같은 번호로 등록된 핸드폰이 존재하는 경우 예외처리한다.*/
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt;
		END IF;
	ELSE
	/*등록사용자가 존재하는 경우에는 이중등록이므로 예외처리함*/
		SET rtn_val = 20103;
		SET msg_txt = 'User already exists';
	END IF;
END