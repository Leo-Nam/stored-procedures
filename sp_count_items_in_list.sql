CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_count_items_in_list`(
	IN IN_LIST			VARCHAR(200),
    OUT OUT_COUNT		INT	
)
BEGIN

/*
Procedure Name 	: sp_count_items_in_list
Input param 	: 1개
Output param 	: 1개
Job 			: 파라미터로 받은 리스트 안에 있는 아이템의 갯수를 반환한다.
Update 			: 2022.01.10
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	SET @IN_ARRAY = IN_LIST;
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
    
    SET OUT_COUNT = @LIST_COUNT;
END