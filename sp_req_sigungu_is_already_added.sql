CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_sigungu_is_already_added`(
	IN IN_SITE_ID						BIGINT,
    IN IN_SIGUNGU_CODE					VARCHAR(10),
    OUT rtn_val 						INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 						VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_sigungu_is_already_added
Input param 	: 2개
Output param 	: 1개
Job 			: 검사하고자 하는 시군구가 이미 사이트에 등록되어 있는지 검사한다.
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.2)
*/

	SELECT COUNT(ID) 
    INTO @CHK_COUNT 
    FROM BUSINESS_AREA 
    WHERE 
		SITE_ID = IN_SITE_ID AND 
        KIKCD_B_CODE = IN_SIGUNGU_CODE AND
        ACTIVE = TRUE;
	
    IF @CHK_COUNT = 0 THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 26401;
		SET msg_txt = 'The area of ​​interest is already registered';
    END IF;
END