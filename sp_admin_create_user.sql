CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_create_user`(
	IN IN_PARAMS				JSON
)
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_CREATE_USER_TEMP (
		ID								VARCHAR(255),
		NAME							VARCHAR(255)
	);        
    
    INSERT INTO ADMIN_CREATE_USER_TEMP(
		ID,
        NAME
    )
	SELECT 
		ID COLLATE utf8mb4_unicode_ci,
		NAME COLLATE utf8mb4_unicode_ci
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		ID		 				VARCHAR(255)		PATH "$.ID",
		NAME	 				VARCHAR(255)		PATH "$.NAME"
	)) AS PARAMS;
    
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'ID'				, ID,
        'NAME'				, NAME
	)) 
    INTO @SAVED_DATA FROM ADMIN_CREATE_USER_TEMP;      
    
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_CREATE_USER_TEMP_2 (
		INPUT_PARAMS					JSON,
		SAVED_DATA						JSON
	);   
    
    INSERT INTO ADMIN_CREATE_USER_TEMP_2(
		INPUT_PARAMS,
        SAVED_DATA
    ) VALUES(
		IN_PARAMS,
        @SAVED_DATA
    );
    
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'INPUT_PARAMS'				, INPUT_PARAMS,
        'SAVED_DATA'				, SAVED_DATA
	)) 
    INTO @json_data FROM ADMIN_CREATE_USER_TEMP_2;  
	DROP TABLE IF EXISTS ADMIN_CREATE_USER_TEMP_2;  
	DROP TABLE IF EXISTS ADMIN_CREATE_USER_TEMP;
    
    SET @rtn_val = 0;
    SET @msg_txt = 'success999';
	CALL sp_return_results(@json_data, @msg_txt, @json_data);
END