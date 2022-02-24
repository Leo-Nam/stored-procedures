CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_b_trmt_method`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'CODE'						, CODE, 
			'WSTE_TRMT_CLS_1'			, WSTE_TRMT_CLS_1, 
			'WSTE_TRMT_CLS_2'			, WSTE_TRMT_CLS_2, 
			'NAME'						, NAME, 
			'WSTE_TRMT_CLS_NM_1'		, WSTE_TRMT_CLS_NM_1, 
			'WSTE_TRMT_CLS_NM_2'		, WSTE_TRMT_CLS_NM_2
		)
	) 
	INTO @json_data 
	FROM V_WSTE_TRMT_METHOD
	ORDER BY CODE;
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END