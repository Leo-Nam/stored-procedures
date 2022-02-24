CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_site_id_of_collector_bidding_id`(
	IN IN_COLLECTOR_BIDDING_ID		BIGINT,
    OUT OUT_SITE_ID					BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_site_id_of_collector_bidding_id
Input param 	: 1개
Output param 	: 1개
Job 			: COLLECTOR_BIDDING.ID로 해당 폐기물 처리 신청을 한 사이트의 아이디를 반환한다.
Update 			: 2022.01.20
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COLLECTOR_ID INTO OUT_SITE_ID FROM COLLECTOR_BIDDING WHERE ID = IN_COLLECTOR_BIDDING_ID;
END