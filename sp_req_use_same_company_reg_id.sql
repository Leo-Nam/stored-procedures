CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_use_same_company_reg_id`(
	IN IN_BIZ_REG_CODE		VARCHAR(12),		/*입력값: 체크할 사업자 등록번호*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_use_same_company_reg_id
Input param 	: 1개
Output param 	: 2개
Job 			: 체크할 사업자등록번호로 등록된 사업자가 존재하는지 체크한 후 존재하지 않는다면 0, 그렇지 않으면 예외처리코드를 반환하게 됨
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) 
    INTO @CHK_COUNT 
    FROM COMPANY 
    WHERE BIZ_REG_CODE = IN_BIZ_REG_CODE;
    
    IF @CHK_COUNT = 0 THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 27501;
		SET msg_txt = 'The same business registration number already exists';
    END IF;
END