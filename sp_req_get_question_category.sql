CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_get_question_category`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID', 							ID, 
			'QUEST_CATEGORY', 				CATEGORY_NAME
		) 
	)
	INTO @json_data 
	FROM POST_SUB_CATEGORY
    WHERE PID = 3; 
    SET @rtn_val = 0;
    SET @msg_txt = 'success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END