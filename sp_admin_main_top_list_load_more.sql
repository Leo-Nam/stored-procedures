CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_main_top_list_load_more`(
    IN IN_PARAM							JSON
)
BEGIN
    
	SELECT USER_ID , MENU_ID, OFFSET_SIZE, PAGE_SIZE
    INTO @USER_ID, @MENU_ID, @OFFSET_SIZE, @PAGE_SIZE
    FROM JSON_TABLE(IN_PARAM, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID",
		MENU_ID 				INT 				PATH "$.MENU_ID",
		OFFSET_SIZE 			INT 				PATH "$.OFFSET_SIZE",
		PAGE_SIZE 				INT 				PATH "$.PAGE_SIZE"
	)) AS PARAMS;

	CALL sp_req_policy_direction(
	/*입찰마감일로부터 배출종료일까지의 최소 소요기간(단위: day)을 반환받는다. 입찰종료일일은 방문종료일 + duration_bidding_end_date_after_the_visit_closing으로 한다.*/
		'admin_main_duration',
		@admin_main_duration
	);
    
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_MAIN_TOP_LIST_LOAD_MORE_TEMP (
        USER_ID					BIGINT,
        MENU_ID					INT,
        OFFSET_SIZE				INT,
        PAGE_SIZE				INT,
        PUSH_HISTORY			JSON
	);  
    
    IF @MENU_ID >= 0 AND @MENU_ID < 3 THEN
		CALL sp_admin_main_top_lists(
			@MENU_ID,
			@admin_main_duration,
			@OFFSET_SIZE,
			@PAGE_SIZE,
			@PUSH_HISTORY
		);
	ELSE
		COMMIT;
    END IF;
    
	INSERT INTO 
	ADMIN_MAIN_TOP_LIST_LOAD_MORE_TEMP(
		USER_ID,
		MENU_ID,
		OFFSET_SIZE,
		PAGE_SIZE,
		PUSH_HISTORY
	)
	VALUES(
		@USER_ID,
		@MENU_ID,
		@OFFSET_SIZE,
		@PAGE_SIZE,
		NULL
	);
	UPDATE ADMIN_MAIN_TOP_LIST_LOAD_MORE_TEMP
    SET 
        PUSH_HISTORY 			= @PUSH_HISTORY
	WHERE USER_ID 				= @USER_ID;
    
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'PUSH_HISTORY'				, PUSH_HISTORY
	)) 
    INTO @json_data FROM ADMIN_MAIN_TOP_LIST_LOAD_MORE_TEMP;
    
	DROP TABLE IF EXISTS ADMIN_MAIN_TOP_LIST_LOAD_MORE_TEMP;
    SET @rtn_val = 0;
    SET @msg_txt = 'success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END