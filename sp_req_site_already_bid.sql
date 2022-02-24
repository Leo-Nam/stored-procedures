CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_site_already_bid`(
	IN IN_SITE_ID			BIGINT,				/*입력값 : 수거자의 고유등록번호(COMP_SITE.ID)*/
	IN IN_DISPOSER_ORDER_ID	BIGINT,				/*입력값 : 배출자의 폐기물배출 고유등록번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_site_already_bid
Input param 	: 2개
Output param 	: 2개
Job 			: 사이트가 해당 폐기물배출정보에 이미 입찰을 했는지 여부 확인. 기존 입찰사실이 없다면 0, 그렇지 않으면 예외처리코드 반환
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.2)
*/

	SELECT COUNT(ID) 
    INTO @CHK_COUNT 
    FROM COLLECTOR_BIDDING 
    WHERE 
		COLLECTOR_ID = IN_SITE_ID AND 
        DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND 
        DATE_OF_BIDDING IS NOT NULL;
        
    IF @CHK_COUNT = 0 THEN
    /*이전에 입찰한 사실이 존재하지 않는 경우*/
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
    /*이전에 입찰한 사실이 존재하는 경우*/
		SET rtn_val = 27101;
		SET msg_txt = 'This site has already bid';
    END IF;
END