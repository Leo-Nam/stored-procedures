CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_company_permit_info_without_handler`(
	IN IN_USER_REG_ID			VARCHAR(50),		/*입력값 : 관리자아이디*/
    IN IN_COMP_ID 				BIGINT,				/*입력값 : 사업자 고유식별 번호*/
    IN IN_TRMT_BIZ_CODE 		VARCHAR(4),			/*입력값 : 사업자 분류코드로서 WSTE_TRMT_BIZ에 등록된 종류별 코드임*/
    IN IN_PERMIT_REG_CODE 		VARCHAR(100),		/*입력값 : 수거자 등으로 등록할 등록 또는 신고번호*/
    IN IN_PERMIT_REG_IMG_PATH 	VARCHAR(100),		/*입력값 : 수거자 등으로 등록할 등록증 또는 신고증명서의 업로드 경로*/
	IN IN_WSTE_CLS				VARCHAR(200),		/*입력값 : 폐기물 구분 코드(ARRAY)*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(100)		/*출력값 : 처리결과 문자열*/
    )
BEGIN

/*
Procedure Name 	: sp_update_company_permit_info_without_handler
Input param 	: 6개
Output param 	: 2개
Job 			: 수거자등으로 등록할 사업자의 정보를 업데이트 처리한다.
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.15
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
    CALL sp_req_company_exists(
		IN_COMP_ID, 
        TRUE, 
        @COMP_EXISTS
    );
    /*체크할 사업자등록번호로 등록된 사업자가 존재하는지 체크한 후 존재한다면 1, 그렇지 않으면 0을 반환하게 됨*/
    
    IF @COMP_EXISTS = 0 THEN
    /*사업자가 존재하는 경우에는 정상처리 진행한다.*/         
        CALL sp_req_user_exists(
			IN_USER_REG_ID, 
            TRUE, 
			@rtn_val, 
			@msg_txt
        );
        /*IN_USER_REG_ID가 이미 등록되어 있는 사용자인지 체크한다. 등록되어 있는 경우에는 @USER_EXISTS = 1, 그렇지 않은 경우에는 @USER_EXISTS = 0을 반환한다.*/
        
        IF @rtn_val = 0 THEN
        /*사업자 정보에 대한 변경요청을 한 사용자가 존재하는 경우에는 정상처리함*/
			UPDATE COMPANY 
			SET 
				TRMT_BIZ_CODE 		= IN_TRMT_BIZ_CODE, 
				PERMIT_REG_CODE 	= IN_PERMIT_REG_CODE, 
				PERMIT_REG_IMG_PATH = IN_PERMIT_REG_IMG_PATH, 
				UPDATED_AT 			= @REG_DT 
			WHERE ID 				= IN_COMP_ID;
			/*변경사항을 적용한다.*/
			
			IF ROW_COUNT() = 1 THEN
			/*저장이 되지 않은 경우에는 예외처리한다.*/
				SET rtn_val = 0;
				SET msg_txt = 'Success';
			ELSE
				SET rtn_val = 27702;
				SET msg_txt = 'Business information not updated';
			END IF;
		ELSE
        /*사업자 정보에 대한 변경요청을 한 사용자가 존재하지 않는 계정인 경우에는 예외 처리함*/
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt;
        END IF;
	ELSE  
    /*사업자가 존재하지 않는 경우에는 예외처리한다.*/
		SET rtn_val = 27701;
        SET msg_txt = 'No company exists';
	END IF;
END