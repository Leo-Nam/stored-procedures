CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_visit_date_expired`(
	IN IN_DISPOSER_ORDER_ID					BIGINT,
    OUT rtn_val 							INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 							VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_visit_date_expired
Input param 	: 1개
Output param 	: 2개
Job 			: 폐기물배출신청건에 대한 방문예정마감일이 종료되었으며 0, 그렇지 않으면 예외처리코드를 반환함
Update 			: 2022.01.29
Version			: 0.0.3
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.3)
*/

    CALL sp_req_current_time(@CURRENT_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
	SELECT VISIT_END_AT
    INTO @VISIT_DATE
    FROM SITE_WSTE_DISPOSAL_ORDER 
    WHERE 
		ID = IN_DISPOSER_ORDER_ID AND 
        ACTIVE = TRUE;
        
	IF @VISIT_DATE IS NOT NULL THEN
		IF @CURRENT_DT >= @VISIT_DATE THEN
			SET rtn_val = 0;
			SET msg_txt = 'Success1';
		ELSE
			SET rtn_val = 26601;
			SET msg_txt = 'The expected date of visit has not yet come';
		END IF;
    ELSE
		SET rtn_val = 26602;
		SET msg_txt = 'No scheduled visit date';
    END IF;
END