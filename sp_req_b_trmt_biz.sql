CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_b_trmt_biz`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'CODE'					, CODE, 
			'NAME'					, NAME, 
			'NOTE'					, NOTE, 
			'USER_TYPE'				, USER_TYPE, 
			'USER_TYPE_EN_NM'		, USER_TYPE_EN_NM, 
			'USER_TYPE_KO_NM'		, USER_TYPE_KO_NM
		)
	) 
	INTO @json_data 
	FROM V_WSTE_TRMT_BIZ
	ORDER BY CODE;
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END