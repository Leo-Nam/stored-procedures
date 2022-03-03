CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_site_permit_info_without_handler`(
	IN IN_USER_ID 						BIGINT,				/*입력값 : 관리자 고유등록번호*/
	IN IN_SITE_ID 						BIGINT,				/*입력값 : 사업자 고유식별 번호*/
	IN IN_WSTE_LIST						JSON,				/*입력값 : 폐기물 구분 코드(JSON)*/
	IN IN_TRMT_BIZ_CODE					VARCHAR(4),			/*입력값 : 사이트 업종구분*/
	IN IN_PERMIT_REG_CODE				VARCHAR(100),		/*입력값 : 사이트 업종구분*/
	IN In_PERMIT_REG_IMG_PATH			VARCHAR(200),		/*입력값 : 사이트 업종구분*/
	OUT rtn_val 						INT,				/*출력값 : 처리결과 반환값*/
	OUT msg_txt 						VARCHAR(100)		/*출력값 : 처리결과 문자열*/
	)
BEGIN

/*
Procedure Name 	: sp_update_site_permit_info_without_handler
Input param 	: 6개
Output param 	: 2개
Job 			: 수거자등으로 등록할 사업자의 사이트 정보를 업데이트 처리한다.
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.02.11
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/

    DECLARE JOB_TXT			VARCHAR(200);		/*변경사항에 대한 내용을 저장할 변수 선언*/
    DECLARE JOB_TXT_DETAIL	VARCHAR(200);		/*변경사항에 대한 내용을 저장할 변수 선언*/
    
    SET JOB_TXT_DETAIL = NULL;
    
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
    CALL sp_req_site_exists(
		IN_SITE_ID,
        TRUE,
        @rtn_val,
        @msg_txt
	);
    /*사이트가 존재하는지 체크한 후 존재한다면 0, 그렇지 않으면 예외코드를 반환하게 됨*/
    
    IF @rtn_val = 0 THEN
    /*사이트가 존재하는 경우에는 정상처리 진행한다.*/   	
		CALL sp_req_comp_id_of_site(
			IN_SITE_ID,
			@COMP_ID
		);
		
		CALL sp_req_super_permission_by_userid(
			IN_USER_ID,
			@COMP_ID,
			@PERMISSION,
			@IS_USER_SITE_HEAD_OFFICE,
			@rtn_val,
			@msg_txt
		);
		
		CALL sp_req_user_class_by_user_reg_id(
			IN_USER_ID,
			@USER_CLASS
		);
		
		CALL sp_req_site_id_of_user_reg_id(
			IN_USER_ID,
			@USER_SITE_ID,
            @rtn_val,
            @msg_txt
		);
        
        IF @rtn_val = 0 THEN
        /*사용자가 소속한 사이트가 존재하는 경우 정상처리한다.*/		
			IF @PERMISSION = 1 OR @PERMISSION = 2 OR ((@PERMISSION = 3 OR @PERMISSION = 5) AND @IS_SITE_HEAD_OFFICE = TRUE) OR (@USER_CLASS = 201 AND @USER_SITE_ID = IN_SITE_ID) THEN
			/*사이트의 모든 정보에 대한 접근 권한이 있는 경우*/   
				CALL sp_update_site_wste_cls(
					IN_SITE_ID, 
					IN_WSTE_LIST, 
					@REG_DT, 
					@rtn_val, 
					@msg_txt
				);
				
				IF @rtn_val = 0 THEN
				/*사이트에서 관리되는 폐기물 코드에 대한 업데이트를 성공하였다면 정상처리 진행한다.*/
					UPDATE COMP_SITE 
					SET 
						TRMT_BIZ_CODE 			= IN_TRMT_BIZ_CODE, 
						PERMIT_REG_CODE 		= IN_PERMIT_REG_CODE, 
						PERMIT_REG_IMG_PATH 	= In_PERMIT_REG_IMG_PATH, 
						UPDATED_AT 				= @REG_DT 
					WHERE ID 					= IN_SITE_ID;
					/*변경사항을 적용한다.*/
						
					IF ROW_COUNT() = 0 THEN
					/*저장이 되지 않은 경우에는 예외처리한다.*/
						SET rtn_val = 22502;
						SET msg_txt = 'Fail to apply changes to the site';
					ELSE
						SET rtn_val = 0;
						SET msg_txt = 'Business information is updated successfully';
					END IF;
				ELSE
				/*사이트에서 관리되는 폐기물 코드에 대한 업데이트를 실패하였다면 예외처리 진행한다.*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
				END IF;
			ELSE
			/*사이트 정보에 대한 수정권한이 없는 경우*/
				SET rtn_val = 22503;
				SET msg_txt = 'No right to edit the site';
			END IF;
        ELSE
        /*사용자가 소속한 사이트가 존재하지 않는 경우 예외처리한다.*/
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt;
        END IF;
	ELSE   
    /*사이트가 존재하지 않는 경우에는 예외처리한다.*/
		SET rtn_val = @rtn_val;
        SET msg_txt = @msg_txt;
	END IF;
END