CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_company_exists`(
	IN IN_COMP_ID			BIGINT,
    IN IN_ACTIVE			TINYINT,
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_company_exists
Input param 	: 2개
Output param 	: 2개
Job 			: 입력 param의 IN_COMP_ID를 사업자 고유번호로 사용하는 사업자가 존재하는지 여부 반환
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	IF IN_ACTIVE IS NULL THEN
		SELECT COUNT(ID) INTO @CHK_COUNT FROM COMPANY WHERE ID = IN_COMP_ID;
    ELSE
		SELECT COUNT(ID) INTO @CHK_COUNT FROM COMPANY WHERE ID = IN_COMP_ID AND ACTIVE = IN_ACTIVE;
    END IF;
    
    IF @CHK_COUNT = 1 THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 28401;
		SET msg_txt = 'company does not exist';
    END IF;
END