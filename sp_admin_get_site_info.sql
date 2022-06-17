CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_get_site_info`(
	IN IN_SITE_ID						BIGINT,
    OUT OUT_SITE_INFO					JSON
)
BEGIN

/*
Procedure Name 	: sp_admin_get_site_info
Input param 	: 4개
Job 			: 사이트의 리스트를 반환한다.
Update 			: 2022.04.28
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_SITE_ID							BIGINT;   
    DECLARE CUR_COMP_ID							BIGINT;   
    DECLARE CUR_CREATED_AT						DATETIME;  
    DECLARE CUR_UPDATED_AT						DATETIME;  
    DECLARE CUR_SITE_NAME						VARCHAR(255);   
    DECLARE CUR_PERMIT_REG_CODE					VARCHAR(12);  
    DECLARE CUR_B_CODE							VARCHAR(10); 
    DECLARE CUR_ADDR							VARCHAR(255);
    DECLARE CUR_PERMIT_REG_IMG_PATH				VARCHAR(255);
    DECLARE CUR_LAT								DECIMAL(12,9);
    DECLARE CUR_LNG								DECIMAL(12,9);
    DECLARE CUR_USER_TYPE						INT;
    DECLARE TEMP_CURSOR		 					CURSOR FOR 
	SELECT 
		A.ID, 
		A.COMP_ID, 
        A.CREATED_AT,
        A.UPDATED_AT,
        A.SITE_NAME,
        A.PERMIT_REG_CODE,
        A.KIKCD_B_CODE,
        A.ADDR,
        A.PERMIT_REG_IMG_PATH,
        A.LAT,
        A.LNG,
        B.USER_TYPE
    FROM COMP_SITE A
    LEFT JOIN WSTE_TRMT_BIZ B ON A.TRMT_BIZ_CODE = B.CODE
    WHERE A.ID = IN_SITE_ID;   
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
    SET OUT_SITE_INFO = NULL;
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_GET_SITE_INFO (
		SITE_ID							BIGINT,
		COMP_ID							BIGINT,
		CREATED_AT						DATETIME,
		UPDATED_AT						DATETIME,
		SITE_NAME						VARCHAR(255),
		PERMIT_REG_CODE					VARCHAR(12),
		B_CODE							VARCHAR(10),
		ADDR							VARCHAR(255),
		PERMIT_REG_IMG_PATH				VARCHAR(255),
        ADDRESS_INFO					JSON,
        COMPANY_INFO					JSON,
        WSTE_INFO						JSON,
        SITE_INFO						JSON,
        SITE_LIST						JSON
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		
		FETCH TEMP_CURSOR 
		INTO  
			CUR_SITE_ID,
			CUR_COMP_ID,
			CUR_CREATED_AT,
			CUR_UPDATED_AT,
			CUR_SITE_NAME,
			CUR_PERMIT_REG_CODE,
			CUR_B_CODE,
			CUR_ADDR,
			CUR_PERMIT_REG_IMG_PATH,
			CUR_LAT,
			CUR_LNG,
			CUR_USER_TYPE;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		ADMIN_GET_SITE_INFO(
			SITE_ID,
			COMP_ID,
			CREATED_AT,
			UPDATED_AT,
			SITE_NAME,
			PERMIT_REG_CODE,
			B_CODE,
			ADDR,
			PERMIT_REG_IMG_PATH
		)
		VALUES(
			CUR_SITE_ID,
			CUR_COMP_ID,
			CUR_CREATED_AT,
			CUR_UPDATED_AT,
			CUR_SITE_NAME,
			CUR_PERMIT_REG_CODE,
			CUR_B_CODE,
			CUR_ADDR,
			CUR_PERMIT_REG_IMG_PATH
		);
        
        CALL sp_get_address_with_bcode(
			CUR_B_CODE,
            @ADDRESS_INFO
        );
        
        CALL sp_get_company_info(
			CUR_COMP_ID,
            @COMPANY_INFO
        );
        
        CALL sp_get_site_wste_info(
			CUR_SITE_ID,
            @WSTE_INFO
        );
        
        CALL sp_get_site_info_simple(
			CUR_SITE_ID,
            @SITE_INFO
        );
        
		CALL sp_req_policy_direction(
			'circle_range',
			@circle_range
		);
        
        CALL sp_get_site_list_inside_range_without_handler(
			CUR_USER_TYPE,
            @circle_range,
            CUR_LAT,
            CUR_LNG,
            @rtn_val,
            @msg_txt,
            @SITE_LIST
        );
        
        UPDATE ADMIN_GET_SITE_INFO
        SET 
			ADDRESS_INFO = @ADDRESS_INFO,
			COMPANY_INFO = @COMPANY_INFO,
			WSTE_INFO = @WSTE_INFO,
			SITE_INFO = @SITE_INFO,
			SITE_LIST = @SITE_LIST
        WHERE SITE_ID = CUR_SITE_ID;
        
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'SITE_ID'					, SITE_ID, 
        'CREATED_AT'				, CREATED_AT, 
        'UPDATED_AT'				, UPDATED_AT, 
        'SITE_NAME'					, SITE_NAME, 
        'PERMIT_REG_CODE'			, PERMIT_REG_CODE, 
        'B_CODE'					, B_CODE, 
        'ADDR'						, ADDR, 
        'PERMIT_REG_IMG_PATH'		, PERMIT_REG_IMG_PATH, 
        'ADDRESS_INFO'				, ADDRESS_INFO, 
        'COMPANY_INFO'				, COMPANY_INFO, 
        'WSTE_INFO'					, WSTE_INFO, 
        'SITE_INFO'					, SITE_INFO, 
        'SITE_LIST'					, SITE_LIST
	)) 
    INTO OUT_SITE_INFO FROM ADMIN_GET_SITE_INFO;
    
	DROP TABLE IF EXISTS ADMIN_GET_SITE_INFO;
END