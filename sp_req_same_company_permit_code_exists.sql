CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_same_company_permit_code_exists`(
	IN IN_PERMIT_REG_CODE	VARCHAR(100),		/*입력값: 체크할 수거자 업체등의 허가 또는 신고번호*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_same_company_permit_code_exists
Input param 	: 1개
Output param 	: 2개
Job 			: 체크할 허가 또는 신고번호로 등록된 사업자가 존재하는지 체크한 후 존재하지 않으면 0, 그렇지 않으면 예외처리코드를 반환하게 됨
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.2)
*/

	SELECT COUNT(ID) INTO @CHK_COUNT FROM COMPANY WHERE PERMIT_REG_CODE = IN_PERMIT_REG_CODE;
    
    IF @CHK_COUNT = 0 THEN
		SET rtn_val = 0;
        SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 27201;
        SET msg_txt = 'There is already a registered business license';
    END IF;
END