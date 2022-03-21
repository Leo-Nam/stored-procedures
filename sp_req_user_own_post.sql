CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_own_post`(
	IN IN_USER_ID 				BIGINT,				/*입력값 : 관리자아이디(USERS.ID)*/
    IN IN_POST_ID 				BIGINT,				/*입력값 : 글 등록번호*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(100)		/*출력값 : 처리결과 문자열*/
    )
BEGIN

/*
Procedure Name 	: sp_req_user_own_post
Input param 	: 2개
Job 			: 사용자가 POST의 소유자인지 검사한다.
Update 			: 2022.03.13
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) INTO @COUNT FROM POSTS WHERE ID = IN_POST_ID AND CREATOR_ID = IN_USER_ID;
    IF @COUNT = 1 THEN
		SET rtn_val = 0;
        SET msg_txt = 'success';
    ELSE
		SET rtn_val = 32701;
        SET msg_txt = 'user does not own the post';
    END IF;
END