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
    
    IF IN_SITE_ID > 0 THEN
		CREATE TEMPORARY TABLE IF NOT EXISTS BUSINESS_AREA_TEMP (
			SITE_ID							BIGINT,
			BUSINESS_AREA					JSON
		);   
        
		INSERT BUSINESS_AREA_TEMP(SITE_ID, BUSINESS_AREA) VALUES(IN_SITE_ID, NULL);	
			
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
        
		UPDATE BUSINESS_AREA_TEMP SET BUSINESS_AREA = @business_area WHERE SITE_ID = IN_SITE_ID;	
			
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'SITE_ID', 					IN_SITE_ID, 
				'BUSINESS_AREA', 			BUSINESS_AREA
			) 
		)
		INTO @json_data 
		FROM BUSINESS_AREA_TEMP;
		SET @rtn_val = 0;
		SET @msg_txt = 'success';
		
		DROP TABLE IF EXISTS BUSINESS_AREA_TEMP;
    ELSE
		SET @rtn_val = 32901;
		SET @msg_txt = 'site does not exist';
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
    
END