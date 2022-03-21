CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_business_area`(
	IN IN_SITE_ID				BIGINT					/*사이트의 고유등록번호(COMP_SITE.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_req_site_sigungu_code_by_site_id
Input param 	: 1개
Job 			: 사이트의 관심지역을 반환한다
Update 			: 2022.03.13
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;
	START TRANSACTION;
    /*트랜잭션 시작*/
    
    IF IN_SITE_ID > 0 THEN
		CREATE TEMPORARY TABLE IF NOT EXISTS BUSINESS_AREA_TEMP (
			ID								BIGINT,
			COMP_ID							BIGINT,
			KIKCD_B_CODE					VARCHAR(10),
			ADDR							VARCHAR(255),
			CONTACT							VARCHAR(100),
			LAT								DECIMAL(12,9),
			LNG								DECIMAL(12,9),
			SITE_NAME						VARCHAR(255),
			TRMT_BIZ_CODE					VARCHAR(4),
			CREATOR_ID						BIGINT,
			HEAD_OFFICE 					TINYINT,
			PERMIT_REG_CODE 				VARCHAR(100),
			PERMIT_REG_IMG_PATH				VARCHAR(200),
			CS_MANAGER_ID					BIGINT,
			CONFIRMED						TINYINT,
			CONFIRMED_AT					DATETIME,
			CREATED_AT						DATETIME,
			UPDATED_AT						DATETIME,
			BUSINESS_AREA					JSON
		);   
			
		INSERT INTO 
		BUSINESS_AREA_TEMP(
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
			UPDATED_AT
		)	
		SELECT 
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
			UPDATED_AT
		FROM COMP_SITE
		WHERE ID = IN_SITE_ID;	
			
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'ID', 							ID, 
				'SITE_ID', 						SITE_ID, 
				'KIKCD_B_CODE', 				KIKCD_B_CODE, 
				'IS_DEFAULT', 					IS_DEFAULT, 
				'CREATED_AT', 					CREATED_AT, 
				'SI_DO', 						SI_DO, 
				'SI_GUN_GU', 					SI_GUN_GU
			) 
		)
		INTO @business_area 
		FROM V_BUSINESS_AREA 
		WHERE SITE_ID = IN_SITE_ID;	
		UPDATE BUSINESS_AREA_TEMP SET BUSINESS_AREA = @business_area WHERE ID = IN_SITE_ID;	
			
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'ID', 						ID, 
				'COMP_ID', 					COMP_ID, 
				'KIKCD_B_CODE', 			KIKCD_B_CODE, 
				'ADDR', 					ADDR, 
				'CONTACT',					CONTACT,
				'LAT',						LAT,
				'LNG', 						LNG, 
				'SITE_NAME', 				SITE_NAME, 
				'TRMT_BIZ_CODE', 			TRMT_BIZ_CODE, 
				'CREATOR_ID', 				CREATOR_ID, 
				'HEAD_OFFICE', 				HEAD_OFFICE, 
				'PERMIT_REG_CODE', 			PERMIT_REG_CODE,
				'PERMIT_REG_IMG_PATH', 		PERMIT_REG_IMG_PATH,
				'CS_MANAGER_ID', 			CS_MANAGER_ID,
				'CONFIRMED', 				CONFIRMED,
				'CONFIRMED_AT', 			CONFIRMED_AT,
				'CREATED_AT', 				CREATED_AT,
				'UPDATED_AT', 				UPDATED_AT,
				'BUSINESS_AREA', 			BUSINESS_AREA
			) 
		)
		INTO @json_data 
		FROM BUSINESS_AREA_TEMP 
		WHERE ID = IN_SITE_ID;
		
		DROP TABLE IF EXISTS BUSINESS_AREA_TEMP;
    ELSE
		SET @rtn_val = 32901;
		SET @msg_txt = 'site does not exist';
		SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
    
END