CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_duty_to_apply_for_visit`(
	IN IN_DISPOSER_ORDER_ID					BIGINT,
    OUT rtn_val 							INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 							VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_get_duty_to_apply_for_visit
Input param 	: 1개
Output param 	: 2개
Job 			: 폐기물배출신청건에 대한 방문의무가 있는지 검사하여 방문의무가 있으면 0, 그렇지 않으면 예외처리코드를 반환함
Update 			: 2022.01.29
Version			: 0.0.3
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.3)
*/

	SELECT VISIT_END_AT
    INTO @OUT_DUTY_TO_APPLY_FOR_VISIT
    FROM SITE_WSTE_DISPOSAL_ORDER 
    WHERE 
		ID = IN_DISPOSER_ORDER_ID AND 
        ACTIVE = TRUE;
        
	IF @OUT_DUTY_TO_APPLY_FOR_VISIT IS NOT NULL THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
	ELSE
		SET rtn_val = 26501;
		SET msg_txt = 'Dischargers who do not have an obligation to visit';
	END IF;
END