CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_comp_site_exists`(
	IN IN_COMP_ID				BIGINT,					/*찾고자 하는 사업자 고유등록번호*/
    IN IN_ACTIVE				TINYINT,				/*찾고자 하는 사업자의 활성화 상태, TRUE:활성화, FALSE:비활성화*/
    OUT rtn_val 				INT,					/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(100)			/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 		: sp_req_comp_site_exists
Input param 		: 2개
Output param 		: 2개
Job 				: 입력 param의 IN_COMP_REG_CODE를 사업자 등록번호로 등록된 STIE의 갯수를 반환
					: 사이트의 활성화 상태에 무관하게 모든 사이트를 검색하고자 하는 경우에는 IN_ACTIVE를 NULL로 입력받는다.
Update 				: 2022.01.29
Version				: 0.0.3
AUTHOR 				: Leo Nam
*/
	
	/*동일한 사업자 등록번호로 등록된 사이트의 개수를 구하여 NUMBER_OF_SITES를 통하여 반환한다.*/
	IF IN_ACTIVE IS NULL THEN
		SELECT COUNT(A.ID) INTO @CHK_COUNT FROM COMPANY A LEFT JOIN COMP_SITE B ON A.ID = B.COMP_ID WHERE A.ID = IN_COMP_ID;
	ELSE
		SELECT COUNT(A.ID) INTO @CHK_COUNT FROM COMPANY A LEFT JOIN COMP_SITE B ON A.ID = B.COMP_ID WHERE A.ID = IN_COMP_ID AND B.ACTIVE = IN_ACTIVE;
	END IF;
    
    IF @CHK_COUNT = 1 THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 28301;
		SET msg_txt = 'site does not exist';
    END IF;
END