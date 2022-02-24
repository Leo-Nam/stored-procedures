CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_site_wste_lists`(
	IN IN_WSTE_LISTS				VARCHAR(255),				/*폐기물 리스트*/
    OUT rtn_val 					INT,						/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_update_site_wste_lists
Input param 	: 2개
Output param 	: 2개
Job 			: 파라미터로 받은 리스트(폐기물 리스트)를 사이트(IN_SITE)의 폐기물 리스트(WSTE_SITE_MATCH)로 업데이트 해준다. 기존 폐기물 리스트(WSTE_SITE_MATCH)가 있다면 모두 삭제(ACTIVE = FALSE) 처리후 등록한다.
Update 			: 2022.01.10
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	SET @IN_ARRAY = IN_WSTE_LISTS;
    SET @ITEM = NULL;
    SET @SEPERATOR = ',' COLLATE utf8mb4_unicode_ci;
    /*리스트의 아이템을 분리하는 식별자로서 comma(,)를 사용하는 것으로 정의함. 식별자는 언제든지 변경가능함*/
    
    IF @IN_ARRAY IS NULL OR @IN_ARRAY = '' THEN
		SET @LIST_COUNT = 0;
    ELSE
		SET @LIST_COUNT = 1;
		WHILE (LOCATE(@SEPERATOR, @IN_ARRAY) > 0) DO
			SET @ITEM = SUBSTRING(@IN_ARRAY, 1, LOCATE(@SEPERATOR, @IN_ARRAY) - 1);
			SET @IN_ARRAY = SUBSTRING(@IN_ARRAY, LOCATE(@SEPERATOR, @IN_ARRAY) + 1);   
			SET @LIST_COUNT = @LIST_COUNT + 1;
		END WHILE;
    END IF;
    
    SET rtn_val = @LIST_COUNT;
    SET msg_txt = @IN_ARRAY;
END