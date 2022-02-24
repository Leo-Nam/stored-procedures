CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_site_final_bidder`(
	IN IN_SITE_ID					BIGINT,				/*입력값 : 입찰 고유등록번호(COMP_SITE.ID)*/
    OUT OUT_IS_SITE_FINAL_BIDDER	TINYINT				/*출력값 : 처리결과 반환값*/   
)
BEGIN

/*
Procedure Name 	: sp_req_is_site_final_bidder
Input param 	: 1개
Output param 	: 1개
Job 			: 사이트가 최종 낙찰자로 배출자로부터 선택을 받았는지 여부 반환
Update 			: 2022.01.23
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(COLLECTOR_BIDDING_ID) INTO @CHK_COUNT FROM V_COLLECTOR_BIDDING WHERE COLLECTOR_SITE_ID = IN_SITE_ID AND COLLECTOR_SELECTED = TRUE;
    IF @CHK_COUNT = 0 THEN
		SET OUT_IS_SITE_FINAL_BIDDER = FALSE;
    ELSE
		SET OUT_IS_SITE_FINAL_BIDDER = TRUE;
    END IF;
END