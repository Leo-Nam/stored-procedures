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
     
    
	CALL sp_req_policy_direction(
	/*입찰마감일로부터 배출종료일까지의 최소 소요기간(단위: day)을 반환받는다. 입찰종료일일은 방문종료일 + duration_bidding_end_date_after_the_visit_closing으로 한다.*/
		'admin_main_duration',
		@admin_main_duration
	);
    
    CALL sp_admin_main_top(
		IN_USER_ID,
		@admin_main_duration,
		@TOP
    );
	SET @BODY = NULL;
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_GET_1_01_TEMP (
		ADMIN_ID						BIGINT,
		TOP								JSON,
		BODY							JSON
	);     
	INSERT ADMIN_GET_1_01_TEMP(
		ADMIN_ID, 
        TOP, 
        BODY
	) VALUES(
        IN_USER_ID, 
        @TOP, 
        @BODY
	);
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'ADMIN_ID'					, ADMIN_ID,
		'TOP'						, TOP,
		'BODY'						, BODY
	)) 
	INTO @json_data
	FROM ADMIN_GET_1_01_TEMP;  
    
	SET @rtn_val = 0;
	SET @msg_txt = 'Success';
	DROP TABLE IF EXISTS ADMIN_GET_1_01_TEMP;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END