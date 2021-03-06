CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_upload_license_old`(
	IN IN_USER_ID			BIGINT,				/*입력값 : 사이트 등록자 아이디(USER.ID)*/
	IN IN_SITE_ID			BIGINT,				/*입력값 : 사이트 등록 아이디(COMP_SITE.ID)*/
	IN IN_LICENSE_PATH		VARCHAR(200)		/*입력값 : 허가증 저장경로*/
)
BEGIN

/*
Procedure Name 	: sp_upload_license
Input param 	: 2개
Job 			: 허가증 개별 등록
Update 			: 2022.03.23
Version			: 0.0.1
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
    
    CALL sp_req_user_exists_by_id(
		IN_USER_ID,			/*사이트를 개설하려는 자의 고유등록번호*/
        TRUE,					/*ACTIVE가 TRUE인 상태(활성화 상태)인 사용자에 한정*/
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우*/
		CALL sp_req_site_id_of_user_reg_id(
        /*사용자가 소속한 사이트의 고유등록번호를 반환한다.*/
			IN_USER_ID,
            @USER_SITE_ID,
			@rtn_val,
			@msg_txt
        );
        IF @rtn_val = 0 THEN
			IF @USER_SITE_ID = IN_SITE_ID THEN
				SELECT B.PERMIT_REG_IMG_PATH, B.LICENSE_CONFIRMED
				INTO @PERMIT_REG_IMG_PATH, @LICENSE_CONFIRMED
				FROM USERS A 
				LEFT JOIN COMP_SITE B ON A.AFFILIATED_SITE = B.ID
				WHERE A.ID = IN_USER_ID;
                IF @PERMIT_REG_IMG_PATH IS NULL AND @LICENSE_CONFIRMED = FALSE THEN
                /*허가증 이미지가 존재하지 않거나 허가증이 CS로부터 확인이 되지 않은 경우에는 허가증 업데이트가 가능하도록 처리함*/
					UPDATE COMP_SITE SET PERMIT_REG_IMG_PATH = IN_LICENSE_PATH, UPDATED_AT = @REG_DT WHERE ID = IN_SITE_ID;
					IF ROW_COUNT() = 1 THEN
						IF IN_LICENSE_PATH IS NULL THEN
						/*허가증 이미지 경로가 NULL이 아닌 경우에는 허가증 변경(등록)으로 간주하고 변경(등록)처리한다.*/
							UPDATE COMP_SITE SET CONFIRMED = FALSE WHERE ID = IN_SITE_ID;
							IF ROW_COUNT() = 1 THEN
								SET @rtn_val 		= 0;
								SET @msg_txt 		= 'Success';
							ELSE
								SET @rtn_val 		= 34504;
								SET @msg_txt 		= 'Failed to delete the license';
								SIGNAL SQLSTATE '23000';
							END IF;
						ELSE
							SET @rtn_val 		= 0;
							SET @msg_txt 		= 'Success';
						END IF;
					ELSE
						SET @rtn_val 		= 34501;
						SET @msg_txt 		= 'Failed to save the License image path';
						SIGNAL SQLSTATE '23000';
					END IF;
                ELSE
                /*그 이외의 경우에는 허가증 업데이트에 대한 예외처리해야 함*/
					SET @rtn_val 		= 34503;
					SET @msg_txt 		= 'license already registered';
					SIGNAL SQLSTATE '23000';
                END IF;
			ELSE
				SET @rtn_val 		= 34502;
				SET @msg_txt 		= 'User is not part of the site';
				SIGNAL SQLSTATE '23000';
			END IF;
        ELSE
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