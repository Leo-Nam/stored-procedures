CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_company_without_handler`(
	IN IN_USER_REG_ID 		VARCHAR(50),		/*입력값 : 관리자아이디*/
    IN IN_PWD 				VARCHAR(100),		/*입력값 : 관리자암호*/
    IN IN_USER_NAME 		VARCHAR(20),		/*입력값 : 관리자이름*/
    IN IN_PHONE 			VARCHAR(20),		/*입력값 : 관리자 핸드폰 번호*/
    IN IN_COMP_NAME 		VARCHAR(100),		/*입력값 : 사업자 상호*/
    IN IN_REP_NAME 			VARCHAR(50),		/*입력값 : 대표자 이름*/
    IN IN_KIKCD_B_CODE 		VARCHAR(10),		/*입력값 : 사무실 소재지 시군구 법정동코드로서 10자리 코드*/
    IN IN_ADDR 				VARCHAR(300),		/*입력값 : 사무실 소재지 상세주소*/
    IN IN_LNG		 		DECIMAL(12,9),		/*입력값 : 사업자 소재지의 경도값*/
    IN IN_LAT		 		DECIMAL(12,9),		/*입력값 : 사업자 소재지의 위도값*/
    IN IN_CONTACT 			VARCHAR(100),		/*입력값 : 사무실 연락처*/
    IN IN_TRMT_BIZ_CODE 	VARCHAR(4),			/*입력값 : 사업자 분류코드로서 WSTE_TRMT_BIZ에 등록된 종류별 코드임*/
    IN IN_BIZ_REG_CODE 		VARCHAR(12),		/*입력값 : 사업자번호*/
	IN IN_SOCIAL_NO			VARCHAR(20),		/*입력값 : 주민등록번호*/
	IN IN_AGREE_TERMS		TINYINT,			/*입력값 : 약관동의여부(동의시 1)*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(200),		/*출력값 : 처리결과 문자열*/
    OUT OUT_SITE_ID			BIGINT,				/*출력값 : 사업자 사이트 등록 고유번호*/
    OUT OUT_USER_ID			BIGINT				/*출력값 : 사용자 등록 고유번호*/
    )
BEGIN

/*
Procedure Name 	: sp_create_company_without_handler
Input param 	: 13개
Output param 	: 3개
Job 			: COMPANY테이블과 USERS테이블에 각각 입력 PARAM값을 분리하여 INSERT 하는 작업을 수행(COMMIT)하며 중도에 에러발생시 예외처리코드 반환함
				: 이 프로시저를 호출한 프로시저에서 처리결과값을 받아서 예외처리해야 함
				: 사업자에 대한 기본 사이트 개설 기능 추가
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.27
Version			: 0.0.4
AUTHOR 			: Leo Nam
Changes			: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.4)
*/

    DECLARE CHK_COUNT 		INT;				/*처리결과에 대한 체크 결과를 저장하는 변수 선언*/
    DECLARE LOG_POLICY		VARCHAR(50);		/*트랜잭션 전체(INSERT, UPDATE, DELETE, DROP)에 대한 트랜잭션 발생시 로그(sys_log)할지 여부를 저장하는 변수 선언*/
    DECLARE JOB_TXT			VARCHAR(100);		/*변경사항에 대한 내용을 저장할 변수 선언*/
    
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
 /*   IF IN_AGREE_TERMS = TRUE THEN*/
    /*약관에 동의한 경우 정상처리한다.*/
		CALL sp_req_use_same_company_reg_id(
			IN_BIZ_REG_CODE, 
			@rtn_val, 
			@msg_txt
		);
		/*체크할 사업자등록번호로 등록된 사업자가 존재하는지 체크한 후 존재한다면 1, 그렇지 않으면 0을 반환하게 됨*/
		
		IF @rtn_val = 0 THEN
		/*같은 사업자등록번호를 가진 사업자가 존재하지 않는 경우에는 정상처리 진행한다.*/ 
			
			CALL sp_req_user_exists(
				IN_USER_REG_ID, 
				TRUE, 
				@rtn_val, 
				@msg_txt
			);
			/*IN_USER_REG_ID가 이미 등록되어 있는 사용자인지 체크한다. 등록되어 있는 경우에는 @USER_EXISTS = 1, 그렇지 않은 경우에는 @USER_EXISTS = 0을 반환한다.*/
			/*이미 등록되어 있는 사용자인 경우에는 관리자(member.admin)인지 검사한 후 member.admin인 경우에는 사업자 생성권한을 부여하고 그렇지 않은 경우에는 예외처리한다.*/
			/*등록되어 있지 않은 경우에는 신규사업자 생성으로 간주하고 정상처리 진행한다.*/
			
			IF @rtn_val = 0 THEN
			/*이미 등록되어 있는 사용자인 경우에는 관리자(member.admin)인지 검사한 후 member.admin인 경우에는 사업자 생성권한을 부여하고 그렇지 않은 경우에는 예외처리한다.*/
				CALL sp_req_user_regid_by_user_id(
					IN_USER_REG_ID,
                    OUT_USER_ID
                );
                SET @CREATOR_REG_ID = OUT_USER_ID;
				CALL sp_member_admin_account_exists(
					IN_USER_REG_ID, 
					@rtn_val, 
					@msg_txt
				);
				
				IF @rtn_val = 0 THEN
				/*사용자에게 사업자를 생성할 권한이 있는 경우*/
					CALL sp_req_comp_max_id(@COMP_MAX_ID);
                    CALL sp_req_comp_id_of_user_by_id(
						@CREATOR_REG_ID,
                        @P_COMP_ID
                    );
					CALL sp_insert_company(
						@COMP_MAX_ID, 
						IN_COMP_NAME, 
						IN_REP_NAME, 
						IN_KIKCD_B_CODE, 
						IN_ADDR, 
						IN_LNG, 
						IN_LAT, 
						IN_CONTACT, 
						IN_TRMT_BIZ_CODE, 
						IN_BIZ_REG_CODE, 
						@P_COMP_ID, 
						@REG_DT, 
						@REG_DT, 
						@rtn_val, 
						@msg_txt
					);
				
					IF @rtn_val = 0 THEN
					/*사업자 레코드가 정상적으로 생성된 경우 기본 사이트 개설 절차를 진행한다.*/
						CALL sp_create_site_without_handler(
							@CREATOR_REG_ID, 
							@COMP_MAX_ID, 
							IN_KIKCD_B_CODE, 
							IN_ADDR, 
							IN_COMP_NAME, 
							0, 
							@REG_DT, 
							IN_CONTACT, 
							IN_TRMT_BIZ_CODE, 
							IN_LNG, 
							IN_LAT, 
							TRUE, 
							@SITE_REG_ID, 
							@rtn_val, 
							@msg_txt
						);
						IF @rtn_val = 0 THEN
							SET rtn_val = 0;
							SET msg_txt = 'Success3';
							SET OUT_SITE_ID = @SITE_REG_ID;
						ELSE
							SET rtn_val = @rtn_val;
							SET msg_txt = @msg_txt;
						END IF;
					ELSE
					/*사업자 레코드가 정상적으로 생성되지 않은 경우에는 ROLLBACK처리한다.*/
						SET rtn_val = @rtn_val;
						SET msg_txt = @msg_txt;
					END IF;
				ELSE
				/*사용자에게 사업자를 생성할 권한이 없는 경우에는 예외처리한다.*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
				END IF;
			ELSE
			/*등록되어 있지 않은 경우에는 신규사업자 생성으로 간주하고 정상처리 진행한다.*/
				CALL sp_req_use_same_phone(
					IN_PHONE, 
					0, 
					TRUE, 
					@rtn_val, 
					@msg_txt
				);
				/*등록하려는 핸드폰이 이미 등록되어 있다면 @CHK_COUNT=1, 아니면 @CHK_COUNT=0*/
				IF @rtn_val = 0 THEN
				/*등록하려는 핸드폰이 등록되어 있지 않은 경우*/
					CALL sp_req_comp_max_id(@COMP_MAX_ID);
                    SET @P_COMP_ID = 0;
					CALL sp_insert_company(
						@COMP_MAX_ID, 
						IN_COMP_NAME, 
						IN_REP_NAME, 
						IN_KIKCD_B_CODE, 
						IN_ADDR, 
						IN_LNG, 
						IN_LAT, 
						IN_CONTACT, 
						IN_TRMT_BIZ_CODE, 
						IN_BIZ_REG_CODE, 
						@P_COMP_ID, 
						@REG_DT, 
						@REG_DT, 
						@rtn_val, 
						@msg_txt
					);
				
					IF @rtn_val = 0 THEN
					/*사업자 레코드가 정상적으로 생성된 경우에는 사용자 계정 생성과정을 정상처리 진행한다.*/
						CALL sp_req_user_max_id(@USER_MAX_ID);
						SET OUT_USER_ID = @USER_MAX_ID;
						CALL sp_insert_user(
							@USER_MAX_ID, 
							IN_USER_REG_ID, 
							IN_PWD, 
							IN_USER_NAME, 
							IN_PHONE, 
							@COMP_MAX_ID, 
							NULL, 
							201, 
							NULL, 
							IN_SOCIAL_NO, 
							IN_AGREE_TERMS, 
							@REG_DT, 
							@REG_DT, 
							@rtn_val, 
							@msg_txt
						);
						IF @rtn_val = 0 THEN
						/*사용자 레코드가 정상적으로 생성된 경우에는 정상처리 진행한다.*/  
							CALL sp_create_site_without_handler(
								@USER_MAX_ID, 
								@COMP_MAX_ID, 
								IN_KIKCD_B_CODE, 
								IN_ADDR, 
								IN_COMP_NAME, 
								0, 
								@REG_DT, 
								IN_CONTACT, 
								IN_TRMT_BIZ_CODE, 
								IN_LNG, 
								IN_LAT, 
								TRUE, 
								@SITE_REG_ID, 
								@rtn_val, 
								@msg_txt
							);
							IF @rtn_val = 0 THEN
							/*사이트가 정상적으로 개설된 경우*/
								SET OUT_SITE_ID = @SITE_REG_ID;
								UPDATE USERS SET AFFILIATED_SITE = @SITE_REG_ID WHERE ID = @USER_MAX_ID;
								/*신규사용자의 소속 사이트(AFFILIATED_SITE)를 현재 생성된 사이트로 업데이트 한다.*/
								
								IF ROW_COUNT() = 1 THEN
								/*사용자의 소속 사이트 정보에 대한 업데이트가 성공한 경우*/
									SET rtn_val = 0;
									SET msg_txt = 'Success1';
									/*사용자 레코드가 정상적으로 생성된 경우에는 최종 COMMIT 처리하여 레코드 생성을 확인한다.*/
									/*0을 반환함으로써 모든 트랜잭션이 성공하였음을 알린다.*/
								ELSE
								/*사용자의 소속 사이트 정보에 대한 업데이트가 실패한 경우*/
									SET rtn_val = 20003;
									SET msg_txt = 'Failed to modify affiliated site information';
								END IF;
							ELSE
							/*사이트가 정상적으로 개설에 실패한 경우*/
								SET rtn_val = @rtn_val;
								SET msg_txt = @msg_txt;
							END IF;
						ELSE
						/*사용자 레코드가 정상적으로 생성되지 않은 경우에는 ROLLBACK처리한다.*/ 
							SET rtn_val = @rtn_val;
							SET msg_txt = @msg_txt;
						END IF;
					ELSE  
					/*사업자 레코드가 정상적으로 생성되지 않은 경우에는 ROLLBACK처리한다.*/
						SET rtn_val = 20002;
						SET msg_txt = 'company record creation failed';
					END IF;
				ELSE
				/*등록하려는 핸드폰이 이미 등록된 경우에는 예외처리한다.*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
				END IF;
			END IF;
		ELSE  
		/*같은 사업자등록번호를 가진 사업자가 존재하는 경우에는 ROLLBACK처리한다.*/
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt; 
		END IF;
/*    ELSE*/
    /*약관에 동의하지 않은 경우 예외처리한다.*/ 
/*		SET rtn_val = 20001;
		SET msg_txt = 'not agree to the terms';
    END IF;*/
END