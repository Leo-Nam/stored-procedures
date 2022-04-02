CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_site_detail`(
	IN IN_USER_ID				BIGINT,				/*입력값 : USERS.ID*/
	IN IN_SITE_ID				BIGINT				/*입력값 : COMP_SITE.ID*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_detail
Input param 	: 1개
Job 			: 사이트에 대한 정보를 반환한다
Update 			: 2022.03.12
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
		CALL sp_req_user_exists_by_id(
			IN_USER_ID,
			TRUE,
			@rtn_val,
			@msg_txt
		);
		
		IF @rtn_val = 0 THEN
			CALL sp_req_site_id_of_user_reg_id(
				IN_USER_ID,
				@USER_SITE_ID,
				@rtn_val,
				@msg_txt
			);
			IF @rtn_val = 0 THEN
				SELECT CLASS INTO @USER_CLASS FROM USERS WHERE ID = IN_USER_ID;
				IF @USER_CLASS = 101 OR @USER_CLASS = 102 OR @USER_CLASS = 201 THEN
					IF @USER_SITE_ID = IN_SITE_ID THEN
						IF @USER_CLASS = 201 THEN
							CREATE TEMPORARY TABLE IF NOT EXISTS SITE_TEMP (
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
								MANAGER_DETAILS					JSON,
								COMPANY_DETAILS					JSON
							);   
								
							INSERT INTO 
							SITE_TEMP(
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
									'USER_ID', 						USER_ID, 
									'USER_NAME', 					USER_NAME, 
									'PHONE', 						PHONE, 
									'CLASS', 						CLASS, 
									'AVATAR_PATH', 					AVATAR_PATH
								) 
							)
							INTO @manager_details 
							FROM USERS 
							WHERE ID IN (SELECT ID FROM USERS WHERE AFFILIATED_SITE = IN_SITE_ID AND CLASS = 201);	
							UPDATE SITE_TEMP SET MANAGER_DETAILS = @manager_details WHERE ID = IN_SITE_ID;						
							
							SELECT JSON_ARRAYAGG(
								JSON_OBJECT(
									'ID', 							ID, 
									'COMP_NAME', 					COMP_NAME, 
									'REP_NAME', 					REP_NAME, 
									'KIKCD_B_CODE', 				KIKCD_B_CODE, 
									'ADDR', 						ADDR, 
									'CONTACT', 						CONTACT, 
									'TRMT_BIZ_CODE', 				TRMT_BIZ_CODE, 
									'LAT', 							LAT, 
									'LNG', 							LNG,
									'BIZ_REG_CODE', 				BIZ_REG_CODE,
									'PERMIT_REG_CODE', 				PERMIT_REG_CODE,
									'P_COMP_ID', 					P_COMP_ID,
									'BIZ_REG_IMG_PATH', 			BIZ_REG_IMG_PATH,
									'PERMIT_REG_IMG_PATH', 			PERMIT_REG_IMG_PATH,
									'CS_MANAGER_ID', 				CS_MANAGER_ID,
									'CONFIRMED', 					CONFIRMED,
									'CONFIRMED_AT', 				CONFIRMED_AT,
									'CREATED_AT', 					CREATED_AT,
									'UPDATED_AT', 					UPDATED_AT
								) 
							)
							INTO @company_details 
							FROM COMPANY 
							WHERE ID > 0 AND ID IN (SELECT COMP_ID FROM COMP_SITE WHERE ID = IN_SITE_ID);	
							UPDATE SITE_TEMP SET COMPANY_DETAILS = @company_details WHERE ID = IN_SITE_ID;
								
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
									'MANAGER_DETAILS', 			MANAGER_DETAILS,
									'COMPANY_DETAILS', 			COMPANY_DETAILS
								) 
							)
							INTO @json_data 
							FROM SITE_TEMP 
							WHERE ID = IN_SITE_ID;
							
							DROP TABLE IF EXISTS SITE_TEMP;
                        ELSE
							SET @rtn_val = 32604;
							SET @msg_txt = 'User is not affiliated with the site';
							SIGNAL SQLSTATE '23000';
                        END IF;
                    ELSE
						IF @USER_CLASS = 201 THEN
							CREATE TEMPORARY TABLE IF NOT EXISTS SITE_TEMP (
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
								MANAGER_DETAILS					JSON,
								COMPANY_DETAILS					JSON
							);   
								
							INSERT INTO 
							SITE_TEMP(
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
									'USER_ID', 						USER_ID, 
									'USER_NAME', 					USER_NAME, 
									'PHONE', 						PHONE, 
									'CLASS', 						CLASS, 
									'AVATAR_PATH', 					AVATAR_PATH
								) 
							)
							INTO @manager_details 
							FROM USERS 
							WHERE ID IN (SELECT ID FROM USERS WHERE AFFILIATED_SITE = IN_SITE_ID AND CLASS = 201);	
							UPDATE SITE_TEMP SET MANAGER_DETAILS = @manager_details WHERE ID = IN_SITE_ID;						
							
							SELECT JSON_ARRAYAGG(
								JSON_OBJECT(
									'ID', 							ID, 
									'COMP_NAME', 					COMP_NAME, 
									'REP_NAME', 					REP_NAME, 
									'KIKCD_B_CODE', 				KIKCD_B_CODE, 
									'ADDR', 						ADDR, 
									'CONTACT', 						CONTACT, 
									'TRMT_BIZ_CODE', 				TRMT_BIZ_CODE, 
									'LAT', 							LAT, 
									'LNG', 							LNG,
									'BIZ_REG_CODE', 				BIZ_REG_CODE,
									'PERMIT_REG_CODE', 				PERMIT_REG_CODE,
									'P_COMP_ID', 					P_COMP_ID,
									'BIZ_REG_IMG_PATH', 			BIZ_REG_IMG_PATH,
									'PERMIT_REG_IMG_PATH', 			PERMIT_REG_IMG_PATH,
									'CS_MANAGER_ID', 				CS_MANAGER_ID,
									'CONFIRMED', 					CONFIRMED,
									'CONFIRMED_AT', 				CONFIRMED_AT,
									'CREATED_AT', 					CREATED_AT,
									'UPDATED_AT', 					UPDATED_AT
								) 
							)
							INTO @company_details 
							FROM COMPANY 
							WHERE ID > 0 AND ID IN (SELECT COMP_ID FROM COMP_SITE WHERE ID = IN_SITE_ID);	
							UPDATE SITE_TEMP SET COMPANY_DETAILS = @company_details WHERE ID = IN_SITE_ID;
								
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
									'MANAGER_DETAILS', 			MANAGER_DETAILS,
									'COMPANY_DETAILS', 			COMPANY_DETAILS
								) 
							)
							INTO @json_data 
							FROM SITE_TEMP 
							WHERE ID = IN_SITE_ID;
							
							DROP TABLE IF EXISTS SITE_TEMP;
                        ELSE
							SET @rtn_val = 32603;
							SET @msg_txt = 'User is not affiliated with the site';
							SIGNAL SQLSTATE '23000';
                        END IF;
                    END IF;
				ELSE
					SET @rtn_val = 32602;
					SET @msg_txt = 'User not authorized';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
				SET @json_data 		= NULL;
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
			SET @json_data 		= NULL;
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
		SET @rtn_val = 32601;
		SET @msg_txt = 'site does not exist';
		SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
    
END