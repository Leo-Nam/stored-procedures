CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_company_validation`(
    IN IN_COMP_ID			BIGINT,				/*입력값 : 사용자 아이디*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_company_validation
Input param 	: 1개
Output param 	: 2개
Job 			: 사업자 계정이 활성상태로 존재하는지 체크하여 정상이면 0, 그렇지 않으면 예외처리코드 반환
Update 			: 2022.01.10
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	DECLARE ACTIVE_STAT		TINYINT;			/*사용자계정의 활성화 상태를 저장할 변수 선언*/
    
    SELECT COUNT(ID) INTO @COMPANY_EXISTS FROM COMPANY WHERE ID = IN_COMP_ID;
	/*COMPANY ID가 존재하는지 체크한다.*/
	/*COMPANY ID가 존재한다면 @COMPANY_EXISTS값이 1의 값을 가지게 되며 그렇지 않은 경우에는 0의 값을 가지게 된다.*/ 
    
	IF @COMPANY_EXISTS = 0 THEN
	/*COMPANY ID가 존재하지 않는 경우 예외처리한다.*/
		SET rtn_val = 20201;
		SET msg_txt = 'company is not existed';
	ELSE  
	/*COMPANY ID가 존재하는 경우에는 정상처리 진행한다.*/
		SELECT ACTIVE INTO ACTIVE_STAT FROM COMPANY WHERE ID = IN_COMP_ID;
		/*사업자의 활성상태를 VALID_STAT에 저정한다.*/
		
		IF ACTIVE_STAT = FALSE THEN
		/*계정이 비활성화된 상태인 경우에는 예외처리한다.*/
			SET rtn_val = 20202;
			SET msg_txt = 'company is not activated';
		ELSE
		/*계정이 활성화된 상태인 경우에는 정상처리한다.*/
			SET rtn_val = 0;
			SET msg_txt = 'company is valid';
		END IF;
    END IF;
END