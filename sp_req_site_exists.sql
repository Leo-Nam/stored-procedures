CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_site_exists`(
	IN IN_SITE_ID			BIGINT,
    IN IN_ACTIVE			TINYINT,
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_site_exists
Input param 	: 2개
Output param 	: 1개
Job 			: 입력 param의 IN_SITE_ID를 사이트 고유등록번호로 사용하는 사이트가 존재하는지 여부 반환
Update 			: 2022.01.14
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	
    SELECT COUNT(ID) INTO @CHK_COUNT FROM COMP_SITE WHERE ID = IN_SITE_ID;
    IF @CHK_COUNT = 1 THEN
		IF IN_ACTIVE IS NULL THEN
			SELECT COUNT(ID) 
			INTO @CHK_COUNT 
			FROM COMP_SITE 
			WHERE ID 	= IN_SITE_ID;
            IF @CHK_COUNT = 1 THEN
				SET rtn_val = 0;
				SET msg_txt = 'Success';
            ELSE
				SET rtn_val = 26101;
				SET msg_txt = 'The site does not exist';
            END IF;
		ELSE
			SELECT COUNT(ID) 
			INTO @CHK_COUNT
			FROM COMP_SITE 
			WHERE 
				ID 		= IN_SITE_ID AND 
				ACTIVE 	= IN_ACTIVE;
		END IF;
            IF @CHK_COUNT = 1 THEN
				SET rtn_val = 0;
				SET msg_txt = 'Success';
            ELSE
				SET rtn_val = 26102;
				SET msg_txt = 'The site does not exist';
            END IF;
    ELSE
        SET rtn_val = 26103;
        SET msg_txt = 'The site does not exist';
    END IF;
END