CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_comp_wste_cls`(
	IN IN_USER_REG_ID	VARCHAR(50),		/*입력값 : 사용자 아이디*/
	IN IN_COMP_ID		BIGINT,				/*입력값 : 사업자 고유등록번호*/
	IN IN_WSTE_CLS		VARCHAR(200),		/*입력값 : 폐기물 구분 코드(ARRAY)*/
	IN IN_REG_DT		DATETIME,			/*입력값 : 입력시간*/
    OUT rtn_val			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 		VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_update_comp_wste_cls
Input param 	: 4개
Output param 	: 2개
Job 			: 수거자 등의 사업자가 관리가능한 폐기물 대구분 코드(ARRAY)를 풀어서 개별적인 INSERT 실행
				: 이 프로시저는 nested procedure로서 이 프로시저를 실행하기 전에 사용자, 사업자, 사용자권한에 대한 유효성 검사를 진행한 후 실행시켜야 한다.
Update 			: 2022.01.10
Version			: 0.0.1
AUTHOR 			: Leo Nam

향후 IN_WSTE_CLS를 현재 list타입에서 json타입으로 로직변경해야 함
*/

	SET @WSTE_CLS_LIST = IN_WSTE_CLS;
    SET @IN_COUNT = 0;
    SET @LIST_COUNT = 0;
    SET @INSERTED_ROW = 0;
    
	SET rtn_val = -1;
	SET msg_txt = 'Nothing happend';
    
    IF IN_WSTE_CLS IS NOT NULL THEN
    /*입력받은 데이타 리스트에 무엇인가 존재하는 경우*/
		CALL sp_count_items_in_list(IN_WSTE_CLS, @NUMBER_OF_ITEMS);
        /*입력받은 데이타에 등록된 리스트가 존재하는 경우*/
		DELETE FROM COMP_WSTE_CLS_MATCH WHERE COMP_ID = IN_COMP_ID;
		
		WHILE (LOCATE(',', @WSTE_CLS_LIST) > 0) DO
			SET @WSTE_CLS = SUBSTRING(@WSTE_CLS_LIST, 1, LOCATE(',', @WSTE_CLS_LIST) - 1);
			SET @WSTE_CLS_LIST = SUBSTRING(@WSTE_CLS_LIST, LOCATE(',', @WSTE_CLS_LIST) + 1);        
			INSERT INTO COMP_WSTE_CLS_MATCH(COMP_ID, WSTE_CLS_CODE) VALUES(IN_COMP_ID, @WSTE_CLS);
			
			SET @INSERTED_ROW = @INSERTED_ROW + ROW_COUNT();
			SET @IN_COUNT = @IN_COUNT + 1;
		END WHILE;
		INSERT INTO COMP_WSTE_CLS_MATCH(COMP_ID, WSTE_CLS_CODE) VALUES(IN_COMP_ID, @WSTE_CLS_LIST);
		SET @INSERTED_ROW = @INSERTED_ROW + ROW_COUNT();	
		SET @IN_COUNT = @IN_COUNT + 1;		
		
		IF @INSERTED_ROW = @NUMBER_OF_ITEMS THEN
			SET rtn_val = 0;
			SET msg_txt = 'Succeeded in changing the waste classification code';
		ELSE
			SET rtn_val = 21001;
			SET msg_txt = 'The number of input data and the number of data input do not match';
		END IF;
    END IF;
END