CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_count_waiting_answers`(
	IN IN_ADMIN_MAIN_DURATION					BIGINT,
    OUT OUT_COUNT								INT
)
BEGIN

/*
Procedure Name 	: sp_get_count_waiting_answers
Input param 	: 1개
Job 			: 문의사항에 답변을 하지 않은 개수
Update 			: 2022.04.24
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_POST_ID							BIGINT; 
    DECLARE TEMP_CURSOR		 					CURSOR FOR 
	SELECT 
		ID
    FROM POSTS
    WHERE 
		CATEGORY = 3 AND
        DELETED = FALSE AND
        NOW() <= DATE_ADD(CREATED_AT, INTERVAL CAST(IN_ADMIN_MAIN_DURATION AS UNSIGNED) DAY);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	SET @COUNT_UNANSWER = 0;
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		SET @TEMP_COUNT = 0;
		FETCH TEMP_CURSOR 
		INTO CUR_POST_ID;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
        SELECT COUNT(ID) INTO @TEMP_COUNT
        FROM POSTS 
        WHERE PID = CUR_POST_ID;
        
        IF @TEMP_COUNT = 0 THEN
			SET @COUNT_UNANSWER = @COUNT_UNANSWER + 1;
        END IF;
	END LOOP;  
        
    SET OUT_COUNT = @COUNT_UNANSWER;
	CLOSE TEMP_CURSOR;
END