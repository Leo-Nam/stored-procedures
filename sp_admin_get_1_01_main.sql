CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_get_1_01_main`(
	IN IN_USER_ID					BIGINT
)
BEGIN

/*
Procedure Name 	: sp_admin_get_1_01_main
Input param 	: 1개
Output param 	: 10개
Job 			: 관리자페이지(1-01-main)에 필요한 초기자료를 반환한다.
Update 			: 2022.04.20
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_1_01_MAIN_TEMP (
		ADMIN_ID						BIGINT,
		REAL_TIME_STATUS				JSON        
	);        
	
	INSERT INTO 
	ADMIN_1_01_MAIN_TEMP(
		ADMIN_ID,
		REAL_TIME_STATUS
	)
	VALUES(
		IN_USER_ID,
		@REAL_TIME_STATUS
	);
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'ADMIN_ID'				, ADMIN_ID, 
        'REAL_TIME_STATUS'		, REAL_TIME_STATUS
	)) 
    INTO @json_data FROM ADMIN_1_01_MAIN_TEMP;
    
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	DROP TABLE IF EXISTS ADMIN_1_01_MAIN_TEMP;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END