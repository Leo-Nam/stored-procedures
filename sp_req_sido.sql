CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_sido`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'B_CODE'		, B_CODE, 
			'SI_DO'			, SI_DO
		)
	) 
	INTO @json_data 
	FROM KIKCD_B 
	WHERE 
		RIGHT(B_CODE, 8) = '00000000' AND 
		CANCELED_DATE IS NULL 
	ORDER BY B_CODE;
    IF ROW_COUNT() > 0 THEN
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';
    ELSE
		SET @rtn_val = 21701;
		SET @msg_txt = 'Data not found';
		SET @json_data = NULL;
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END