CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_status_group`(
	IN IN_USER_TYPE_CODE			INT
)
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'					, DISP_ID, 
			'USER_TYPE'				, USER_TYPE, 
			'USER_TYPE_NM_EN'		, USER_TYPE_NM_EN, 
			'USER_TYPE_NM_KO'		, USER_TYPE_NM_KO, 
			'ACTIVE'				, ACTIVE, 
			'DISP_NM_KO'			, DISP_NM_KO, 
			'DISP_NM_EN'			, DISP_NM_EN
		)
	) 
	INTO @json_data 
	FROM V_STATUS_GROUP
	WHERE 
		USER_TYPE = IN_USER_TYPE_CODE;
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END