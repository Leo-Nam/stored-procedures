CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_detail`(
	IN IN_USER_ID				BIGINT				/*입력값 : USERS.ID*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_detail
Input param 	: 1개
Job 			: 사용자에 대한 정보를 반환한다
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
    
    CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
        @rtn_val,
        @msg_txt
    );
    
    IF @rtn_val = 0 THEN
		CREATE TEMPORARY TABLE IF NOT EXISTS USER_TEMP (
			ID								BIGINT,
			USER_ID							VARCHAR(50),
			USER_NAME						VARCHAR(20),
			PHONE							VARCHAR(20),
			AVATAR_PATH						VARCHAR(255),
			PUSH_ENABLED					TINYINT,
			NOTICE_ENABLED					TINYINT,
			COMPANY_ID						BIGINT,
			COMPANY_DETAIL					JSON,
			SITE_ID							BIGINT,
			SITE_DETAIL						JSON,
			CLASS 							INT,
			DEPARTMENT 						VARCHAR(20),
			CS_MANAGER_ID					BIGINT,
			CONFIRMED						TINYINT,
			AGREEMENT_TERMS					TINYINT,
			CONFIRMED_AT					DATETIME,
			CREATED_AT						DATETIME,
			UPDATED_AT						DATETIME
		);   
			
		INSERT INTO 
		USER_TEMP(
			ID, 
			USER_ID, 
			USER_NAME, 
			PHONE, 
            AVATAR_PATH,
            PUSH_ENABLED,
            NOTICE_ENABLED,
			COMPANY_ID, 
			SITE_ID, 
			CLASS,
			DEPARTMENT,
			CS_MANAGER_ID,
			CONFIRMED,
			AGREEMENT_TERMS,
			CONFIRMED_AT,
			CREATED_AT, 
			UPDATED_AT
		)	
		SELECT 
			ID,
			USER_ID, 
			USER_NAME, 
			PHONE, 
            AVATAR_PATH,
            PUSH_ENABLED,
            NOTICE_ENABLED,
			BELONG_TO, 
			AFFILIATED_SITE, 
			CLASS, 
			DEPARTMENT, 
			CS_MANAGER_ID, 
			CONFIRMED, 
			AGREEMENT_TERMS, 
			CONFIRMED_AT,
			CREATED_AT,
			UPDATED_AT
		FROM USERS
		WHERE ID = IN_USER_ID;
		
        SELECT BELONG_TO, AFFILIATED_SITE INTO @USER_COMP_ID, @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
        IF @USER_COMP_ID > 0 THEN
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
			INTO @company_detail 
			FROM COMPANY 
			WHERE ID = @USER_COMP_ID;	
        ELSE
			SET @company_detail = NULL;
        END IF;
		UPDATE USER_TEMP SET COMPANY_DETAIL = @company_detail WHERE ID = IN_USER_ID;
		
        IF @USER_COMP_ID > 0 THEN
			SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'ID', 							ID, 
					'COMP_ID', 						COMP_ID, 
					'KIKCD_B_CODE', 				KIKCD_B_CODE, 
					'ADDR', 						ADDR, 
					'CONTACT', 						CONTACT, 
					'LAT', 							LAT, 
					'LNG', 							LNG, 
					'SITE_NAME', 					SITE_NAME, 
					'TRMT_BIZ_CODE', 				TRMT_BIZ_CODE,
					'CREATOR_ID', 					CREATOR_ID,
					'HEAD_OFFICE', 					HEAD_OFFICE,
					'PERMIT_REG_CODE', 				PERMIT_REG_CODE,
					'PERMIT_REG_IMG_PATH', 			PERMIT_REG_IMG_PATH,
					'CS_MANAGER_ID', 				CS_MANAGER_ID,
					'CONFIRMED', 					CONFIRMED,
					'CONFIRMED_AT', 				CONFIRMED_AT,
					'CREATED_AT', 					CREATED_AT,
					'UPDATED_AT', 					UPDATED_AT,
					'PUSH_ENABLED', 				PUSH_ENABLED,
					'NOTICE_ENABLED', 				NOTICE_ENABLED
				) 
			)
			INTO @site_detail 
			FROM COMP_SITE 
			WHERE ID = @USER_SITE_ID;
        ELSE
			SET @site_detail = NULL;
        END IF;
		UPDATE USER_TEMP SET SITE_DETAIL = @site_detail WHERE ID = IN_USER_ID;
			
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'ID', 							ID, 
				'USER_REG_ID', 					USER_ID, 
				'USER_NAME', 					USER_NAME, 
				'PHONE', 						PHONE, 
				'AVATAR_PATH',					AVATAR_PATH,
				'PUSH_ENABLED',					PUSH_ENABLED,
				'NOTICE_ENABLED',				NOTICE_ENABLED,
				'COMPANY_ID', 					COMPANY_ID, 
				'COMPANY_DETAIL', 				COMPANY_DETAIL, 
				'SITE_ID', 						SITE_ID, 
				'SITE_DETAIL', 					SITE_DETAIL, 
				'CLASS', 						CLASS, 
				'DEPARTMENT', 					DEPARTMENT,
				'CS_MANAGER_ID', 				CS_MANAGER_ID,
				'CONFIRMED', 					CONFIRMED,
				'AGREEMENT_TERMS', 				AGREEMENT_TERMS,
				'CONFIRMED_AT', 				CONFIRMED_AT,
				'CREATED_AT', 					CREATED_AT,
				'UPDATED_AT', 					UPDATED_AT
			) 
		)
		INTO @json_data 
		FROM USER_TEMP 
		WHERE ID = IN_USER_ID;
		
		DROP TABLE IF EXISTS USER_TEMP;
    ELSE
		SET @rtn_val = 32601;
		SET @msg_txt = 'User does not exists';
    END IF;
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
    
END