CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_get_chat_rooms`(
    IN IN_PARAMS					JSON
)
BEGIN
	DECLARE rtn_val					INT				DEFAULT 0;
    DECLARE msg_txt					VARCHAR(200)	DEFAULT NULL;
    DECLARE json_data				JSON			DEFAULT NULL;
    
	SELECT USER_ID
    INTO @USER_ID
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID"
	)) AS PARAMS;   
    
    SELECT USER_CURRENT_TYPE INTO @USER_TYPE
    FROM USERS
    WHERE ID = @USER_ID;
    
	CALL sp_admin_get_chat_rooms_without_handler(
		@USER_ID,
		@USER_TYPE,
		json_data
	);
    SET rtn_val = 0;
    SET msg_txt = 'success1234';
	CALL sp_return_results(rtn_val, msg_txt, json_data);
	
END