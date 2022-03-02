CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_visit_request_already_not_canceled`(
	IN IN_COLLECTOR_SITE_ID					BIGINT,
    IN IN_DISPOSER_ORDER_ID					BIGINT,
    OUT rtn_val 							INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 							VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_is_visit_request_already_not_canceled
Input param 	: 2개
Output param 	: 2개
Job 			: 수거자가 자신이 신청한 방문신청에 대하여 취소한 사실이 있는지 검사하여 취소한 사실이 있다면 0, 그렇지 않으면 예외처리한다.
Update 			: 2022.03.02
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	SELECT CANCEL_VISIT 
    INTO @CANCEL_VISIT 
    FROM COLLECTOR_BIDDING 
    WHERE 
		COLLECTOR_ID = IN_COLLECTOR_SITE_ID AND 
        DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID;
        
	IF @RESPONSE_VISIT = FALSE THEN
	/*방문신청을 취소한 사실이 없는 경우*/
		SET rtn_val = 0;
		SET msg_txt = 'Success';
	ELSE
	/*방문신청을 취소한 사실이 있는 경우*/
		SET rtn_val = 31401;
		SET msg_txt = 'The visit request has already been canceled';
	END IF;
END