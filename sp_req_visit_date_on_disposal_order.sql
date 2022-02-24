CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_visit_date_on_disposal_order`(
	IN IN_DISPOSER_ORDER_ID					BIGINT,
	OUT OUT_VISIT_START_AT					DATETIME,
	OUT OUT_VISIT_END_AT					DATETIME
)
BEGIN

/*
Procedure Name 	: sp_req_visit_date_on_disposal_order
Input param 	: 1개
Output param 	: 4개
Job 			: 배출자가 지정한 방문일정을 반환한다.
Update 			: 2022.02.22
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
	SELECT VISIT_START_AT, VISIT_END_AT
    INTO OUT_VISIT_START_AT, OUT_VISIT_END_AT
    FROM SITE_WSTE_DISPOSAL_ORDER 
    WHERE 
		ID = IN_DISPOSER_ORDER_ID AND 
        ACTIVE = TRUE;
END