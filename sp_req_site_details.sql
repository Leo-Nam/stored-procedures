CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_site_details`(
	IN IN_SITE_ID				BIGINT
)
BEGIN   

/*
Procedure Name 	: sp_req_site_details
Input param 	: 1개
Job 			: 사업자 사이트의 상세정보를 반환한다.
Update 			: 2022.02.23
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/
    
    DECLARE vRowCount 						INT DEFAULT 0;
    DECLARE endOfRow 						TINYINT DEFAULT FALSE;  
    
    DECLARE CUR_SITE_ID			 			BIGINT;
    DECLARE CUR_SITE_NAME		 			VARCHAR(255);
    DECLARE CUR_SITE_SI_DO			 		VARCHAR(20);
    DECLARE CUR_SITE_SI_GUN_GU		 		VARCHAR(20);
    DECLARE CUR_SITE_EUP_MYEON_DONG			VARCHAR(20);
    DECLARE CUR_SITE_DONG_RI		 		VARCHAR(20);
    DECLARE CUR_SITE_ADDR			 		VARCHAR(255);
    DECLARE CUR_SITE_CONTACT			 	VARCHAR(255);
    DECLARE CUR_SITE_TRMT_BIZ_NM			VARCHAR(50);
    
    DECLARE TEMP_CURSOR 					CURSOR FOR 
    SELECT 
		COMP_SITE_ID, 
		COMP_SITE_NAME, 
        COMP_SITE_SI_DO, 
        COMP_SITE_SI_GUN_GU, 
        COMP_SITE_EUP_MYEON_DONG, 
        COMP_SITE_DONG_RI, 
        COMP_SITE_ADDR, 
        COMP_SITE_CONTACT, 
        COMP_SITE_TRMT_BIZ_NM
	FROM V_COMP_SITE 
    WHERE COMP_SITE_ID = IN_SITE_ID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;       
    
	CREATE TEMPORARY TABLE IF NOT EXISTS TEMP_SITE_DETAILS (
		ID 						BIGINT, 
		NAME 					VARCHAR(255), 
		SI_DO 					VARCHAR(20), 
		SI_GUN_GU 				VARCHAR(20), 
		EUP_MYEON_DONG 			VARCHAR(20), 
		DONG_RI 				VARCHAR(20), 
		ADDR 					VARCHAR(255), 
		CONTACT 				VARCHAR(255), 
		TRMT_BIZ_NM 			VARCHAR(50), 
		GRADE					FLOAT, 
		REVIEW_LIST 			JSON
	);	
    
    SELECT COUNT(COMP_SITE_ID) INTO @SITE_COUNT FROM V_COMP_SITE WHERE COMP_SITE_ID = IN_SITE_ID;
    
    IF @SITE_COUNT > 0 THEN
		OPEN TEMP_CURSOR;	
		cloop: LOOP
			FETCH TEMP_CURSOR 
			INTO 
				CUR_SITE_ID,
				CUR_SITE_NAME,
				CUR_SITE_SI_DO,
				CUR_SITE_SI_GUN_GU,
				CUR_SITE_EUP_MYEON_DONG,
				CUR_SITE_DONG_RI,
				CUR_SITE_ADDR,
				CUR_SITE_CONTACT,
				CUR_SITE_TRMT_BIZ_NM;
				
			SET vRowCount = vRowCount + 1;
			IF endOfRow THEN
				LEAVE cloop;
			END IF;
					
			INSERT INTO 
			TEMP_SITE_DETAILS(
				ID, 
				NAME, 
				SI_DO, 
				SI_GUN_GU, 
				EUP_MYEON_DONG, 
				DONG_RI, 
				ADDR, 
				CONTACT, 
				TRMT_BIZ_NM
			) 
			VALUES(
				CUR_SITE_ID, 
				CUR_SITE_NAME, 
				CUR_SITE_SI_DO, 
				CUR_SITE_SI_GUN_GU, 
				CUR_SITE_EUP_MYEON_DONG, 
				CUR_SITE_DONG_RI, 
				CUR_SITE_ADDR, 
				CUR_SITE_CONTACT, 
				CUR_SITE_TRMT_BIZ_NM
			);    
			
			SELECT AVG(SCORE) INTO @GRADE FROM SITE_EVALUATION WHERE SITE_ID = IN_SITE_ID;

			CALL sp_req_get_posts_without_handler(
				IN_SITE_ID,
				4,
				1,
				0,
				10,
				@rtn_val,
				@msg_txt,
				@review_list
			);
		
			UPDATE TEMP_SITE_DETAILS SET REVIEW_LIST = @review_list, GRADE = @GRADE WHERE ID = IN_SITE_ID;
			
		END LOOP;   
		CLOSE TEMP_CURSOR;
    
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'ID'					, ID,
				'NAME'					, NAME,
				'SI_DO'					, SI_DO, 
				'SI_GUN_GU'				, SI_GUN_GU, 
				'EUP_MYEON_DONG'		, EUP_MYEON_DONG, 
				'DONG_RI'				, DONG_RI, 
				'ADDR'					, ADDR, 
				'CONTACT'				, CONTACT, 
				'TRMT_BIZ_NM'			, TRMT_BIZ_NM, 
				'GRADE'					, GRADE, 
				'REVIEW_LIST'			, REVIEW_LIST
			)
		) 
		INTO @json_data 
		FROM TEMP_SITE_DETAILS
		WHERE ID = IN_SITE_ID;
        
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';
	ELSE
		SET @rtn_val = 24201;
		SET @msg_txt = 'Data not found';
		SET @json_data = NULL;
    END IF;
    
    DROP TABLE IF EXISTS TEMP_SITE_DETAILS;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END