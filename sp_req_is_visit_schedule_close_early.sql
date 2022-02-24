CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_visit_schedule_close_early`(
	IN IN_DISPOSER_ORDER_ID			BIGINT,
    OUT rtn_val 					INT,						/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_is_visit_schedule_close_early
Input param 	: 1개
Output param 	: 1개
Job 			: 배출자의 일정 중에 방문일정이 조기마감되었는지 여부를 반환한다.
Update 			: 2022.01.24
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT VISIT_EARLY_CLOSING 
    INTO @VISIT_EARLY_CLOSING 
    FROM SITE_WSTE_DISPOSAL_ORDER 
    WHERE ID = IN_DISPOSER_ORDER_ID;
    
    IF @VISIT_EARLY_CLOSING IS NULL THEN
    /*조기마감되지 않은 상태*/
		SET rtn_val 		= 0;
		SET msg_txt 		= 'Success123';
    ELSE
    /*@VISIT_EARLY_CLOSING이 NULL값이 아니라면*/
		IF @VISIT_EARLY_CLOSING = FALSE THEN
		/*방문이 조기마감이 되지 않은 경우*/
			SET rtn_val 		= 0;
			SET msg_txt 		= 'Success234';
		ELSE
		/*방문이 조기마감된 경우*/
			SET rtn_val 		= 29501;
			SET msg_txt 		= 'Visit schedule has ended early';
		END IF;
    END IF;
END