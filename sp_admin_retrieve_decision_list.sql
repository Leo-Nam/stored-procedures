CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_retrieve_decision_list`(
    IN IN_PARAMS					JSON
)
BEGIN
    
	SELECT USER_ID
    INTO @USER_ID
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID"
	)) AS PARAMS;  
    
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_RETRIEVE_DECISION_LIST_TEMP (
        USER_ID					BIGINT,
        DECISION_LIST			JSON,
        INPUT_PARAM				JSON
	);
    
	CALL sp_admin_retrieve_decision_list_without_handler(
		@DECISION_LIST
	);
    
	INSERT INTO 
	ADMIN_RETRIEVE_DECISION_LIST_TEMP(
		USER_ID,
		DECISION_LIST,
		INPUT_PARAM
	)
	VALUES(
		@USER_ID,
		@DECISION_LIST,
		@IN_PARAMS
	);
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'USER_ID'				, @USER_ID,
        'DECISION_LIST'			, @DECISION_LIST,
        'INPUT_PARAM'			, IN_PARAMS
	)) 
    INTO @json_data FROM ADMIN_RETRIEVE_DECISION_LIST_TEMP;
    
	DROP TABLE IF EXISTS ADMIN_RETRIEVE_DECISION_LIST_TEMP;
    SET @rtn_val = 0;
    SET @msg_txt = 'success999';
	CALL sp_return_results(@json_data, @msg_txt, @json_data);
END