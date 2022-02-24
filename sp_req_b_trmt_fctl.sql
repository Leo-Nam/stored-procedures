CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_b_trmt_fctl`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'CODE'			, CODE, 
			'CODE_1'		, CODE_1, 
			'CODE_2'		, CODE_2, 
			'CODE_3'		, CODE_3, 
			'CODE_4'		, CODE_4, 
			'NAME'			, NAME, 
			'NOTE'			, NOTE
		)
	) 
	INTO @json_data 
	FROM WSTE_TRMT_FCTL
	ORDER BY CODE;
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END