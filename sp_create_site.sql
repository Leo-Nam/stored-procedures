CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_site`(
	IN IN_USER_ID			BIGINT,				/*입력값 : 사이트 등록자 아이디(USER.ID)*/
	IN IN_COMP_ID			BIGINT,				/*입력값 : 사업자 고유등록번호*/
	IN IN_KIKCD_B_CODE		VARCHAR(10),		/*입력값 : 사이트가 소재하는 주소지에 대한 시군구 법정동코드*/
	IN IN_ADDR				VARCHAR(255),		/*입력값 : 사이트가 소재하는 주소지에 대한 시군구 주소를 제외한 상세주소*/
	IN IN_SITE_NAME			VARCHAR(255),		/*입력값 : 사이트 이름*/
	IN IN_CONTACT			VARCHAR(100)		/*입력값 : 사이트 연락처*/
)
BEGIN

/*
Procedure Name 	: sp_create_site
Input param 	: 6개
Job 			: 예외처리 핸들러를 가지고 사이트를 개설하는 경우로서 사용자가 사이트를 추가로 개설하려는 경우에 사용한다.
				: 최초의 사이트는 사업자 개설시 자동으로 1개소가 개설됨
Update 			: 2022.01.27
Version			: 0.0.6
AUTHOR 			: Leo Nam
Change			: Creator 정보 입력 부분 삭제(0.0.3)
				: 기존 사업자 고유등록정보를 INPUT PARAM으로 받는 방식에서 사업자등록번호를 INPUT PARAM으로 받아서 사업자를 식별하는 방식으로 변경
				: 사업자등록번호를 사업자고유등록번호(COMPANY.ID)로 변경
				: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.6)
				: 사이트의 최초 환경설정 기능 추가(0.0.6)
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    SET @LAT = NULL, @LNG = NULL;
    /*사이트 소재지의 위경도는 NULL값으로 하고 시스템 관리자에 의하여 그 값(위경도 계산 API 사용하여 일괄적으로 처리)이 정해짐*/
    
    SET @HEAD_OFFICE = FALSE;
    /*추가로 개설되는 사이트는 모두 HEAD_OFFICE가 아님*/
    /*HEAD_OFFICE는 삭제가 불가능하고 사업자를 삭제하는 경우에만 삭제가 되므로 사업자는 최소 1개의 사이트를 가지게 됨*/
    
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
    CALL sp_req_user_exists_by_id(
		IN_USER_ID,			/*사이트를 개설하려는 자의 고유등록번호*/
        TRUE,					/*ACTIVE가 TRUE인 상태(활성화 상태)인 사용자에 한정*/
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우*/           
		CALL sp_req_whether_site_is_open(
		/*사업자가 추가로 사이트를 개설할 수 있는지 여부를 반환한다.*/
			IN_COMP_ID,
			@rtn_val,
			@msg_txt
		);
		
		IF @rtn_val = 0 THEN
		/*사업자가 추가로 사이트를 개설할 수 있는 경우*/
			CALL sp_req_super_permission_by_userid(
				IN_USER_ID,
				IN_COMP_ID,
				@PERMISSION,
				@IS_SITE_HEAD_OFFICE
			);
			
			IF @PERMISSION = 1 OR @PERMISSION = 2 OR ((@PERMISSION = 3 OR @PERMISSION = 5) AND @IS_SITE_HEAD_OFFICE = TRUE) THEN
			/*사이트를 개설할 권한이 있는 경우*/
			/*1. 치움서비스의 관리자 그룹에 속하는 사용자인 경우*/
			/*2. 사용자가 속한 사이트가 HEAD OFFICE이면서 사용자의 권한이 201인 경우*/
            
				CALL sp_create_site_without_handler(
					IN_USER_ID,
                    IN_COMP_ID,
					IN_KIKCD_B_CODE,
					IN_ADDR,
					IN_SITE_NAME,
                    NULL,
					@REG_DT,
					IN_CONTACT,
					@LAT,
					@LNG,
					@HEAD_OFFICE,
					@SITE_REG_ID,
					@rtn_val,
					@msg_txt
                );
				
				IF @rtn_val = 0 THEN
				/*사이트 개설에 성공한 경우*/
					CALL sp_create_site_configuration(
                    /*사이트에 대한 최초의 환경설정을 한다.*/
						@SITE_REG_ID,
						@rtn_val,
						@msg_txt
                    );
                    IF @rtn_val > 0 THEN
                    /*사이트의 환경설정에 실패한 경우*/
						SIGNAL SQLSTATE '23000';
                    END IF;
				ELSE
				/*사이트 개설에 실패한 경우*/
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사이트를 개설할 권한이 없는 경우*/
				SET @rtn_val 		= 21401;
				SET @msg_txt 		= 'No authority to open a site';
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
		/*사업자가 추가로 사이트를 개설할 수 없는 경우*/
			SIGNAL SQLSTATE '23000';
		END IF;
	ELSE
    /*사용자가 존재하지 않는 경우*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END