CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_company`(
	IN IN_USER_ID 			BIGINT,				/*입력값 : 관리자아이디*/
    IN IN_COMP_ID	 		BIGINT				/*입력값 : 사업자 고유번호*/
    )
BEGIN

/*
Procedure Name 	: sp_delete_company
Input param 	: 2개
Output param 	: 2개
Job 			: 사업자 정보 삭제(ACTIVE = FALSE)
				: 사업자 정보 삭제시 사업자에 종속된 사업자, 사이트, 사용자 모두 삭제처리됨
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.28
Version			: 0.0.3
AUTHOR 			: Leo Nam
Change			: 사업자 삭제에 대한 기능을 Nested Procedure(sp_delete_company_without_handler)를 사용하여 처리함
				: 사용자 식별자를 사용자 아이디(USERS.USER_NAME)에서 사용자 고유등록번호(USER.ID)로 변경함(0.0.2)
				: 로깅 기능 삭제(유보)(0.0.3)
*/

    DECLARE JOB_TXT			VARCHAR(100);		/*변경사항에 대한 내용을 저장할 변수 선언*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    /*CALL sp_req_use_same_company_reg_id(IN_BIZ_REG_CODE, @BIZ_REG_CODE_EXISTS);*/ 
	CALL sp_req_user_exists_by_id(
		IN_USER_ID, 
		TRUE, 
		@rtn_val,
		@msg_txt
	);
	/*IN_USER_ID가 이미 등록되어 있는 사용자인지 체크한다. 등록되어 있는 경우에는 @USER_EXISTS = 1, 그렇지 않은 경우에는 @USER_EXISTS = 0을 반환한다.*/
	/*이미 등록되어 있는 사용자인 경우에는 관리자(member.admin)인지 검사한 후 member.admin인 경우에는 사업자 생성권한을 부여하고 그렇지 않은 경우에는 예외처리한다.*/
	/*등록되어 있지 않은 경우에는 신규사업자 생성으로 간주하고 정상처리 진행한다.*/
	
	IF @rtn_val = 0 THEN
	/*이미 등록되어 있는 사용자인 경우에는 관리자(member.admin)인지 검사한 후 member.admin인 경우에는 사업자 생성권한을 부여하고 그렇지 않은 경우에는 예외처리한다.*/
		/*체크할 사업자등록번호로 등록된 사업자가 존재하는지 체크한 후 존재한다면 1, 그렇지 않으면 0을 반환하게 됨*/
		CALL sp_req_company_validation(
			IN_COMP_ID, 
			@rtn_val, 
			@msg_txt
		);
		
		IF @state_code > 0 THEN
		/*사업자가 활성화되어 있는 사업자가 아닌 경우*/
			SIGNAL SQLSTATE '23000';
		ELSE   
		/*같은 사업자등록번호를 가진 사업자가 존재하는 경우에는 정상처리 진행한다.*/        
			CALL sp_req_super_permission_by_userid(
				IN_USER_ID, 
				IN_COMP_ID, 
				@PERMISSION, 
				@IS_USER_SITE_HEAD_OFFICE,
				@rtn_val,
				@msg_txt
			);
			IF @PERMISSION IN (1, 2) THEN
			/*IN_USER_ID가 sys.admin:101, 102인 경우*/
				CALL sp_req_parent_comp_id(
					IN_COMP_ID, 
					@PARENT_COMP_ID
				);
				/*사업자의 모기업 사업자 아이디를 구하여 @PARENT_COMP_ID에 저장한다.*/
				IF @PARENT_COMP_ID = 0 THEN
				/*모기업 사업자가 없는 경우(@PARENT_COMP_ID = 0)는 다른 사업자에 의하여 생성된 사업자가 아니므로 sys.admin에 의하여 삭제가 가능함*/
				/*다른 사업자에 의하여 생성된 사업자는 시스템에 의하여 삭제가 불가능하다.*/
					CALL sp_delete_company_without_handler(
					/*사업자정보를 삭제하는 절차를 진행한다.*/
						IN_USER_ID,					/*사용자 등록 고유번호(USERS.ID)*/
						IN_COMP_ID,						/*사업자 등록 고유번호(COMPANY.ID)*/
						@rtn_val,						/*처리결과 반환값*/
						@msg_txt						/*처리결과 문자열*/
					);
                    
					IF @rtn_val > 0 THEN
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*모기업 사업자가 있는 경우(@PARENT_COMP_ID <> 0)는 다른 사업자에 의하여 생성된 사업자이므로 sys.admin에 의하여 삭제가 불가능하며 해당 사업자를 생성한 모기업 사업자의 관리자에 의하여만 삭제가 가능함. 예외처리함.*/
					SET @rtn_val = 20601;
					SET @msg_txt = 'Subsidiaries cannot be deleted by the system administrator';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*IN_USER_ID가 sys.admin:101, 102이 아닌 경우*/
				IF @PERMISSION = 3 THEN
					/*사업자의 모기업 사업자 고유등록번호를 구하여 @PARENT_COMP_ID에 저장한다.*/   
					/*PERMISSION = 3인 경우에는 사용자의 권한(USER.CLASS)은 그 사업자의 최고권한인 201이다.*/   
					/*따라서 사용자가 삭제 대상사업자에 속하면서 최고권한을 가지고 있으므로 유일한 사업자 삭제 권한자이다.*/   
					CALL sp_req_comp_id_of_user_by_id(
						IN_USER_ID, 
						@USER_COMP_ID
					);
					/*사업자 정보 삭제 요청을 하는 사용자가 소속한 사업자의 고유등록번호를 구하여 @USER_COMP_ID에 저장함*/
					CALL sp_delete_company_without_handler(
					/*사업자정보를 삭제하는 절차를 진행한다.*/
						IN_USER_ID,					/*사용자 등록 고유번호(USERS.ID)*/
						IN_COMP_ID,						/*사업자 등록 고유번호(COMPANY.ID)*/
						@rtn_val,						/*처리결과 반환값*/
						@msg_txt						/*처리결과 문자열*/
					);
                    
					IF @rtn_val > 0 THEN
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
					SET @rtn_val = 20602;
					SET @msg_txt = 'Users do not have the right to delete company information';
					SIGNAL SQLSTATE '23000';
				END IF;
			END IF;
		END IF;
	ELSE
	/*사업자 정보에 대한 삭제 요청을 한 사용자가 확인되지 않는 경우에는 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
	END IF;
    COMMIT;
    
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END