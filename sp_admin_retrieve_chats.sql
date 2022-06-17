CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_retrieve_chats`(
    IN IN_PARAMS					JSON
)
BEGIN

	SELECT USER_ID, ROOM_ID, PAGE_SIZE, OFFSET_SIZE
    INTO @USER_ID, @ROOM_ID, @PAGE_SIZE, @OFFSET_SIZE
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID",
		ROOM_ID	 				BIGINT				PATH "$.ROOM_ID",
		PAGE_SIZE	 			INT					PATH "$.PAGE_SIZE",
		OFFSET_SIZE	 			INT					PATH "$.OFFSET_SIZE"
	)) AS PARAMS;
    
    CALL sp_admin_set_is_read_true(
		@ROOM_ID,
        @USER_ID,
        @rtn_val,
        @msg_txt
    );
    
	CALL sp_admin_retrieve_chats_without_handler(
		@ROOM_ID,
		@USER_ID,
        @PAGE_SIZE,
        @OFFSET_SIZE,
        @json_data
    );
    SET @rtn_val = 0;
    SET @msg_txt = 'success1';
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END