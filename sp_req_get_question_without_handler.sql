CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_get_question_without_handler`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 사용자 아이디(USERS.ID)*/
	IN IN_SITE_ID				BIGINT,				/*입력값 : 게시판 소유자(COMP_SITE.ID)*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200),		/*출력값 : 처리결과 문자열*/
    OUT json_data 				json				/*출력값 : 포스팅 리스트*/
)
BEGIN

/*
Procedure Name 	: sp_req_get_posts
Input param 	: 2개
Job 			: 문의사항 작성자가 자신이 작성한 문의사항 리스트를 반환한다
Update 			: 2022.02.16
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/		

    DECLARE vRowCount 						INT DEFAULT 0;
    DECLARE endOfRow 						TINYINT DEFAULT FALSE;  
    
    DECLARE CUR_ID		 					BIGINT;
    DECLARE CUR_SITE_ID			 			BIGINT;
    DECLARE CUR_SITE_NAME		 			VARCHAR(255);
    DECLARE CUR_CREATOR_ID			 		BIGINT;
    DECLARE CUR_CREATOR_NAME		 		VARCHAR(20);
    DECLARE CUR_SUBJECTS			 		VARCHAR(255);
    DECLARE CUR_CONTENTS			 		TEXT;
    DECLARE CUR_CATEGORY			 		INT;
    DECLARE CUR_CATEGORY_NAME		 		VARCHAR(45);
    DECLARE CUR_SUB_CATEGORY		 		INT;
    DECLARE CUR_SUB_CATEGORY_NAME	 		VARCHAR(45);
    DECLARE CUR_VISITORS			 		INT;
    DECLARE CUR_CREATED_AT			 		DATETIME;
    DECLARE CUR_UPDATED_AT			 		DATETIME;
    DECLARE CUR_RATING				 		FLOAT;
    DECLARE CUR_STATUS				 		TINYINT;
    
    DECLARE TEMP_CURSOR 					CURSOR FOR 
    SELECT 
		POST_ID, 
        POST_SITE_ID, 
        POST_SITE_NAME, 
        POST_CREATOR_ID, 
        POST_CREATOR_NAME, 
        POST_SUBJECTS, 
        POST_CONTENTS, 
        POST_CATEGORY_ID, 
        POST_CATEGORY_NAME, 
        POST_SUB_CATEGORY_ID, 
        POST_SUB_CATEGORY_NAME, 
        POST_VISITORS, 
        POST_CREATED_AT, 
        POST_UPDATED_AT, 
        POST_RATING , 
        POST_STATUS 
	FROM V_POSTS 
    WHERE 
		POST_PID 			= 0 AND 
        POST_CREATOR_ID 	= IN_USER_ID AND 
        POST_SITE_ID 		= IN_SITE_ID  AND 
        POST_CATEGORY_ID	= 3 AND 
        POST_ACTIVE		 	= TRUE 
	ORDER BY POST_UPDATED_AT DESC /*LIMIT IN_OFFSET, IN_ITEMS*/;   
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;   
    
    SET json_data = NULL;
	CREATE TEMPORARY TABLE IF NOT EXISTS TEMP_QUESTION_LIST (
		ID 					BIGINT, 
		SITE_ID 			BIGINT, 
		SITE_NAME 			VARCHAR(255), 
		CREATOR_ID 			BIGINT, 
		CREATOR_NAME 		VARCHAR(20), 
		SUBJECTS 			VARCHAR(255), 
		CONTENTS 			TEXT, 
		CATEGORY_ID 		INT, 
		CATEGORY_NAME 		VARCHAR(45), 
		SUB_CATEGORY_ID 	INT, 
		SUB_CATEGORY_NAME 	VARCHAR(45), 
		VISITORS 			INT, 
		CREATED_AT 			DATETIME, 
		UPDATED_AT 			DATETIME, 
		REPLY 				JSON, 
		RATING				FLOAT, 
		AVATAR_PATH			VARCHAR(255), 
		STATUS				TINYINT
	);
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_ID, 
			CUR_SITE_ID, 
			CUR_SITE_NAME, 
			CUR_CREATOR_ID, 
			CUR_CREATOR_NAME, 
			CUR_SUBJECTS, 
			CUR_CONTENTS, 
			CUR_CATEGORY, 
			CUR_CATEGORY_NAME, 
			CUR_SUB_CATEGORY, 
			CUR_SUB_CATEGORY_NAME, 
			CUR_VISITORS,  
			CUR_CREATED_AT, 
			CUR_UPDATED_AT, 
			CUR_RATING, 
			CUR_STATUS;   
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
				
		INSERT INTO 
		TEMP_QUESTION_LIST(
			ID, 
			SITE_ID, 
			SITE_NAME, 
			CREATOR_ID, 
			CREATOR_NAME, 
			SUBJECTS, 
			CONTENTS, 
			CATEGORY_ID, 
			CATEGORY_NAME, 
			SUB_CATEGORY_ID, 
			SUB_CATEGORY_NAME, 
			VISITORS, 
			CREATED_AT, 
			UPDATED_AT, 
			RATING, 
			STATUS
		) 
		VALUES(
			CUR_ID, 
			CUR_SITE_ID, 
			CUR_SITE_NAME, 
			CUR_CREATOR_ID, 
			CUR_CREATOR_NAME, 
			CUR_SUBJECTS, 
			CUR_CONTENTS, 
			CUR_CATEGORY, 
			CUR_CATEGORY_NAME, 
			CUR_SUB_CATEGORY, 
			CUR_SUB_CATEGORY_NAME, 
			CUR_VISITORS, 
			CUR_CREATED_AT, 
			CUR_UPDATED_AT, 
			CUR_RATING, 
			CUR_STATUS
		);    

		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'ID'					, POST_ID, 
				'SITE_ID'				, POST_SITE_ID, 
				'SITE_NAME'				, POST_SITE_NAME, 
				'CREATOR_ID'			, POST_CREATOR_ID, 
				'CREATOR_NAME'			, POST_CREATOR_NAME, 
				'SUBJECTS'				, POST_SUBJECTS, 
				'CONTENTS'				, POST_CONTENTS, 
				'CATEGORY_ID'			, POST_CATEGORY_ID, 
				'CATEGORY_NAME'			, POST_CATEGORY_NAME, 
				'SUB_CATEGORY_ID'		, POST_SUB_CATEGORY_ID, 
				'SUB_CATEGORY_NAME'		, POST_SUB_CATEGORY_NAME, 
				'VISITORS'				, POST_VISITORS, 
				'CREATED_AT'			, POST_CREATED_AT, 
				'UPDATED_AT'			, POST_UPDATED_AT, 
				'RATING'				, POST_RATING
			)
		) 
		INTO @REPLY 
		FROM V_POSTS 
		WHERE POST_PID = CUR_ID AND
			POST_ACTIVE = TRUE;   
			
		UPDATE TEMP_QUESTION_LIST SET REPLY = @REPLY WHERE ID = CUR_ID;   
        
        SELECT A.AVATAR_PATH INTO @AVATAR_PATH FROM USERS A LEFT JOIN COMP_SITE B ON A.AFFILIATED_SITE = B.ID WHERE A.AFFILIATED_SITE = CUR_SITE_ID AND A.CLASS = 201;

	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'ID'					, ID, 
		'SITE_ID'				, SITE_ID, 
		'SITE_NAME'				, SITE_NAME, 
		'CREATOR_ID'			, CREATOR_ID, 
		'CREATOR_NAME'			, CREATOR_NAME, 
		'SUBJECTS'				, SUBJECTS, 
		'CONTENTS'				, CONTENTS, 
		'CATEGORY_ID'			, CATEGORY_ID, 
		'CATEGORY_NAME'			, CATEGORY_NAME, 
		'SUB_CATEGORY_ID'		, SUB_CATEGORY_ID, 
		'SUB_CATEGORY_NAME'		, SUB_CATEGORY_NAME, 
		'VISITORS'				, VISITORS, 
		'CREATED_AT'			, CREATED_AT, 
		'UPDATED_AT'			, UPDATED_AT, 
		'REPLY'					, REPLY, 
		'RATING'				, RATING, 
		'AVATAR_PATH'			, @AVATAR_PATH, 
		'STATUS'				, STATUS
	)) 
	INTO json_data 
	FROM TEMP_QUESTION_LIST;
	
	SET rtn_val = 0;
	SET msg_txt = 'Success';
    DROP TABLE IF EXISTS TEMP_QUESTION_LIST;
END