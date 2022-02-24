CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_user_collector`(
	IN IN_USER_ID					BIGINT,				/*사용자의 고유등록번호(USERS.ID)*/
    OUT rtn_val 					INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_is_user_collector
Input param 	: 1개
Output param 	: 2개
Job 			: 사용자가 소속한 사이트가 수집운반업자 등인 경우에는 0를 반환하고 그렇지 않은 경우에는 예외코드를 반환한다.
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: OUT 데이타를 반환코드와 결과문자열로 나누는 방식으로 변경(0.0.2)
*/

	SELECT TRMT_BIZ_CODE INTO @TRMT_BIZ_CODE FROM V_USERS WHERE ID = IN_USER_ID;
    IF @TRMT_BIZ_CODE IS NOT NULL THEN
		IF @TRMT_BIZ_CODE < 9 THEN
			SET rtn_val = 0;
            SET msg_txt = 'Success99';
		ELSE
			SET rtn_val = 26301;
            SET msg_txt = 'User is not a manager belonging to the collector';
		END IF;
    ELSE
		SET rtn_val = 26302;
		SET msg_txt = 'The site does not exist or the waste disposal code is invalid';
    END IF;
END