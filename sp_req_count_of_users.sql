CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_count_of_users`(
	IN IN_SITE_ID				BIGINT,					/*찾고자 하는 사이트 고유등록번호*/
    IN IN_ACTIVE				TINYINT,				/*찾고자 하는 사용자의 활성화 상태, TRUE:활성화, FALSE:비활성화*/
    OUT NUMBER_OF_USERS			INT						/*동일한 사이트에 등록된 사용자의 수*/
)
BEGIN

/*
Procedure Name 		: sp_req_count_of_users
Input param 		: 2개
Output param 		: 1개
Job 				: 동일한 사이트에 소속한 사용자의 수를 반환한다.
Update 				: 2022.01.14
Version				: 0.0.1
AUTHOR 				: Leo Nam
*/
	
	IF IN_ACTIVE IS NULL THEN
		SELECT COUNT(ID) INTO NUMBER_OF_USERS FROM USERS WHERE AFFILIATED_SITE = IN_SITE_ID;
	ELSE
		SELECT COUNT(ID) INTO NUMBER_OF_USERS FROM USERS WHERE AFFILIATED_SITE = IN_SITE_ID AND ACTIVE = IN_ACTIVE;
	END IF;
END