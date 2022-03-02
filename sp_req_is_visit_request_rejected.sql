CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_visit_request_rejected`(
	IN IN_COLLECTOR_BIDDING_ID				BIGINT,
    IN IN_DISPOSER_ORDER_ID					BIGINT,
    OUT rtn_val 							INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 							VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_is_visit_reqeust_rejected
Input param 	: 2개
Output param 	: 2개
Job 			: 수거자가 배출자로부터 방문신청에 대한 거절이 있었다면 0, 그렇지 않으면 예외처리코드를 반환한다.
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.2)
*/

	SELECT RESPONSE_VISIT 
    INTO @RESPONSE_VISIT 
    FROM COLLECTOR_BIDDING 
    WHERE 
		ID = IN_COLLECTOR_BIDDING_ID AND 
        DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND 
        RESPONSE_VISIT_AT IS NOT NULL;
        
	IF @RESPONSE_VISIT IS NOT NULL THEN
		IF @RESPONSE_VISIT = FALSE THEN
		/*방문거절을 당한 경우*/
			SET rtn_val = 26901;
			SET msg_txt = 'No refusal to visit';
		ELSE
		/*방문거절이 아닌 경우*/
			SET rtn_val = 0;
			SET msg_txt = 'Success';
		END IF;
    ELSE
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    END IF;
END