CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_company`(
	IN IN_COMP_ID				BIGINT
)
BEGIN

/*
Procedure Name 	: sp_get_company
Input param 	: 1개
Job 			: 사업자 정보를 반환한다.
Update 			: 2022.01.10
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		/*ROLLBACK;*/
        COMMIT;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
	SELECT COUNT(ID) INTO @COMPANY_COUNT
    FROM COMPANY
    WHERE ID = IN_COMP_ID;
    
    IF @COMPANY_COUNT > 0 THEN
    
		CREATE TEMPORARY TABLE IF NOT EXISTS COMPANY_INFO_TEMP (
			ID								BIGINT,
			COMP_NAME						VARCHAR(100),
			REP_NAME						VARCHAR(50),
			KIKCD_B_CODE					VARCHAR(10),
			ADDR							VARCHAR(255),
			CONTACT							VARCHAR(100),
			TRMT_BIZ_CODE					VARCHAR(4),
			BIZ_REG_CODE					VARCHAR(12),
			PERMIT_REG_CODE					VARCHAR(100),
			BIZ_REG_IMG_PATH				VARCHAR(200),
			PERMIT_REG_IMG_PATH				VARCHAR(200),
			ACTIVE							TINYINT,
            PARENT_COMPANY_INFO				JSON,
            CHILD_COMPANY_INFO				JSON,
            SITE_INFO						JSON
		); 		
    
		INSERT INTO COMPANY_INFO_TEMP (
			ID,
			COMP_NAME,
			REP_NAME,
			KIKCD_B_CODE,
			ADDR,
			CONTACT,
			TRMT_BIZ_CODE,
			BIZ_REG_CODE,
			PERMIT_REG_CODE,
			BIZ_REG_IMG_PATH,
			PERMIT_REG_IMG_PATH,
			ACTIVE,
            PARENT_COMPANY_ID
        ) SELECT 
			ID,
			COMP_NAME,
			REP_NAME,
			KIKCD_B_CODE,
			ADDR,
			CONTACT,
			TRMT_BIZ_CODE,
			BIZ_REG_CODE,
			PERMIT_REG_CODE,
			BIZ_REG_IMG_PATH,
			PERMIT_REG_IMG_PATH,
			ACTIVE,
            P_COMP_ID
		FROM COMPANY 
        WHERE ID = IN_COMP_ID;  
        
        SELECT COUNT(ID) INTO @CHILD_COMPANY_COUNT
        FROM COMPANY
        WHERE P_COMP_ID = IN_COMP_ID;
        IF @CHILD_COMPANY_COUNT > 0 THEN
			SELECT JSON_ARRAYAGG(JSON_OBJECT(
				'ID'						, ID, 
				'COMP_NAME'					, COMP_NAME, 
				'REP_NAME'					, REP_NAME, 
				'KIKCD_B_CODE'				, KIKCD_B_CODE, 
				'ADDR'						, ADDR, 
				'CONTACT'					, CONTACT, 
				'TRMT_BIZ_CODE'				, TRMT_BIZ_CODE, 
				'BIZ_REG_CODE'				, BIZ_REG_CODE, 
				'PERMIT_REG_CODE'			, PERMIT_REG_CODE, 
				'BIZ_REG_IMG_PATH'			, BIZ_REG_IMG_PATH, 
				'PERMIT_REG_IMG_PATH'		, PERMIT_REG_IMG_PATH, 
				'ACTIVE'					, ACTIVE, 
				'PARENT_COMPANY_ID'			, P_COMP_ID
			)) 
			INTO @CHILD_COMPANY_INFO 
			FROM COMPANY
			WHERE P_COMP_ID = IN_COMP_ID;
        ELSE
			SET @CHILD_COMPANY_INFO = NULL;
        END IF;
    
		SELECT COUNT(ID) INTO @SITE_COUNT
        FROM COMP_SITE
        WHERE COMP_ID = IN_COMP_ID;
        
        IF @SITE_COUNT > 0 THEN
			SELECT JSON_ARRAYAGG(JSON_OBJECT(
				'ID'						, ID, 
				'COMP_ID'					, COMP_ID, 
				'KIKCD_B_CODE'				, KIKCD_B_CODE, 
				'ADDR'						, ADDR, 
				'CONTACT'					, CONTACT, 
				'LAT'						, LAT, 
				'LNG'						, LNG, 
				'SITE_NAME'					, SITE_NAME, 
				'ACTIVE'					, ACTIVE, 
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
				'RECOVERY_TAG'				, RECOVERY_TAG, 
				'NOTICE_ENABLED'			, NOTICE_ENABLED, 
				'LICENSE_CONFIRMED'			, LICENSE_CONFIRMED, 
				'LICENSE_CONFIRMED_AT'		, LICENSE_CONFIRMED_AT
			)) 
			INTO @SITE_INFO 
			FROM COMP_SITE 
			WHERE COMP_ID = IN_COMP_ID; 
        ELSE
			SET @SITE_INFO = NULL;
        END IF;
        
        UPDATE COMPANY_INFO_TEMP
        SET 
            PARENT_COMPANY_INFO 		= @PARENT_COMPANY_INFO,
            CHILD_COMPANY_INFO 			= @CHILD_COMPANY_INFO,
            SITE_INFO 					= @SITE_INFO
		WHERE ID = IN_COMP_ID;
        
        IF ROW_COUNT() = 1 THEN
			SELECT JSON_ARRAYAGG(JSON_OBJECT(
				'ID'						, ID, 
				'COMP_NAME'					, COMP_NAME, 
				'REP_NAME'					, REP_NAME, 
				'KIKCD_B_CODE'				, KIKCD_B_CODE, 
				'ADDR'						, ADDR, 
				'CONTACT'					, CONTACT, 
				'TRMT_BIZ_CODE'				, TRMT_BIZ_CODE, 
				'BIZ_REG_CODE'				, BIZ_REG_CODE, 
				'PERMIT_REG_CODE'			, PERMIT_REG_CODE, 
				'BIZ_REG_IMG_PATH'			, BIZ_REG_IMG_PATH, 
				'PERMIT_REG_IMG_PATH'		, PERMIT_REG_IMG_PATH, 
				'ACTIVE'					, ACTIVE, 
				'PARENT_COMPANY_ID'			, PARENT_COMPANY_ID,
				'CHILD_COMPANY_INFO'		, CHILD_COMPANY_INFO,
				'SITE_INFO'					, SITE_INFO
			)) 
			INTO @json_data 
			FROM COMPANY_INFO_TEMP; 
            
			SET @rtn_val = 0;
			SET @msg_txt = 'Success';
        ELSE
			SET @rtn_val = 35402;
			SET @msg_txt = 'company info temporary data update error';
        END IF;
        
    ELSE
		SET @rtn_val = 35401;
		SET @msg_txt = 'company does not exist';
    END IF;
	DROP TABLE IF EXISTS COMPANY_INFO_TEMP;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END