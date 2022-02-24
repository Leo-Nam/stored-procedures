CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_comp_id_by_reg_code`(
	IN IN_COMP_BIZ_REG_CODE		VARCHAR(12),		/*입력값 : 사업자등록번호*/
    OUT OUT_COMP_ID				BIGINT				/*출력값 : 사업자 등록 고유번호*/
)
BEGIN

/*
Procedure Name 	: sp_req_comp_id_by_reg_code
Input param 	: 1개
Output param 	: 1개
Job 			: IN_COMP_REG_CODE를 사업자 등록번호로 사용하는 사업자의 고유등록번호를 OUT_COMP_ID를 통하여 반환한다.
Update 			: 2022.01.13
Version			: 0.0.1
AUTHOR 			: Leo Nam
NOTE			: 이 프로시저를 호출하는 프로시저에서 사업자등록번호의 존재에 대한 유효성 검사는 한 후 이 프로시저를 실행하도록 한다.
*/

		SELECT ID INTO OUT_COMP_ID FROM COMPANY WHERE BIZ_REG_CODE = IN_COMP_BIZ_REG_CODE;
END