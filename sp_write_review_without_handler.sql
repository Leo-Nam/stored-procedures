CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_write_review_without_handler`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 작성자의 고유등록번호 (USERS.ID)*/
	IN IN_CONTENTS				TEXT,				/*입력값 : 내용*/
	IN IN_SITE_ID				BIGINT,				/*입력값 : 게시판 소유자(COMP_SITE.ID)*/
	IN IN_PID					BIGINT,				/*입력값 : 댓글의 경우에는 원글의 번호이며 원글인 경우에는 0*/    
	IN IN_RATING				FLOAT,				/*입력값 : 리뷰작성시 입력되는 평점*/  
	IN IN_DISPOSER_ORDER_ID		BIGINT,				/*입력값 : 리뷰를 작성할 입찰등록번호*/      
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(100),		/*출력값 : 처리결과 문자열*/
    OUT json_data 				JSON
)
BEGIN

/*
Procedure Name 	: sp_write_review_without_handler
Input param 	: 5개
Job 			: 리뷰작성
Update 			: 2022.02.16
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	SELECT AFFILIATED_SITE INTO @USER_SITE_ID
    FROM USERS
    WHERE ID = IN_USER_ID;
    
    IF @USER_SITE_ID = 0 THEN
    /*작성자가 개인인 경우*/
		SELECT COUNT(ID) INTO @REVIEW_EXISTS
        FROM POSTS
        WHERE 
			CREATOR_ID = IN_USER_ID AND
            SITE_ID = IN_SITE_ID AND
            DISPOSER_ORDER_ID = IN_DISPOSER_ORDER_ID AND
            DELETED = FALSE;
    ELSE
    /*작성자가 사업자인 경우에는 소속사이트의 아이디로 등록된 리뷰가 존재하는 경우에는 리뷰를 본인이 리뷰를 작성하지 않았더라도 리뷰를 작성한 것으로 본다*/
		SELECT COUNT(A.ID) INTO @REVIEW_EXISTS
        FROM POSTS A
        LEFT JOIN USERS B ON A.CREATOR_ID = B.ID
        WHERE 
			B.AFFILIATED_SITE = @USER_SITE_ID AND
            A.SITE_ID = IN_SITE_ID AND
            A.DISPOSER_ORDER_ID = IN_DISPOSER_ORDER_ID AND
            A.DELETED = FALSE;
    END IF;
    
    IF @REVIEW_EXISTS = 0 THEN
    /*이전에 리뷰를 작성하지 않은 경우에는 정상처리한다.*/
		CALL sp_insert_post(
			IN_USER_ID,	
			NULL,
			IN_CONTENTS,
			IN_SITE_ID,
			4,
			NULL,
			IN_PID,
			IN_RATING,
			IN_DISPOSER_ORDER_ID,
			NULL,
			NULL,
			@rtn_val,
			@msg_txt,
			@last_insert_id
		);
		IF @rtn_val = 0 THEN
			SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'LAST_ID', @last_insert_id
				)
			) 
			INTO json_data;
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt;
		ELSE
		/*posting이 비정상적으로 종료된 경우 예외처리한다.*/
			SET json_data = NULL;
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt;
		END IF;
    ELSE
    /*이전에 리뷰를 작성한 경우에는 예외처리한다.*/
		SET json_data = NULL;
		SET rtn_val = 39701;
		SET msg_txt = 'you or your site already registered the review';
    END IF;
END