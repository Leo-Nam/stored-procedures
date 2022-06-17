CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_retrieve_site_info`(
    IN IN_PARAMS					JSON
)
BEGIN
    
	SELECT USER_ID, SITE_ID, TYPE_INDEX, CIRCLE_RANGE
    INTO @USER_ID, @SITE_ID, @TYPE_INDEX, @CIRCLE_RANGE
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID",
		SITE_ID	 				BIGINT				PATH "$.SITE_ID",
		TYPE_INDEX				INT					PATH "$.TYPE_INDEX",
        CIRCLE_RANGE			INT					PATH "$.CIRCLE_RANGE"
	)) AS PARAMS;   
    
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_RETRIEVE_SITE_INFO_TEMP_ROOT (
        USER_ID					BIGINT,
        SITE_ID					BIGINT,
        SITE_INFO				JSON,
        CIRCLE_RANGE			INT,
        INPUT_PARAM				JSON
	);
    
	CALL sp_admin_retrieve_site_info_without_handler(
		@SITE_ID,
		@TYPE_INDEX,
		@CIRCLE_RANGE,
		@SITE_INFO
	);
    
	INSERT INTO 
	ADMIN_RETRIEVE_SITE_INFO_TEMP_ROOT(
		USER_ID,
		SITE_ID,
		SITE_INFO,
        CIRCLE_RANGE
	)
	VALUES(
		@USER_ID,
		@SITE_ID,
		@SITE_INFO,
		@CIRCLE_RANGE
	);
    
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'USER_ID'				, @USER_ID,
        'SITE_ID'				, @SITE_ID,
        'SITE_INFO'				, @SITE_INFO,
        'CIRCLE_RANGE'			, @CIRCLE_RANGE,
        'INPUT_PARAM'			, IN_PARAMS
	)) 
    INTO @json_data FROM ADMIN_RETRIEVE_SITE_INFO_TEMP_ROOT;
    
	DROP TABLE IF EXISTS ADMIN_RETRIEVE_SITE_INFO_TEMP_ROOT;
    SET @rtn_val = 0;
    SET @msg_txt = 'success999';
	CALL sp_return_results(@json_data, @msg_txt, @json_data);
END