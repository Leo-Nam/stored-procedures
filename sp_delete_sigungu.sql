CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_sigungu`(
	IN IN_USER_ID			BIGINT,				/*입력값 : 사업지역을 추가하고자 하는 사이트의 관리자(USERS.ID)*/
	IN IN_SIGUNGU_CODE		VARCHAR(10)			/*입력값 : 추가하고자 하는 시군구코드(KIKCD_B.B_CODE)*/
)
BEGIN

/*
Procedure Name 	: sp_delete_sigungu
Input param 	: 2개
Job 			: 수집운반업자 등의 허가를 갖춘 사이트가 사업지역을 삭제한다.(시군구 단위)
Update 			: 2022.03.29
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
    
	CALL sp_req_user_exists_by_id(
    /*DISPOSER가 존재하면서 활성화된 상태인지 검사한다.*/
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
    /*사용자가 존재한다면*/
		CALL sp_req_site_id_of_user_reg_id(
        /*사용자가 소속한 사이트의 고유등록번호를 구한다.*/
			IN_USER_ID,
            @SITE_ID,
			@rtn_val,
			@msg_txt
        );
		IF @rtn_val = 0 THEN
		/*사이트가 정상(개인사용자는 제외됨)적인 경우*/
			CALL sp_req_is_site_collector(
            /*사이트가 수거자등인지 검사한다.*/
				@SITE_ID,
				@rtn_val,
				@msg_txt
            );
            IF @rtn_val = 0 THEN
            /*사이트가 수거자 종류이면*/
				SELECT COUNT(ID) INTO @AREA_COUNT
                FROM BUSINESS_AREA
                WHERE 
					SITE_ID = @SITE_ID AND
                    KIKCD_B_CODE = IN_SIGUNGU_CODE AND
                    ACTIVE = TRUE;                
                IF @AREA_COUNT > 0 THEN
                /*시군구가 사이트에 등록되어 있는 경우*/
					UPDATE BUSINESS_AREA
                    SET
						ACTIVE = FALSE,
                        DELETED_AT = @REG_DT
					WHERE 
						SITE_ID = @SITE_ID AND
						KIKCD_B_CODE = IN_SIGUNGU_CODE AND
						ACTIVE = TRUE;  
					IF ROW_COUNT() = 1 THEN
                    /*성공적으로 삭제가 완료된 경우 정상처리한다.*/
						SET @rtn_val 		= 0;
						SET @msg_txt 		= 'success';
                    ELSE
                    /*삭제에 실패한 경우 예외처리한다.*/
						SET @rtn_val 		= 35501;
						SET @msg_txt 		= 'Failed to delete region of interest';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*시군구가 사이트에 등록되어 있지 않은 경우*/
					SET @rtn_val 		= 35502;
					SET @msg_txt 		= 'Unregistered area of ​​interest';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*사이트가 수거자 종류가 아니면*/
				SIGNAL SQLSTATE '23000';
            END IF;
		ELSE
		/*사이트가 존재하지 않거나 유효하지 않은(개인사용자의 경우) 경우*/
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
    /*사용자가 존재하지 않거나 유효하지 않다면*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;   
    
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END