CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_all_class`()
BEGIN
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	SELECT JSON_ARRAYAGG(JSON_OBJECT('ID', ID, 'CLASS_NM', CLASS_NM)) INTO @json_data FROM USERS_CLASS;
    CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END