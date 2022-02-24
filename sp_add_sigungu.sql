CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_add_sigungu`(
	IN IN_USER_ID			BIGINT,				/*입력값 : 사업지역을 추가하고자 하는 사이트의 관리자(USERS.ID)*/
	IN IN_SIGUNGU_CODE		VARCHAR(10),		/*입력값 : 추가하고자 하는 시군구코드(KIKCD_B.B_CODE)*/
	IN IN_IS_DEFAULT		TINYINT				/*입력값 : 최초 사업자가 만들어질때는 사업자가 소재하는 시군구를 기본값으로 등록하게 되므로 TRUE로 값을 전달하고 그 이외에 추가하는 시군구에 대해서는 FALSE로 값을 전달한다.*/
)
BEGIN

/*
Procedure Name 	: sp_add_sigungu
Input param 	: 3개
Job 			: 수집운반업자 등의 허가를 갖춘 사이트가 사업지역을 추가한다.(시군구 단위)
Update 			: 2022.01.27
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.2)
*/					
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;				
    /*트랜잭션 시작*/  

    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
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
				CALL sp_req_sigungu_is_already_added(
                /*검사하고자 하는 시군구가 이미 사이트에 등록되어 있는지 검사한다*/
					@SITE_ID,
                    IN_SIGUNGU_CODE,
					@rtn_val,
					@msg_txt
                );
                IF @rtn_val = 0 THEN
                /*시군구가 사이트에 등록되어 있지 않은 경우*/
					INSERT INTO BUSINESS_AREA (
						SITE_ID, 
                        KIKCD_B_CODE, 
                        IS_DEFAULT, 
                        CREATED_AT
					) 
					VALUES (
						@SITE_ID, 
                        IN_SIGUNGU_CODE, 
                        IN_IS_DEFAULT, 
                        @REG_DT
					);
					
                    IF ROW_COUNT() = 1 THEN
                    /*레코드가 정상적으로 생성되었다면*/
						SET @rtn_val 		= 0;
						SET @msg_txt 		= 'The business area has been registered successfully';
                    ELSE
                    /*레코드가 정상적으로 생성되지 않았다면*/
						SET @rtn_val 		= 24001;
						SET @msg_txt 		= 'DB error occurred while adding business area';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*시군구가 사이트에 이미 등록되어 있는 경우*/
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