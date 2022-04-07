CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_site_id_of_collector_bidding`(
	IN IN_COLLECTOR_BIDDING_ID		BIGINT,
    OUT OUT_DISPOER_SITE_ID			BIGINT,
    OUT OUT_COLLECTOR_SITE_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_site_id_of_collector_bidding_id
Input param 	: 1개
Output param 	: 1개
Job 			: IN_COLLECTOR_BIDDING_ID로 해당 폐기물 처리 작업중인 사이트의 고유등록번호를 반환한다.
Update 			: 2022.01.25
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT B.SITE_ID, A.COLLECTOR_ID 
    INTO OUT_DISPOER_SITE_ID, OUT_COLLECTOR_SITE_ID
    FROM COLLECTOR_BIDDING A
    LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID
    WHERE A.ID = IN_COLLECTOR_BIDDING_ID;
END