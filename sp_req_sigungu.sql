CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_sigungu`(
	IN IN_SIDO_CODE				VARCHAR(10)
)
BEGIN
	IF IN_SIDO_CODE = '3600000000' THEN
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'B_CODE'		, B_CODE, 
				'SI_DO'			, SI_DO, 
				'SI_GUN_GU'		, SI_GUN_GU
			)
		) 
		INTO @json_data 
		FROM KIKCD_B 
		WHERE 
			LEFT(B_CODE, 2) 	= LEFT(IN_SIDO_CODE, 2) AND 
            RIGHT(B_CODE, 8) 	= '00000000' AND 
            CANCELED_DATE 		IS NULL 
		ORDER BY B_CODE;
		IF ROW_COUNT() > 0 THEN
			SET @rtn_val = 0;
			SET @msg_txt = 'Success';
		ELSE
			SET @rtn_val = 23901;
			SET @msg_txt = 'Data not found';
			SET @json_data = NULL;
		END IF;
    ELSE
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'B_CODE'		, B_CODE, 
				'SI_DO'			, SI_DO, 
				'SI_GUN_GU'		, SI_GUN_GU
			)
		) 
		INTO @json_data 
		FROM KIKCD_B 
		WHERE 
			LEFT(B_CODE, 2) 	= LEFT(IN_SIDO_CODE, 2) AND 
            RIGHT(B_CODE, 5) 	= '00000' AND 
            JACHIGU 			IS NULL AND 
            B_CODE 				<> IN_SIDO_CODE AND 
            SI_GUN_GU 			IS NOT NULL AND 
            CANCELED_DATE 		IS NULL 
		ORDER BY B_CODE;
		IF ROW_COUNT() > 0 THEN
			SET @rtn_val = 0;
			SET @msg_txt = 'Success';
		ELSE
			SET @rtn_val = 23902;
			SET @msg_txt = 'Data not found';
			SET @json_data = NULL;
		END IF;
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END