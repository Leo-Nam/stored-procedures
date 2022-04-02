CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_get_notice_without_handler`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 게시판 소유자(COMP_SITE.ID)*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200),		/*출력값 : 처리결과 문자열*/
    OUT json_data 				json				/*출력값 : 포스팅 리스트*/
)
BEGIN

/*
Procedure Name 	: sp_req_get_notice_without_handler
Input param 	: 1개
Job 			: 공지사항을 반환한다.
Update 			: 2022.03.17
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/		

    DECLARE vRowCount 						INT DEFAULT 0;
    DECLARE endOfRow 						TINYINT DEFAULT FALSE;  
    
    DECLARE CUR_ID		 					BIGINT;
    DECLARE CUR_SUBJECTS	 				VARCHAR(255);
    DECLARE CUR_CONTENTS			 		TEXT;
    DECLARE CUR_CREATED_AT			 		DATETIME;
    
    DECLARE TEMP_CURSOR 					CURSOR FOR 
    SELECT 
		POST_ID, 
        POST_SUBJECTS, 
        POST_CONTENTS, 
        POST_CREATED_AT
	FROM V_POSTS 
    WHERE 
        POST_CATEGORY_ID 	= 1  AND 
        POST_ACTIVE		 	= TRUE 
	ORDER BY POST_UPDATED_AT DESC /*LIMIT IN_OFFSET, IN_ITEMS*/;   
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;   
    
    SET json_data = NULL;
	CREATE TEMPORARY TABLE IF NOT EXISTS TEMP_NOTICE_LIST (
		POST_ID 						BIGINT, 
		POST_SUBJECTS 					VARCHAR(255), 
		POST_CONTENTS 					TEXT, 
		POST_CREATED_AT 				DATETIME
	);
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_ID, 
			CUR_SUBJECTS, 
			CUR_CONTENTS, 
			CUR_CREATED_AT;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
				
		INSERT INTO 
			TEMP_NOTICE_LIST(
			POST_ID, 
			POST_SUBJECTS, 
			POST_CONTENTS, 
			POST_CREATED_AT
		) 
		VALUES(
			CUR_ID, 
			CUR_SUBJECTS, 
			CUR_CONTENTS, 
			CUR_CREATED_AT
		);  

	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'POST_ID'						, POST_ID, 
		'POST_SUBJECTS'					, POST_SUBJECTS, 
		'POST_CONTENTS'					, POST_CONTENTS, 
		'POST_CREATED_AT'				, POST_CREATED_AT
	)) 
	INTO json_data 
	FROM TEMP_NOTICE_LIST;
	
	SET rtn_val = 0;
	SET msg_txt = 'Success';
    DROP TABLE IF EXISTS TEMP_NOTICE_LIST;
END