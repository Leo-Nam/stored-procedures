CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_wste_cls`(
	IN IN_USER_REG_ID	VARCHAR(50),		/*입력값 : 사용자 아이디*/
	IN IN_SITE_ID		BIGINT,				/*입력값 : 사이트 고유등록번호*/
	IN IN_WSTE_CLS		VARCHAR(200),		/*입력값 : 폐기물 구분 코드(ARRAY)*/
	IN IN_REG_DT		VARCHAR(200),		/*입력값 : 입력시간*/
    OUT rtn_val			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 		VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_update_wste_cls
Input param 	: 4개
Output param 	: 2개
Job 			: 수거자 등의 사업자가 관리가능한 폐기물 대구분 코드(ARRAY)를 풀어서 개별적인 INSERT 실행
				: 이 프로시저는 nested procedure로서 이 프로시저를 실행하기 전에 사용자, 사업자, 사용자권한에 대한 유효성 검사를 진행한 후 실행시켜야 한다.
Update 			: 2022.01.14
Version			: 0.0.2
AUTHOR 			: Leo Nam
CHANGE			: 사업자(COMPANY)중심에서 사이트(SITE)중심으로 이동
*/

	SET @WSTE_CLS_LIST = IN_WSTE_CLS;
    SET @IN_COUNT = 0;
    SET @INSERTED_ROW = 0;
    
    DELETE FROM SITE_WSTE_CLS_MATCH WHERE SITE_ID = IN_SITE_ID;
    
	WHILE (LOCATE(',', @WSTE_CLS_LIST) > 0) DO
		SET @WSTE_CLS = SUBSTRING(@WSTE_CLS_LIST, 1, LOCATE(',', @WSTE_CLS_LIST) - 1);
        SET @WSTE_CLS_LIST = SUBSTRING(@WSTE_CLS_LIST, LOCATE(',', @WSTE_CLS_LIST) + 1);        
        INSERT INTO SITE_WSTE_CLS_MATCH(SITE_ID, WSTE_CLS_CODE) VALUES(IN_SITE_ID, @WSTE_CLS);
        
		SET @INSERTED_ROW = @INSERTED_ROW + ROW_COUNT();
        SET @IN_COUNT = @IN_COUNT + 1;
    END WHILE;
    
	INSERT INTO SITE_WSTE_CLS_MATCH(SITE_ID, WSTE_CLS_CODE) VALUES(IN_SITE_ID, @WSTE_CLS_LIST);
	SET @INSERTED_ROW = @INSERTED_ROW + ROW_COUNT();
    
    IF @INSERTED_ROW < @IN_COUNT THEN
		SET rtn_val = 21001;
		SET msg_txt = 'Failed to change waste classification code';
	ELSE
		SET rtn_val = 0;
		SET msg_txt = 'Succeeded in changing the waste classification code';
    END IF;
END