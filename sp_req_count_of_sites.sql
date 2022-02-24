CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_count_of_sites`(
	IN IN_COMP_ID				BIGINT,					/*찾고자 하는 사업자 고유등록번호*/
    IN IN_ACTIVE				TINYINT,				/*찾고자 하는 사업자의 활성화 상태, TRUE:활성화, FALSE:비활성화*/
    OUT NUMBER_OF_SITES			INT						/*개설된 사이트의 개소수를 반환함*/
)
BEGIN

/*
Procedure Name 		: sp_req_count_of_sites
Input param 		: 2개
Output param 		: 1개
Job 				: 동일한 사업자가 개설한 사이트의 개소수를 반환한다.
Update 				: 2022.01.14
Version				: 0.0.1
AUTHOR 				: Leo Nam
*/
	
	/*동일한 사업자 등록번호로 등록된 사이트의 개수를 구하여 NUMBER_OF_SITES를 통하여 반환한다.*/
	IF IN_ACTIVE IS NULL THEN
		SELECT COUNT(ID) INTO NUMBER_OF_SITES FROM COMP_SITE WHERE COMP_ID = IN_COMP_ID;
	ELSE
		SELECT COUNT(ID) INTO NUMBER_OF_SITES FROM COMP_SITE WHERE COMP_ID = IN_COMP_ID AND ACTIVE = IN_ACTIVE;
	END IF;
END