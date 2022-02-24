CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_bidding_end_date_expired`(
	IN IN_DISPOSER_ORDER_ID						BIGINT,
    OUT rtn_val 								INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 								VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_bidding_end_date_expired
Input param 	: 1개
Output param 	: 2개
Job 			: 폐기물배출신청건에 대한 입찰마감일이 종료되지 않았으면 0, 그렇지 않으면 예외처리코드를 반환함
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.2)
*/

    CALL sp_req_current_time(@CURRENT_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
	SELECT BIDDING_END_AT
    INTO @BIDDING_END_DATE
    FROM SITE_WSTE_DISPOSAL_ORDER 
    WHERE 
		ID = IN_DISPOSER_ORDER_ID AND 
        ACTIVE = TRUE;
	
    IF @BIDDING_END_DATE IS NOT NULL THEN
		IF @CURRENT_DT >= @BIDDING_END_DATE THEN
			SET rtn_val = 27001;
			SET msg_txt = 'Bidding deadline has expired';
		ELSE
			SET rtn_val = 0;
			SET msg_txt = 'Success';
		END IF;
    ELSE
		SET rtn_val = 27002;
		SET msg_txt = 'No bid deadline set';
    END IF;
END