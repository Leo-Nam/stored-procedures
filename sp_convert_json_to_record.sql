CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_convert_json_to_record`(
	IN IN_JSON_DATA						JSON,
    IN IN_TITLE							VARCHAR(50),
    OUT rtn_val							INT
)
BEGIN

/*
Procedure Name 	: sp_convert_json_to_record
Input param 	: 2개
Output param 	: 1개
Job 			: 파라미터로 입력받은 JSON데이타를 테이블 형식으로 반환함. 에러가 발생하는 경우에는 rtn_val을 통하여 0을 반환함
Update 			: 2022.01.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	IF IN_TITLE = 'WSTE_LIST_DISCHARGED' THEN
		SELECT * FROM JSON_TABLE(IN_JSON_DATA, "$[*]" COLUMNS(
			WSTE_CLASS_CODE 		VARCHAR(100) 					PATH "$.WSTE_CLASS_CODE",
			WSTE_APPERANCE 			VARCHAR(100) 					PATH "$.WSTE_APPERANCE",
			UNIT 					ENUM('Kg','m3','전체견적가')		PATH "$.UNIT",
			QUANTITY 				FLOAT							PATH "$.QUANTITY"
		)) AS WSTE_LIST;
		SET rtn_val = 1;
	ELSE
		IF IN_TITLE = 'WSTE_REG_PHOTO' THEN
			SELECT * FROM JSON_TABLE(IN_JSON_DATA, "$[*]" COLUMNS(
				FILE_NAME				VARCHAR(100) 					PATH "$.FILE_NAME",
				PATH 					VARCHAR(255)					PATH "$.PATH"
			)) AS WSTE_PHOTO;
			SET rtn_val = 1;
		ELSE
			SET rtn_val = 0;
		END IF;
    END IF;
END