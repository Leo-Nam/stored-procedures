CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_company`(
	IN IN_USER_ID 				BIGINT,				/*입력값 : 관리자아이디(USERS.ID)*/
    IN IN_COMP_ID 				BIGINT,				/*입력값 : 사업자 고유식별 번호*/
    IN IN_COMP_NAME 			VARCHAR(100),		/*입력값 : 사업자 상호*/
    IN IN_REP_NAME 				VARCHAR(50),		/*입력값 : 대표자 이름*/
    IN IN_KIKCD_B_CODE 			VARCHAR(10),		/*입력값 : 사무실 소재지 시군구 법정동코드로서 10자리 코드*/
    IN IN_ADDR 					VARCHAR(255),		/*입력값 : 사무실 소재지 상세주소*/
    IN IN_CONTACT 				VARCHAR(100),		/*입력값 : 사무실 연락처*/
    IN IN_TRMT_BIZ_CODE 		VARCHAR(4),			/*입력값 : 사업자 분류코드로서 WSTE_TRMT_BIZ에 등록된 종류별 코드임*/
    IN IN_BIZ_REG_CODE 			VARCHAR(12),		/*입력값 : 사업자번호*/
    IN IN_PERMIT_REG_CODE 		VARCHAR(100),		/*입력값 : 허가증 또는 신고증명서번호*/
    IN IN_BIZ_REG_IMG_PATH 		VARCHAR(200),		/*입력값 : 사업자등록증 저장 경로*/
    IN IN_PERMIT_REG_IMG_PATH 	VARCHAR(200)		/*입력값 : 허가증 또는 신고증명서 저장경로*/
    )
BEGIN

/*
Procedure Name 	: sp_update_company
Input param 	: 12개
Job 			: COMPANY테이블에 대한 정보 수정
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.29
Version			: 0.0.3
AUTHOR 			: Leo Nam
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
    
    CALL sp_req_company_exists(
		IN_COMP_ID, 
        TRUE, 
		@rtn_val, 
		@msg_txt
    );
    /*체크할 사업자등록번호로 등록된 사업자가 존재하는지 체크한 후 존재한다면 1, 그렇지 않으면 0을 반환하게 됨*/
    
    IF @rtn_val = 0 THEN 
    /*같은 사업자등록번호를 가진 사업자가 존재하는 경우에는 정상처리 진행한다.*/ 
        CALL sp_req_user_exists_by_id(
			IN_USER_ID, 
            TRUE, 
			@rtn_val, 
			@msg_txt
        );
        
        IF @rtn_val = 0 THEN
        /*사업자 정보에 대한 변경요청을 한 사용자가 존재하는 경우에는 정상처리함*/
			CALL sp_req_super_permission_by_userid(
				IN_USER_ID, 
                IN_COMP_ID, 
                @PERMISSION,
                @HEAD_OFFICE
            );
            IF @PERMISSION IN (1, 2, 3, 5) THEN
			/*등록을 요청하는 사용자(IN_USER_ID)가 시스템 관리자(1, 2)인 경우, 모회사의 관리자가 자회사의 정보를 입력하는 경우(3), 자신이 속한 사업에 대한 정보를 입력하는 경우(5)로서 정상처리 진행한다.*/
				UPDATE COMPANY 
				SET 
					COMP_NAME 			= IN_COMP_NAME, 
					REP_NAME 			= IN_REP_NAME, 
					KIKCD_B_CODE 		= IN_KIKCD_B_CODE, 
					ADDR 				= IN_ADDR, 
					CONTACT 			= IN_CONTACT, 
					TRMT_BIZ_CODE 		= IN_TRMT_BIZ_CODE, 
					BIZ_REG_CODE 		= IN_BIZ_REG_CODE, 
					PERMIT_REG_CODE 	= IN_PERMIT_REG_CODE, 
					BIZ_REG_IMG_PATH 	= IN_BIZ_REG_IMG_PATH, 
					PERMIT_REG_IMG_PATH = IN_PERMIT_REG_IMG_PATH, 
					UPDATED_AT 			= @REG_DT 
				WHERE ID 				= IN_COMP_ID;
				/*변경사항을 적용한다.*/
				
				IF ROW_COUNT() = 0 THEN
				/*저장이 되지 않은 경우에는 예외처리한다.*/
					SET @rtn_val = 20401;
					SET @msg_txt = 'Business information has not changed';
					SIGNAL SQLSTATE '23000';
				ELSE
					SET @rtn_val = 0;
					SET @msg_txt = 'Business information is updated successfully';
				END IF;
			ELSE
            /*권한이 없는 경우에는 예외처리한다.*/
				SET @rtn_val = 20402;
				SET @msg_txt = 'No right to change business information';
				SIGNAL SQLSTATE '23000';
            END IF;
		ELSE
        /*사업자 정보에 대한 변경요청을 한 사용자가 존재하지 않는 계정인 경우에는 예외 처리함*/
			SIGNAL SQLSTATE '23000';
        END IF;
	ELSE  
    /*같은 사업자등록번호를 가진 사업자가 존재하지 않는 경우에는 예외처리한다.*/
        SIGNAL SQLSTATE '23000';
	END IF;
	COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END