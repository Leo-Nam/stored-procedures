CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_parent_company_info`(
	IN IN_COMP_ID			BIGINT,
    OUT OUT_COMP_INFO		JSON
)
BEGIN
	
	CREATE TEMPORARY TABLE IF NOT EXISTS PARENT_COMP_INFO_TEMP (
		ID						BIGINT,
		COMP_NAME				VARCHAR(100),
		REP_NAME				VARCHAR(50),
        KIKCD_B_CODE			VARCHAR(10),
        ADDR					VARCHAR(255),
        CONTACT					VARCHAR(100),
        TRMT_BIZ_CODE			VARCHAR(4),
		LAT						DECIMAL(12,9),
        LNG						DECIMAL(12,9),
        BIZ_REG_CODE			VARCHAR(12),
        PERMIT_REG_CODE			VARCHAR(100),
        P_COMP_ID				BIGINT,
        BIZ_REG_IMG_PATH		VARCHAR(255),
        PERMIT_REG_IMG_PATH		VARCHAR(255),
        CS_MANAGER_ID			BIGINT,
        CONFIRMED				TINYINT,
        CONFIRMED_AT			DATETIME,
        CREATED_AT				DATETIME,
        UPDATED_AT				DATETIME,
        ACTIVE					TINYINT,
        ADDRESS_INFO			JSON
	);     
    
    INSERT INTO PARENT_COMP_INFO_TEMP (
		ID,
		COMP_NAME,
		REP_NAME,
        KIKCD_B_CODE,
        ADDR,
        CONTACT,
        TRMT_BIZ_CODE,
		LAT,
        LNG,
        BIZ_REG_CODE,
        PERMIT_REG_CODE,
        P_COMP_ID,
        BIZ_REG_IMG_PATH,
        PERMIT_REG_IMG_PATH,
        CS_MANAGER_ID,
        CONFIRMED,
        CONFIRMED_AT,
        CREATED_AT,
        UPDATED_AT,
        ACTIVE
	)
	SELECT 
		ID,
		COMP_NAME,
		REP_NAME,
        KIKCD_B_CODE,
        ADDR,
        CONTACT,
        TRMT_BIZ_CODE,
		LAT,
        LNG,
        BIZ_REG_CODE,
        PERMIT_REG_CODE,
        P_COMP_ID,
        BIZ_REG_IMG_PATH,
        PERMIT_REG_IMG_PATH,
        CS_MANAGER_ID,
        CONFIRMED,
        CONFIRMED_AT,
        CREATED_AT,
        UPDATED_AT,
        ACTIVE
	FROM COMPANY 
	WHERE ID = IN_COMP_ID;	
    
    SELECT KIKCD_B_CODE INTO @KIKCD_B_CODE
    FROM COMPANY 
	WHERE ID = IN_COMP_ID;	
    
    CALL sp_get_address_with_bcode(
		@KIKCD_B_CODE,
        @ADDRESS_INFO
    );
    
    UPDATE PARENT_COMP_INFO_TEMP
    SET 
		ADDRESS_INFO 		= @ADDRESS_INFO
    WHERE ID = IN_COMP_ID;	
    
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'						, ID, 
			'COMP_NAME'					, COMP_NAME, 
			'REP_NAME'					, REP_NAME, 
			'KIKCD_B_CODE'				, KIKCD_B_CODE,
			'ADDR'						, ADDR,
			'CONTACT'					, CONTACT,
            'TRMT_BIZ_CODE'				, TRMT_BIZ_CODE,
            'LAT'						, LAT,
			'LNG'						, LNG, 
            'BIZ_REG_CODE'				, BIZ_REG_CODE,
            'PERMIT_REG_CODE'			, PERMIT_REG_CODE,
            'P_COMP_ID'					, P_COMP_ID,
            'BIZ_REG_IMG_PATH'			, BIZ_REG_IMG_PATH,
            'PERMIT_REG_IMG_PATH'		, PERMIT_REG_IMG_PATH,
            'CS_MANAGER_ID'				, CS_MANAGER_ID,
            'CONFIRMED'					, CONFIRMED,
            'CONFIRMED_AT'				, CONFIRMED_AT,
            'CREATED_AT'				, CREATED_AT,
            'UPDATED_AT'				, UPDATED_AT,
            'ACTIVE'					, ACTIVE,
            'ADDRESS_INFO'				, ADDRESS_INFO
		)
	) 
	INTO OUT_COMP_INFO 
	FROM PARENT_COMP_INFO_TEMP;	
	DROP TABLE IF EXISTS PARENT_COMP_INFO_TEMP;
END