CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_disposer_site_id_of_collector_bidding_id`(
	IN IN_COLLECTOR_BIDDING_ID		BIGINT,
    OUT OUT_SITE_ID					BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_disposer_site_id_of_collector_bidding_id
Input param 	: 1개
Output param 	: 1개
Job 			: COLLECTOR_BIDDING.ID로 해당 폐기물 처리 신청을 한 배출자 사이트의 고유등록번호를 반환한다.
Update 			: 2022.01.20
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT DISPOSER_SITE_ID INTO OUT_SITE_ID FROM V_COLLECTOR_BIDDING WHERE COLLECTOR_BIDDING_ID = IN_COLLECTOR_BIDDING_ID;
END