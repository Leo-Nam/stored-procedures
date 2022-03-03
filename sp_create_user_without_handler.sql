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
				IF IN_SITE_ID = 0 THEN
				/*생성자가 치움관리자인 경우*/
					SET @COMP_ID_SITE_BELONGS_TO = 0;
				ELSE
				/*생성자가 치움관리자가 아닌 일반 사업자의 관리자인 경우*/
					CALL sp_req_comp_id_of_site(
					/*사이트가 속한 사업자 고유등록번호를 반환한다. 개인 또는 치움서비스 관리자인 경우에는 0이 @COMP_ID_SITE_BELONGS_TO을 통하여 반환된다.*/
						IN_SITE_ID, 
						@COMP_ID_SITE_BELONGS_TO		
					);
				END IF;
				IF IN_SITE_ID > 0 THEN
				/*사이트에 소속된 사용자를 생성하는 경우로서 개인사용자가 아닌 경우*/
					
					CALL sp_req_whether_user_can_be_added(
					/*현재 사이트에 사용자를 추가할 수 있는지 여부를 반환한다.*/
						IN_SITE_ID,
						TRUE,
						@rtn_val,
						@msg_txt
					);
					
					IF @rtn_val = 0 THEN
					/*사이트에 사용자 추가가 가능한 경우*/
						
						CALL sp_req_super_permission_by_userid(
							IN_USER_ID,
							@COMP_ID_SITE_BELONGS_TO,
							@PERMISSION,
							@IS_CREATOR_SITE_HEAD_OFFICE,
							@rtn_val,
							@msg_txt
						);
						
						CALL sp_req_is_site_head_office(
						/*사용자가 소속될 사이트가 HEAD OFFICE인지 검사한 후 HEAD OFFICE인 경우 TRUE, 그렇지 않은 경우 FALSE를 @IS_SITE_HEAD_OFFICE을 통하여 반환함*/
							IN_SITE_ID,
							@IS_USER_SITE_HEAD_OFFICE
						);
						
						IF @PERMISSION = 1 OR @PERMISSION = 2 OR (@PERMISSION = 3 AND (@IS_USER_SITE_HEAD_OFFICE = TRUE OR (@IS_USER_SITE_HEAD_OFFICE = FALSE AND IN_CLASS = 201))) OR (@PERMISSION = 5 AND @IS_CREATOR_SITE_HEAD_OFFICE = TRUE) THEN
						/*사용자를 생성할 권한이 있는 경우*/
						/*1. 치움서비스의 관리자 그룹에 속하는 사용자인 경우*/
						/*2. 생성자(CREATOR)의 권한이 사이트의 최고권한자이면서 사용자가 소속될  속한 사이트가 HEAD OFFICE이면서 생성자(CREATOR)의 권한이 201인 경우*/  
							SET @MANAGER_EXISTS = FALSE;
							IF IN_CLASS = 201 THEN
								SET @IS_USER_MANAGER = TRUE;
								CALL sp_req_manager_exists_in_site(
									IN_SITE_ID, 
									IN_CLASS, 
									@MANAGER_EXISTS
								);
							ELSE
								SET @IS_USER_MANAGER = FALSE;
							END IF;
							/*IN_SITE_ID의 고유등록번호를 가진 사이트를 관리하는 manager.admin:201이 존재하는 체크한 후 존재한다면 @MANAGER_EXISTS = 1, 그렇지 않으면 @MANAGER_EXISTS = 0이 됨*/
							IF (@IS_USER_MANAGER = TRUE AND @MANAGER_EXISTS = FALSE) OR @IS_USER_MANAGER = FALSE THEN
							/*등록대상 사용자가 관리자(201)이 아니거나 또는 관리자이지만 현재 등록할 사이트에 관리자가 등록되어 있지 않다면 정상적으로 사용자 등록을 진행다.*/
								CALL sp_insert_user(
									@USER_MAX_ID, 
									IN_USER_REG_ID, 
									IN_PWD, 
									IN_USER_NAME, 
									IN_PHONE, 
									@COMP_ID_SITE_BELONGS_TO, 
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
							/*사용자 등록을 진행하지 못하는 상황인 경우 예외처리한다.*/
								SET rtn_val = 20101;
								SET msg_txt = 'site manager account already exists';
							END IF;
						ELSE
						/*@PERMISSION = 1 OR @PERMISSION = 2 OR (@PERMISSION = 3 AND (@IS_USER_SITE_HEAD_OFFICE = TRUE OR (@IS_USER_SITE_HEAD_OFFICE = FALSE AND IN_CLASS = 201))) OR (@PERMISSION = 5 AND @IS_CREATOR_SITE_HEAD_OFFICE = TRUE)가 아닌 경우*/
							CALL sp_req_user_class_by_user_reg_id(
							/*생성자(CREATOR)의 권한(CLASS)를 구하여 @CREATOR_CLASS를 통하여 반환한다.*/
								IN_USER_ID,				/*생성자 고유등록번호*/
								@CREATOR_CLASS					/*생성자의 권한(CLASS)*/
							);
							
							CALL sp_req_site_id_of_user_reg_id(
								IN_USER_ID,				/*생성자 고유등록번호*/
								@SITE_ID_CREATOR_BELONGS_TO,	/*생성자가 속한 사이트의 고유등록번호*/
								@rtn_val,
								@msg_txt
							);
							IF @rtn_val = 0 THEN
                            /*사이트가 유효한 사이트인 경우*/
								IF @CREATOR_CLASS = 201 AND @SITE_ID_CREATOR_BELONGS_TO = IN_SITE_ID AND IN_CLASS > 201 THEN
								/*생성자의 권한이 201이고 생성자가 자신이 소속한 사이트에 속하는 사용자중에서 권한이 201인 사이트 관리자를 제외(권한 201인 사이트 관리자는 중복 생성 불가함)한 다른 사용자를 생성하는 경우에는 정상처리한다.*/
									CALL sp_insert_user(
										@USER_MAX_ID, 
										IN_USER_REG_ID, 
										IN_PWD, 
										IN_USER_NAME, 
										IN_PHONE, 
										@COMP_ID_SITE_BELONGS_TO, 
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
								/*그 이외에는 사업자에 속하는 생성자가 다른 사용자를 생성할 수 없으므로 예외처리한다.*/
									SET rtn_val = 20102;
									SET msg_txt = 'failed to create site member account';
								END IF;
                            ELSE
                            /*사이트가 유효하지 않은 사이트인 경우*/
								SET rtn_val = @rtn_val;
								SET msg_txt = @msg_txt;
                            END IF;
						END IF;
					ELSE
					/*사이트에 사용자 추가가 불가능한 경우*/
						SET rtn_val = @rtn_val;
						SET msg_txt = @msg_txt;
					END IF;
				ELSE
				/*SITE_ID = 0인 경우로서 치움서비스 관리자가 치움서비스 하부 관리자를 생성하거나 치움서비스관리자가 개인사용자를 생성하는 경우*/
					CALL sp_req_user_class_by_user_reg_id(
                    /*생성자의 권한을 반환한다.*/
						IN_USER_ID,
                        @CREATOR_CLASS
                    );
					IF (@CREATOR_CLASS = 101 AND IN_CLASS > 101 AND IN_CLASS < 200) OR ((@CREATOR_CLASS = 101 OR @CREATOR_CLASS = 102) AND IN_CLASS = 201) THEN
					/*치움서비스의 최고관리자가 치움서비스의 하부관리자를 생성하거나 치움서비스의 관리자 중에서 개인사용자를 생성할 있는 치움관리자(101, 102)가 개인사용자(201)을 생성하는 경우*/
						IF (IN_CLASS > 101 AND IN_CLASS < 200) THEN
                        /*치움의 관리자가 생성되는 경우*/
							CALL sp_insert_user(
								@USER_MAX_ID, 
								IN_USER_REG_ID, 
								IN_PWD, 
								IN_USER_NAME, 
								IN_PHONE, 
								@COMP_ID_SITE_BELONGS_TO, 
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
                        ELSE
                        /*개인사용자가 생성되는 경우*/
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
                        END IF;
						IF @rtn_val = 0 THEN
						/*사용자 입력에 성공한 경우*/
							IF IN_CLASS = 201 THEN
                            /*개인사용자가 생성되는 경우에는 담당자 배정을 받는다.*/
								CALL sp_cs_confirm_account(
								/*등록된 사용자에게 CS의 담당자가 배정된다.*/
									@USER_MAX_ID,
									0,
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
								SET rtn_val = 0;
								SET msg_txt = 'Success';
                            END IF;
						ELSE
						/*사용자 입력에 실패한 경우 예외처리한다.*/
							SET rtn_val = @rtn_val;
							SET msg_txt = @msg_txt;
						END IF;
					ELSE
					/*사용자 생성불가의 경우이므로 예외처리한다.*/
						SET rtn_val = @rtn_val;
						SET msg_txt = @msg_txt;
					END IF;
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