CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_b_wste_code`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'CODE'					, CODE, 
			'CODE_1'				, CODE_1, 
			'CODE_2'				, CODE_2, 
			'CODE_3'				, CODE_3, 
			'CODE_4'				, CODE_4, 
			'NAME'					, NAME, 
			'LAW_REV'				, LAW_REV, 
			'WSTE_REPT_CLS_CODE'	, WSTE_REPT_CLS_CODE, 
			'WSTE_REPT_CLS_NM'		, WSTE_REPT_CLS_NM, 
			'CLASS_ID'				, CLASS_ID, 
			'CLASS_NAME'			, CLASS_NAME
		)
	) 
	INTO @json_data 
	FROM V_WSTE_CODE
    WHERE DISPLAY = 1
	ORDER BY CODE_4;
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END