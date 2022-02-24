CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_use_same_company_permit_code`(
	IN IN_PERMIT_REG_CODE	VARCHAR(100),		/*입력값: 체크할 수거자 업체등의 허가 또는 신고번호*/
    OUT OUT_PARAM			TINYINT				/*출력값: 동일한 등록번호가 존재한다면 1, 그렇지 않으면 0을 반환함*/
)
BEGIN

/*
Procedure Name 	: sp_req_use_same_company_permit_code
Input param 	: 1개
Output param 	: 1개
Job 			: 체크할 허가 또는 신고번호로 등록된 사업자가 존재하는지 체크한 후 존재한다면 1, 그렇지 않으면 0을 반환하게 됨
Update 			: 2022.01.10
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) INTO OUT_PARAM FROM COMPANY WHERE PERMIT_REG_CODE = IN_PERMIT_REG_CODE;
END