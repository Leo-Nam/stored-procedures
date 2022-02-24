CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_b_wste_appearance`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'				, ID, 
			'KOREAN'			, KOREAN, 
			'ENGLISH'			, ENGLISH, 
			'ACTIVE'			, ACTIVE
		)
	) 
	INTO @json_data 
	FROM WSTE_APPEARANCE
	ORDER BY ID;
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END