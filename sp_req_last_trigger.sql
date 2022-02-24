CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_last_trigger`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'				, ID, 
			'TABLE_NM'			, TABLE_NM, 
			'EVENT'				, EVENT, 
			'CREATED_AT'		, CREATED_AT
		)
	) 
	INTO @json_data 
	FROM TRIGGER_TABLE 
	WHERE 
		ID IN (SELECT MAX(ID) FROM TRIGGER_TABLE);
        
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END