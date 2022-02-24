CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_apply_for_visit`(
	IN IN_SITE_ID							BIGINT,
    IN IN_DISPOSER_ORDER_ID					BIGINT,
    OUT OUT_COLLECTOR_BIDDING_ID			BIGINT,				/*출력값 : 처리결과 반환값*/
    OUT rtn_val 							INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 							VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_apply_for_visit
Input param 	: 2개
Output param 	: 2개
Job 			: 수거자등의 사업자가 방문신청을 했는지 여부 확인
Update 			: 2022.01.29
Version			: 0.0.3
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.3)
*/

	SELECT COUNT(ID) 
    INTO @APPLY_FOR_VISIT 
    FROM COLLECTOR_BIDDING 
    WHERE 
		COLLECTOR_ID = IN_SITE_ID AND 
        DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND
        DATE_OF_VISIT IS NOT NULL AND
        ACTIVE = TRUE;
	
    IF @APPLY_FOR_VISIT = 1 THEN
		SELECT ID 
        INTO OUT_COLLECTOR_BIDDING_ID 
        FROM COLLECTOR_BIDDING 
        WHERE 
			COLLECTOR_ID = IN_SITE_ID AND 
			DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND
			DATE_OF_VISIT IS NOT NULL AND
			ACTIVE = TRUE;
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 26701;
		SET msg_txt = 'The collector does not apply for a visit';
    END IF;
END