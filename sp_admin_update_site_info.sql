CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_update_site_info`(
    IN IN_PARAMS					JSON
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;  
	START TRANSACTION;	
  
	SELECT 
		USER_ID, 
        SITE_ID, 
        SITE_NAME, 
        BIZ_REG_CODE, 
        BIZ_REG_IMG_PATH, 
        PERMIT_REG_CODE, 
        PERMIT_REG_IMG_PATH, 
        REP_NAME, 
        B_CODE, 
        ADDR, 
        WSTE_LIST, 
        LAT, 
        LNG, 
        COMP_NAME, 
        CONFIRMED, 
        MANAGER_ID
    INTO 
		@USER_ID, 
        @SITE_ID, 
        @SITE_NAME, 
        @BIZ_REG_CODE, 
        @BIZ_REG_IMG_PATH, 
        @PERMIT_REG_CODE, 
        @PERMIT_REG_IMG_PATH, 
        @REP_NAME, 
        @B_CODE, 
        @ADDR, 
        @WSTE_LIST, 
        @LAT, 
        @LNG, 
        @COMP_NAME, 
        @CONFIRMED, 
        @MANAGER_ID
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID",
		SITE_ID	 				BIGINT				PATH "$.SITE_ID",
		SITE_NAME	 			VARCHAR(255)		PATH "$.SITE_NAME",
		BIZ_REG_CODE 			VARCHAR(12)			PATH "$.BIZ_REG_CODE",
		BIZ_REG_IMG_PATH		VARCHAR(200)		PATH "$.BIZ_REG_IMG_PATH",
		PERMIT_REG_CODE 		VARCHAR(100)		PATH "$.PERMIT_REG_CODE",
		PERMIT_REG_IMG_PATH		VARCHAR(200)		PATH "$.PERMIT_REG_IMG_PATH",
		REP_NAME 				VARCHAR(50)			PATH "$.REP_NAME",
		B_CODE	 				VARCHAR(10)			PATH "$.B_CODE",
		ADDR	 				VARCHAR(255)		PATH "$.ADDR",
		WSTE_LIST 				JSON				PATH "$.WSTE_LIST",
		LAT 					DECIMAL(12,9)		PATH "$.LAT",
		LNG 					DECIMAL(12,9)		PATH "$.LNG",        
		COMP_NAME 				VARCHAR(100)		PATH "$.COMP_NAME",
		CONFIRMED  				TINYINT				PATH "$.CONFIRMED",
		MANAGER_ID 				BIGINT				PATH "$.MANAGER_ID"
	)) AS PARAMS;
    
	CALL sp_req_current_time(@REG_DT);
    UPDATE COMP_SITE
    SET 
		SITE_NAME		 	= @SITE_NAME,
		PERMIT_REG_CODE 	= @PERMIT_REG_CODE,
        PERMIT_REG_IMG_PATH = @PERMIT_REG_IMG_PATH,
        KIKCD_B_CODE 		= @B_CODE,
        ADDR 				= @ADDR,
        LAT 				= @LAT,
        LNG 				= @LNG,
        CONFIRMED 			= @CONFIRMED,
        CS_MANAGER_ID 		= @MANAGER_ID,
        UPDATED_AT 			= @REG_DT
	WHERE 
        ID 					= @SITE_ID;
	
	SELECT COMP_ID INTO @COMP_ID
	FROM COMP_SITE
	WHERE ID = @SITE_ID;
	
	UPDATE COMPANY
	SET 
		BIZ_REG_CODE 		= @BIZ_REG_CODE,
		BIZ_REG_IMG_PATH 	= @BIZ_REG_IMG_PATH,
		COMP_NAME 			= @COMP_NAME,
		REP_NAME 			= @REP_NAME,
		UPDATED_AT 			= @REG_DT
	WHERE 
		ID 					= @COMP_ID;
		
	IF @WSTE_LIST IS NOT NULL THEN
		CALL sp_admin_update_site_wste_info(
			@SITE_ID,
			@WSTE_LIST,
			@rtn_val,
			@msg_txt
		);
		IF @rtn_val = 0 THEN
			CALL sp_admin_get_site_info(
				@SITE_ID,
				@json_data
			);
		ELSE
			SIGNAL SQLSTATE '23000';
		END IF;
	ELSE
		SET @rtn_val = 0;
		SET @msg_txt = 'success';
	END IF;
   
    COMMIT;
    CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END