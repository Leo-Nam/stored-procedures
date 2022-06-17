CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_delete_registered_site_2_without_handler`(
	IN IN_USER_ID					BIGINT,
    IN IN_USER_TYPE					INT,
	IN IN_TARGET_ID					BIGINT,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_req_delete_registered_site_2_without_handler
Input param 	: 2개
Job 			: 기존업체를 관심목록에서 삭제한다.
Update 			: 2022.05.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
	CALL sp_req_current_time(@REG_DT);
    
    SELECT AFFILIATED_SITE INTO @USER_SITE_ID
    FROM USERS
    WHERE ID = IN_USER_ID;
    
    SET @IS_SITE_REGISTERED = FALSE;
    SET @REGISTERED_SITE_COUNT = 0;
    IF @USER_SITE_ID = 0 THEN
    /*배출자가 개인인 경우*/
		SELECT COUNT(ID) INTO @IS_SITE_DELETED
		FROM REGISTERED_SITE
		WHERE 
			USER_ID = IN_USER_ID AND
            TARGET_ID = IN_TARGET_ID AND
            REGISTER_TYPE = 2;
    ELSE
    /*배출자가 사업자인 경우*/
		SELECT COUNT(ID) INTO @IS_SITE_DELETED
		FROM REGISTERED_SITE
		WHERE 
			SITE_ID = @USER_SITE_ID AND
            TARGET_ID = IN_TARGET_ID AND
            REGISTER_TYPE = 2;
    END IF;
    
	IF @IS_SITE_DELETED = 0 THEN
	/*삭제 등록이 가능한 경우 정상처리한다.*/
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
			IN_USER_ID,
			@USER_SITE_ID,
			IN_TARGET_ID,
			@REG_DT,
			@REG_DT,
			@REG_DT,
			TRUE,
			2
		);
		IF ROW_COUNT() = 1 THEN
			SET rtn_val 		= 0;
			SET msg_txt 		= concat('success987', '/', IN_USER_ID, '/', IN_USER_TYPE, '/', IN_TARGET_ID);
		ELSE
			SET rtn_val 		= 39702;
			SET msg_txt 		= 'failed to register site information';
		END IF;
	ELSE
	/*삭제 등록이 불가능한 경우 예외처리한다.*/
		SET rtn_val 		= 39701;
		SET msg_txt 		= 'site is already deleted';
	END IF;
END