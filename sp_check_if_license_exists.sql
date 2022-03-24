CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_if_license_exists`(
	IN IN_USER_ID			BIGINT
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    CALL sp_req_user_exists_by_id(
		IN_USER_ID,			/*사이트를 개설하려는 자의 고유등록번호*/
        TRUE,					/*ACTIVE가 TRUE인 상태(활성화 상태)인 사용자에 한정*/
		@rtn_val,
		@msg_txt
    );
    IF @rtn_val = 0 THEN
		CALL sp_req_site_id_of_user_reg_id(
		/*사용자 고유등록번호로 사용자가 소속한 사이트의 고유등록번호를 반환한다.*/
			IN_USER_ID,
			@USER_SITE_ID,
			@rtn_val,
			@msg_txt
		);
		IF @rtn_val = 0 THEN
			CALL sp_req_site_id_of_user_reg_id(
			/*사용자 고유등록번호로 사용자가 소속한 사이트의 고유등록번호를 반환한다.*/
				IN_USER_ID,
				@USER_SITE_ID,
				@rtn_val,
				@msg_txt
			);
			IF @rtn_val = 0 THEN
				CALL sp_req_is_site_collector(
				/*사이트가 수거업체인지 확인한다*/
					@USER_SITE_ID,
					@rtn_val,
					@msg_txt
				);
				IF @rtn_val > 0 THEN
					SIGNAL SQLSTATE '23000';
                END IF;
			ELSE
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;   
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END