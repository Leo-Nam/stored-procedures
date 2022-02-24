CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_site_wste_lists_without_handler`(
	IN IN_USER_REG_ID				VARCHAR(255),				/*폐기물 리스트를 업데이트 하려고 하는 사용자의 고유등록번호(USERS.ID)*/
	IN IN_WSTE_LISTS				VARCHAR(255),				/*폐기물 리스트*/
	IN IN_SITE_ID					BIGINT,						/*폐기물의 종류를 업데이트할 사이트의 고유등록번호(COMP_SITE.ID)*/
	IN IN_REG_DT					DATETIME,					/*자료등록 및 변경일자*/
    OUT rtn_val 					INT,						/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_update_site_wste_lists_without_handler
Input param 	: 4개
Output param 	: 2개
Job 			: 파라미터로 받은 리스트(폐기물 리스트)를 사이트(IN_SITE)의 폐기물 리스트(WSTE_SITE_MATCH)로 업데이트 해준다. 기존 폐기물 리스트(WSTE_SITE_MATCH)가 있다면 모두 삭제(ACTIVE = FALSE) 처리후 등록한다.
Update 			: 2022.01.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SET @IN_ARRAY = IN_WSTE_LISTS;
    SET @ITEM = NULL;
    SET @SEPERATOR = ',' COLLATE utf8mb4_unicode_ci;
    /*리스트의 아이템을 분리하는 식별자로서 comma(,)를 사용하는 것으로 정의함. 식별자는 언제든지 변경가능함*/
    
    IF @IN_ARRAY IS NULL OR @IN_ARRAY = '' THEN
    /*입력받은 ARRAY가 비어 있거나 또는 NULL인 경우에는 예외처리한다.*/
		SET rtn_val = 22301;
		SET msg_txt = 'No waste information';
    ELSE
    /*입력받은 ARRAY가 비어 있지 않은 경우*/
		UPDATE WSTE_SITE_MATCH SET ACTIVE = FALSE, UPDATED_AT = IN_REG_DT WHERE SITE_ID = IN_SITE_ID AND ACTIVE = TRUE;
        /*이전에 등록되어 있는 폐기물 리스트를 모두 삭제(ACTIVE = FALSE)처리한다.*/
        
		myloop : WHILE (LOCATE(@SEPERATOR, @IN_ARRAY) > 0) DO
			SET @ITEM = SUBSTRING(@IN_ARRAY, 1, LOCATE(@SEPERATOR, @IN_ARRAY) - 1);
			SET @IN_ARRAY = SUBSTRING(@IN_ARRAY, LOCATE(@SEPERATOR, @IN_ARRAY) + 1);   
            INSERT INTO WSTE_SITE_MATCH(SITE_ID, WSTE_CODE, ACTIVE, CREATED_AT, UPDATED_AT) VALUES(IN_SITE_ID, @ITEM, TRUE, IN_REG_DT, IN_REG_DT);
            /*ARRAY에서 폐기물 아이템을 하나 받아서 WSTE_SITE_MATCH에 입력한다.*/
            IF ROW_COUNT() = 0 THEN
            /*폐기물 정보 입력에 실패한 경우 예외처리하면서 WHILE 조건문을 빠져 나간다.*/
				SET rtn_val = 22302;
				SET msg_txt = 'Failed to enter waste information';
				LEAVE myloop;
                /*WHILE 조건문을 빠져 나간다.*/
			ELSE
				SET rtn_val = 0;
				SET msg_txt = 'Success';
            END IF;
		END WHILE;
		INSERT INTO WSTE_SITE_MATCH(SITE_ID, WSTE_CODE, ACTIVE, CREATED_AT, UPDATED_AT) VALUES(IN_SITE_ID, @IN_ARRAY, TRUE, IN_REG_DT, IN_REG_DT);
        /*마지막 남은 아이템을 WSTE_SITE_MATCH에 입력처리한다.*/
		IF ROW_COUNT() = 0 THEN
		/*폐기물 정보 입력에 실패한 경우 예외처리한다.*/
			SET rtn_val = 22303;
			SET msg_txt = 'Failed to enter waste information';
		ELSE
			SET rtn_val = 0;
			SET msg_txt = 'Success';
		END IF;
    END IF;
END