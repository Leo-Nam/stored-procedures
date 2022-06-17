CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_b_department`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'NAME'					, NAME, 
			'BELONG_TO'				, BELONG_TO
		)
	) 
	INTO @json_data 
	FROM DEPARTMENT
	ORDER BY CODE;
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END