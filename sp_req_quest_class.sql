CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_quest_class`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'					, ID, 
			'CLASS_NM'				, CATEGORY_NAME
		)
	) 
	INTO @json_data 
	FROM POST_SUB_CATEGORY
    WHERE PID = 3
	ORDER BY ID;
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);   
END