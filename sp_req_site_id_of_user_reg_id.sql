CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_site_id_of_user_reg_id`(
	IN IN_USER_ID			BIGINT,
    OUT OUT_SITE_ID			INT,				/*출력값 : 사이트 고유등록번호*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_site_id_of_user_reg_id
Input param 	: 1개
Output param 	: 3개
Job 			: 사용자가 속한 사이트의 고유등록번호를 반환한다.
Update 			: 2022.01.28
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.2)
*/

	SELECT AFFILIATED_SITE INTO @SITE_ID FROM USERS WHERE ID = IN_USER_ID;
    IF @SITE_ID IS NULL THEN
		SET OUT_SITE_ID = NULL;
		SET rtn_val = 22901;
		SET msg_txt = 'The site to which the user belongs does not exist';
    ELSE
		IF @SITE_ID = 0 THEN
			SET OUT_SITE_ID = 0;
			SET rtn_val = 22902;
			SET msg_txt = 'Individual users are not affiliated with the site';
        ELSE
			SET OUT_SITE_ID = @SITE_ID;
			SET rtn_val = 0;
			SET msg_txt = 'Success';
        END IF;
    END IF;
END