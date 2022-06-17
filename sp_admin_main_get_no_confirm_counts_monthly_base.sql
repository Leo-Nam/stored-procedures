CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_main_get_no_confirm_counts_monthly_base`(
    IN IN_PARAM							JSON
)
BEGIN

/*
Procedure Name 	: sp_admin_main_get_no_confirm_counts_monthly_base
Input param 	: 1개
Job 			: 현재가 속하고 있는 연월에서 일별로 사업자등록증 허가증 등 cs로부터 미처리된 리스트를 반환한다.
Update 			: 2022.04.28
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
	SELECT 
		USER_ID, 
        MENU_ID, 
        TARGET_DATE
    INTO 
		@USER_ID, 
        @MENU_ID, 
        @TARGET_DATE
    FROM JSON_TABLE(IN_PARAM, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID",
		MENU_ID 				INT 				PATH "$.MENU_ID",
		TARGET_DATE				DATE 				PATH "$.TARGET_DATE"
	)) AS PARAMS;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS MAIN_GET_NO_CONFIRM_COUNTS_TEMP (
		USER_ID									BIGINT,
		MENU_ID									INT,
        LISTS									JSON        
	);        
	
    INSERT INTO MAIN_GET_NO_CONFIRM_COUNTS_TEMP(
		USER_ID,
        MENU_ID,
        LISTS
	) VALUES (
		@USER_ID,
        @MENU_ID,
        @LISTS
	);
	
	CALL sp_get_no_confirm_license_counts_monthly(
		@TARGET_DATE,
		@MENU_ID,
		@LISTS
	);
    
    UPDATE MAIN_GET_NO_CONFIRM_COUNTS_TEMP
    SET LISTS = @LISTS
    WHERE USER_ID = @USER_ID;
    
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'USER_ID'			, USER_ID, 
        'MENU_ID'			, MENU_ID, 
        'LISTS'				, LISTS
	)) 
    INTO @json_data FROM MAIN_GET_NO_CONFIRM_COUNTS_TEMP;
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	DROP TABLE IF EXISTS MAIN_GET_NO_CONFIRM_COUNTS_TEMP;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END