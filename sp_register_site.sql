CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_register_site`(
    IN IN_USER_ID						BIGINT,
    IN IN_TARGET_ID						BIGINT
)
BEGIN

/*
Procedure Name 	: sp_register_site
Input param 	: 1개
Job 			: 배출자가 수거업체의 사이트를 등록업체로 등록한다.
Update 			: 2022.05.09
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/	

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data = NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;  
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
	SET @USER_ID 		= IN_USER_ID;
	SET @TARGET_ID 		= IN_TARGET_ID;
	SET @rtn_val 		= NULL;
	SET @msg_txt 		= NULL;
	SET @json_data		= NULL;
    
	CALL sp_req_current_time(@REG_DT);
    
    SELECT AFFILIATED_SITE INTO @USER_SITE_ID
    FROM USERS
    WHERE ID = @USER_ID;
    
    SET @IS_SITE_REGISTERED = FALSE;
    SET @REGISTERED_SITE_COUNT = 0;
    IF @USER_SITE_ID = 0 THEN
    /*배출자가 개인인 경우*/
		SELECT COUNT(ID) INTO @REGISTERED_SITE_COUNT
		FROM REGISTERED_SITE
		WHERE 
			USER_ID = @USER_ID AND
            DELETED_AT IS NULL AND
			ACTIVE = TRUE AND
            REGISTER_TYPE = 1;
            
		SELECT COUNT(ID) INTO @IS_SITE_REGISTERED
		FROM REGISTERED_SITE
		WHERE 
			USER_ID = @USER_ID AND
            TARGET_ID = @TARGET_ID AND
            DELETED_AT IS NULL AND
			ACTIVE = TRUE AND
            REGISTER_TYPE = 1;
    ELSE
    /*배출자가 사업자인 경우*/
		SELECT COUNT(ID) INTO @REGISTERED_SITE_COUNT
		FROM REGISTERED_SITE
		WHERE 
			SITE_ID = @USER_SITE_ID AND
            DELETED_AT IS NULL AND
			ACTIVE = TRUE AND
            REGISTER_TYPE = 1;
            
		SELECT COUNT(ID) INTO @IS_SITE_REGISTERED
		FROM REGISTERED_SITE
		WHERE 
			SITE_ID = @USER_SITE_ID AND
            TARGET_ID = @TARGET_ID AND
            DELETED_AT IS NULL AND
			ACTIVE = TRUE AND
            REGISTER_TYPE = 1;
    END IF;
    
	/*무료로 등록할 수 있는 수거업체의 개소수를 @max_site_registeration에 반환한다.*/
	CALL sp_req_policy_direction(
		'max_site_registeration',
		@max_site_registeration
	);
    
    IF @max_site_registeration > @REGISTERED_SITE_COUNT THEN
    /*등록가능한 수거업체의 개소수에 여유가 있는 경우 정상처리한다.*/
		IF @IS_SITE_REGISTERED = 0 THEN
        /*등록이 가능한 경우 정상처리한다.*/
			INSERT REGISTERED_SITE(
				USER_ID,
				SITE_ID,
				TARGET_ID,
				CREATED_AT,
				UPDATED_AT,
				DELETED_AT,
				ACTIVE,
                REGISTER_TYPE
			) VALUES (
				@USER_ID,
				@USER_SITE_ID,
				@TARGET_ID,
				@REG_DT,
				@REG_DT,
				NULL,
				TRUE,
                1
			);
			IF ROW_COUNT() = 1 THEN
				SET @rtn_val 		= 0;
				SET @msg_txt 		= 'success';
			ELSE
				SET @rtn_val 		= 39502;
				SET @msg_txt 		= 'failed to register site information';
				SIGNAL SQLSTATE '23000';
			END IF;
        ELSE
        /*등록이 불가능한 경우 예외처리한다.*/
			SET @rtn_val 		= 39503;
			SET @msg_txt 		= 'site is already registered';
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*등록가능한 수거업체의 개소수에 여유가 없는 경우 예외처리한다.*/
		SET @rtn_val 		= 39501;
		SET @msg_txt 		= 'can not register sites any more';
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
    SET @json_data = NULL;
    CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END