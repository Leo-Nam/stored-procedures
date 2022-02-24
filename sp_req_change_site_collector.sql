CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_change_site_collector`(
	IN IN_USER_ID 						BIGINT,				/*입력값 : 사용자 고유등록번호*/
    IN IN_SITE_ID						BIGINT,				/*입력값 : 관리자암호*/
	IN IN_WSTE_LIST						JSON,				/*입력값 : 폐기물 구분 코드(JSON)*/
	IN IN_TRMT_BIZ_CODE					VARCHAR(4),			/*입력값 : 사이트 업종구분*/
	IN IN_PERMIT_REG_CODE				VARCHAR(100),		/*입력값 : 사이트 업종구분*/
	IN IN_PERMIT_REG_IMG_PATH			VARCHAR(200)		/*입력값 : 사이트 업종구분*/
    )
BEGIN

/*
Procedure Name 	: sp_req_change_site_collector
Input param 	: 6개
Job 			: 사이트를 수거업자등으로 변경한다.
Update 			: 2022.02.11
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
	
    /*사이트가 소재하는 주소지에 대한 위도 경도값은 NULL처리 한다.*/
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
    CALL sp_req_user_exists_by_id(
		IN_CREATOR_ID,			/*사이트를 개설하려는 자의 고유등록번호*/
        TRUE,					/*ACTIVE가 TRUE인 상태(활성화 상태)인 사용자에 한정*/
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
	/*사용자가 존재하는 경우 정상처리한다.*/
		CALL sp_req_site_id_of_user_reg_id(
			IN_USER_ID,
            @USER_SITE_ID,
            @rtn_val,
            @msg_txt
        );
        IF @rtn_val = 0 THEN
        /*사용자가 소속한 사이트가 존재하는 경우 정상처리한다.*/
			IF IN_SITE_ID = @USER_SITE_ID THEN
            /*사용자가 소속한 사이트와 정보를 변경할 대상인 사이트가 동일한 경우 정상처리한다.*/
				CALL sp_req_user_class(
					IN_USER_ID,
                    @USER_CLASS
                );
                IF @USER_CLASS = 201 THEN
                /*사용자가 사이트의 정보를 변경할 권한이 있는 경우 정상처리한다.*/
					CALL sp_update_site_permit_info_without_handler(
						IN_USER_ID,
                        IN_SITE_ID,
                        IN_WSTE_LIST,
                        IN_TRMT_BIZ_CODE,
                        IN_PERMIT_REG_CODE,
                        IN_PERMIT_REG_IMG_PATH,
                        @rtn_val,
                        @msg_txt
                    );
                    IF @rtn_val = 0 THEN
                    /*정보를 성공적으로 변경한 경우에는 정상처리한다.*/
						SET @json_data 		= NULL;
						SET @rtn_val = 0;
						SET @msg_txt = 'Success';
                    ELSE
                    /*정보 변경에 실패한 경우에는 예외처리한다.*/
						SET @json_data 		= NULL;
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*사용자가 사이트의 정보를 변경할 권한이 없는 경우 예외처리한다.*/
					SET @json_data 		= NULL;
					SET @rtn_val = 30002;
					SET @msg_txt = 'Users are not authorized to change information on the site.';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사용자가 소속한 사이트와 정보를 변경할 대상인 사이트가 동일하지 않은 경우 예외처리한다.*/
				SET @json_data 		= NULL;
                SET @rtn_val = 30001;
                SET @msg_txt = 'User is not affiliated with the site';
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*사용자가 소속한 사이트가 존재하지 않는 경우 예외처리한다.*/
			SET @json_data 		= NULL;
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
	/*사용자가 존재하지 않는 경우 예외처리한다.*/
		SET @json_data 		= NULL;
		SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END