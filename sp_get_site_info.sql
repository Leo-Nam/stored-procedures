CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_site_info`(
	IN IN_SITE_ID			BIGINT,
    OUT OUT_SITE_INFO		JSON
)
BEGIN
	
	CREATE TEMPORARY TABLE IF NOT EXISTS SITE_INFO_TEMP (
		ID						BIGINT,
		COMP_ID					BIGINT,
		KIKCD_B_CODE			VARCHAR(10),
        ADDR					VARCHAR(255),
        CONTACT					VARCHAR(100),
        LAT						DECIMAL(12,9),
        LNG						DECIMAL(12,9),
		SITE_NAME				VARCHAR(255),
        TRMT_BIZ_CODE			VARCHAR(4),
        CREATOR_ID				BIGINT,
        HEAD_OFFICE				TINYINT,
        PERMIT_REG_CODE			VARCHAR(255),
        PERMIT_REG_IMG_PATH		VARCHAR(255),
        CS_MANAGER_ID			BIGINT,
        CONFIRMED				TINYINT,
        CONFIRMED_AT			DATETIME,
        CREATED_AT				DATETIME,
        UPDATED_AT				DATETIME,
        PUSH_ENABLED			TINYINT,
        NOTICE_ENABLED			TINYINT,
        TRMT_BIZ_NM				VARCHAR(50),
		SI_DO					VARCHAR(20),
		SI_GUN_GU				VARCHAR(20),
		EUP_MYEON_DONG			VARCHAR(20),
        DONG_RI					VARCHAR(20),
        AVATAR_PATH				VARCHAR(255),
        PHONE					VARCHAR(20),
        BUSINESS_TARGET			JSON,
        ADDRESS_INFO			JSON,
        COMPANY_INFO			JSON
	);     
    
    INSERT INTO SITE_INFO_TEMP (
		ID,
        COMP_ID,
		KIKCD_B_CODE,
        ADDR,
        CONTACT,
        LAT,
        LNG,
		SITE_NAME,
        TRMT_BIZ_CODE,
        CREATOR_ID,
        HEAD_OFFICE,
        PERMIT_REG_CODE,
        PERMIT_REG_IMG_PATH,
        CS_MANAGER_ID,
        CONFIRMED,
        CONFIRMED_AT,
        CREATED_AT,
        UPDATED_AT,
        PUSH_ENABLED,
        NOTICE_ENABLED,
        TRMT_BIZ_NM,
		SI_DO,
		SI_GUN_GU,
		EUP_MYEON_DONG,
        DONG_RI,
        AVATAR_PATH,
        PHONE,
        ACTIVE
	)
	SELECT 
		A.ID, 
        A.COMP_ID,
		A.KIKCD_B_CODE, 
		A.ADDR,
		A.CONTACT,
        A.LAT,
        A.LNG,
		A.SITE_NAME, 
        A.TRMT_BIZ_CODE,
        A.CREATOR_ID,
        A.HEAD_OFFICE,
        A.PERMIT_REG_CODE,
        A.PERMIT_REG_IMG_PATH,
        A.CS_MANAGER_ID,
        A.CONFIRMED,
        A.CONFIRMED_AT,
        A.CREATED_AT,
        A.UPDATED_AT,
        A.PUSH_ENABLED,
        A.NOTICE_ENABLED,
        D.NAME,
		B.SI_DO,
		B.SI_GUN_GU,
		B.EUP_MYEON_DONG,
		B.DONG_RI,
		C.AVATAR_PATH,
		C.PHONE,
		A.ACTIVE
	FROM COMP_SITE A         
    LEFT JOIN KIKCD_B B ON A.KIKCD_B_CODE = B.B_CODE
    LEFT JOIN USERS C ON A.ID = C.AFFILIATED_SITE
    LEFT JOIN WSTE_TRMT_BIZ D ON A.TRMT_BIZ_CODE = D.CODE
	WHERE 
		A.ID = IN_SITE_ID AND
        C.CLASS = 201 AND
        C.ACTIVE = TRUE;	
    
	CALL sp_get_wste_lists_registerd_by_site(
		IN_SITE_ID,
		@BUSINESS_TARGET
	);
	
    SELECT COMP_ID, KIKCD_B_CODE INTO @COMP_ID, @KIKCD_B_CODE
    FROM COMP_SITE
    WHERE ID = IN_SITE_ID;
    
	CALL sp_get_address_with_bcode(
		@KIKCD_B_CODE,
		@ADDRESS_INFO
	);
    
	CALL sp_get_company_info(
		@COMP_ID,
		@COMPANY_INFO
	);
    
	UPDATE SITE_INFO_TEMP
    SET 
		BUSINESS_TARGET	 = @BUSINESS_TARGET,
		ADDRESS_INFO	 = @ADDRESS_INFO,
		COMPANY_INFO	 = @COMPANY_INFO
    WHERE ID = IN_SITE_ID;
    
    
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'						, ID, 
			'COMP_ID'					, COMP_ID, 
			'KIKCD_B_CODE'				, KIKCD_B_CODE, 
			'ADDR'						, ADDR,
			'CONTACT'					, CONTACT,
            'LAT'						, LAT,
            'LNG'						, LNG,
			'SITE_NAME'					, SITE_NAME, 
            'TRMT_BIZ_CODE'				, TRMT_BIZ_CODE,
            'CREATOR_ID'				, CREATOR_ID,
            'HEAD_OFFICE'				, HEAD_OFFICE,
            'PERMIT_REG_CODE'			, PERMIT_REG_CODE,
            'PERMIT_REG_IMG_PATH'		, PERMIT_REG_IMG_PATH,
            'CS_MANAGER_ID'				, CS_MANAGER_ID,
            'CONFIRMED'					, CONFIRMED,
            'CONFIRMED_AT'				, CONFIRMED_AT,
            'CREATED_AT'				, CREATED_AT,
            'UPDATED_AT'				, UPDATED_AT,
            'PUSH_ENABLED'				, PUSH_ENABLED,
            'NOTICE_ENABLED'			, NOTICE_ENABLED,
            'TRMT_BIZ_NM'				, TRMT_BIZ_NM,
			'SI_DO'						, SI_DO,
			'SI_GUN_GU'					, SI_GUN_GU,
			'EUP_MYEON_DONG'			, EUP_MYEON_DONG,
			'DONG_RI'					, DONG_RI,
			'AVATAR_PATH'				, AVATAR_PATH,
			'PHONE'						, PHONE,
			'ACTIVE'					, ACTIVE,
            'BUSINESS_TARGET'			, BUSINESS_TARGET,
            'ADDRESS_INFO'				, ADDRESS_INFO,
            'COMPANY_INFO'				, COMPANY_INFO
		)
	) 
	INTO OUT_SITE_INFO 
	FROM SITE_INFO_TEMP;	
	DROP TABLE IF EXISTS SITE_INFO_TEMP;
END