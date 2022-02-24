CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_site_collector`(
	IN IN_SITE_ID					BIGINT,				/*사이트의 고유등록번호(COMP_SITE.ID)*/
    OUT rtn_val 					INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_is_site_collector
Input param 	: 1개
Output param 	: 1개
Job 			: 사이트가 수집운반업자 등인 경우에는 TRUE를 반환하고 그렇지 않은 경우에는 FALSE를 반환한다.
Update 			: 2022.01.24
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/

	SELECT PERMIT_REG_CODE INTO @PERMIT_REG_CODE FROM COMP_SITE WHERE ID = IN_SITE_ID;
    IF @PERMIT_REG_CODE IS NOT NULL THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 29701;
		SET msg_txt = 'The site is not a collector';
    END IF;
END