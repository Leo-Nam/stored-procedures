CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_get_question_category`()
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID', 							ID, 
			'QUEST_CLASS', 					CLASS_NM
		) 
	)
	INTO @json_data 
	FROM QUEST_CLASS; 
    SET @rtn_val = 0;
    SET @msg_txt = 'success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END