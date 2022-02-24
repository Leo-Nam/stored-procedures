CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_bidding_schedule_close_early`(
	IN IN_DISPOSER_ORDER_ID					BIGINT,
    OUT rtn_val 							INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 							VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_is_bidding_schedule_close_early
Input param 	: 1개
Output param 	: 2개
Job 			: 배출자의 일정 중에 입찰마감일정이 조기마감되 않은 경우 0, 그렇지 않으면 예외처리코드를 반환한다.
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.2)
*/

	SELECT BIDDING_EARLY_CLOSING 
    INTO @BIDDING_EARLY_CLOSING 
    FROM SITE_WSTE_DISPOSAL_ORDER 
    WHERE ID = IN_DISPOSER_ORDER_ID;
    
    IF @BIDDING_EARLY_CLOSING IS NULL THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		IF @BIDDING_EARLY_CLOSING = FALSE THEN
		/*입찰마감일정이 조기마감되지 않은 경우*/
			SET rtn_val = 0;
			SET msg_txt = 'Success';
		ELSE
		/*입찰마감일정이 조기마감된 경우*/
			SET rtn_val = 26801;
			SET msg_txt = 'The bidding schedule has ended early';
		END IF;
    END IF;
END