CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_collector`(
	IN IN_USER_ID 					BIGINT,				/*입력값 : 사용자 고유등록번호*/
	IN IN_SITE_ID 					BIGINT,				/*입력값 : 수거자 업체등으로 등록할 사이트 고유등록번호(COMP_SITE.ID)*/
	IN IN_TRMT_BIZ_CODE 			VARCHAR(4),			/*입력값 : 사업자 분류코드로서 WSTE_TRMT_BIZ에 등록된 종류별 코드임, 2~7까지의 코드 사용가능*/
	IN IN_PERMIT_REG_CODE 			VARCHAR(100),		/*입력값 : 수거자등의 허가 또는 신고번호*/
	IN IN_PERMIT_REG_IMG_PATH		VARCHAR(200),		/*입력값 : 수거자등의 허가 또는 신고증명서 등록 이미지 저장 경로*/
	IN IN_WSTE_CODE_LIST			VARCHAR(255)		/*입력값 : 폐기물 코드 리스트*/
    )
BEGIN

/*
Procedure Name 	: sp_create_collector
Input param 	: 6개
Job 			: 수거자등의 업체 등록
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.29
Version			: 0.0.5
AUTHOR 			: Leo Nam
Change			: JWT 입력변수 삭제(0.0.3) / 폐기물 종류 정보(IN_WSTE_CLS) 입력
				: COMP_SITE 테이블 변경에 따른 로직 일부 수정(0.0.3)
				: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.4)
                : 서브 프로시저의 데이타 반환타입 통일(0.0.5)
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;
	START TRANSACTION;
    /*트랜잭션 시작*/
    
    CALL sp_req_current_time(
		@REG_DT
    );
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
    CALL sp_req_same_company_permit_code_exists(
    /*체크할 등록번호로 등록된 사업자가 존재하는지 체크한 후 존재한다면 1, 그렇지 않으면 0을 반환하게 됨*/
		IN_PERMIT_REG_CODE, 
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
    /*같은 등록번호를 가진 사업자가 존재하지 않는 경우에는 정상처리 진행한다.*/         
        CALL sp_req_user_exists_by_id(
			IN_USER_ID, 
            TRUE, 
			@rtn_val,
			@msg_txt
        );
        /*IN_USER_ID가 이미 등록되어 있는 사용자인지 체크한다. 
        등록되어 있는 경우에는 @USER_EXISTS = 1, 
        그렇지 않은 경우에는 @USER_EXISTS = 0을 반환한다.*/
        
        IF @rtn_val = 0 THEN
        /*이미 등록되어 있는 사용자인 경우에는 관리자(member.admin)인지 검사한 후 
        member.admin인 경우에는 사업자 생성권한을 부여하고 
        그렇지 않은 경우에는 예외처리한다.*/
			CALL sp_req_comp_id_of_site(
            /*사이트 아이디로 사업자 고유등록번호를 반환한다.*/
				IN_SITE_ID,
                @COMP_ID
            );
            
			CALL sp_req_super_permission_by_userid(
				IN_USER_ID, 
                @COMP_ID, 
                @REGISTRATION_RIGHT,
                @IS_USER_BELONGS_TO_HEAD_OFFICE,
				@rtn_val,
				@msg_txt
            );
			/*@REGISTRATION_RIGHT로 사업자 등록을 요청하는 사용자의 권한을 구분한다.*/
			
			IF @REGISTRATION_RIGHT IN (1, 2, 3, 5) THEN
			/*등록을 요청하는 사용자(IN_USER_ID)가 시스템 관리자(1, 2)인 경우, 
            모회사의 관리자가 자회사의 정보를 입력하는 경우(3), 
            자신이 속한 사업에 대한 정보를 입력하는 경우(5)로서 정상처리 진행한다.*/
				UPDATE COMP_SITE 
                /*사이트에 허가증 정보를 반영하여 변경적용한다.*/
                SET 
					PERMIT_REG_CODE 			= IN_PERMIT_REG_CODE, 
					PERMIT_REG_IMG_PATH 		= IN_PERMIT_REG_IMG_PATH, 
					UPDATED_AT			 		= @REG_DT
                WHERE ID = IN_SITE_ID;
			
				IF ROW_COUNT() = 1 THEN
				/*사업자 레코드가 정상적으로 생성된 경우에는 정상처리한다.*/
					CALL sp_update_site_wste_lists_without_handler(
                    /*폐기물 리스트를 업데이트 한다.*/
						IN_USER_ID,
                        IN_WSTE_CODE_LIST,
                        IN_SITE_ID,
                        @REG_DT,
                        @rtn_val,
                        @msg_txt
                    );
                    
                    IF @rtn_val = 0 THEN
						SET @rtn_val 		= 0;
						SET @msg_txt 		= 'Success';
                    ELSE
						SIGNAL SQLSTATE '23000';
                    END IF;
				ELSE
				/*사업자 레코드가 정상적으로 생성되지 않은 경우에는 예외처리한다.*/
					SET @rtn_val 		= 21901;
					SET @msg_txt 		= 'Failed to add collection and transport business permission to members';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*@P_COMP_ID로 반환되는 값이 0인 경우에는 IN_USER_ID가 관리자(member.admin:201)로서의 
            권한이 없는 상황이기때문에 사업자 생성로직을 중단한 후 예외처리해야 한다.*/
            /*사업자를 생성하는 로직에는 관리자 정보가 필수이기때문에 
            치움의 sys.admin이 스스로 회원사로 가입할 사업자를 생성할 수 없다.*/
				SET @rtn_val 		= 21902;
				SET @msg_txt 		= 'user not authorized to modify site information';
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
        /*변경요청을 시도하는 사용자가 유효하지 않은 사용자인 경우에는 예외처리한다.*/
			SIGNAL SQLSTATE '23000';
        END IF;
	ELSE   
    /*같은 등록번호를 가진 사업자가 존재하는 경우에는 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END