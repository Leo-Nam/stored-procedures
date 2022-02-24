CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_company`(
	IN IN_COMP_ID			BIGINT,
    IN IN_COMP_NAME			VARCHAR(100),
    IN IN_REP_NAME			VARCHAR(50),
    IN IN_KIKCD_B_CODE		VARCHAR(10),
    IN IN_ADDR				VARCHAR(300),
    IN IN_LNG		 		DECIMAL(12,9),		/*입력값 : 사업자 소재지의 경도값*/
    IN IN_LAT		 		DECIMAL(12,9),		/*입력값 : 사업자 소재지의 위도값*/
    IN IN_CONTACT			VARCHAR(100),
    IN IN_TRMT_BIZ_CODE		VARCHAR(4),
    IN IN_BIZ_REG_CODE		VARCHAR(12),
    IN IN_P_COMP_ID			BIGINT,
    IN IN_CREATED_AT		DATETIME,
    IN IN_UPDATED_AT		DATETIME,
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_insert_company
Input param 	: 11개
Output param 	: 2개
Job 			: 사업자 레코드를 생성한다. 성공하면 0, 실패하면 예외처리코드를 반환한다.
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	INSERT INTO COMPANY
		(ID, COMP_NAME, REP_NAME, KIKCD_B_CODE, ADDR, LNG, LAT, CONTACT, TRMT_BIZ_CODE, BIZ_REG_CODE, P_COMP_ID, CREATED_AT, UPDATED_AT) 
	VALUES
		(IN_COMP_ID, IN_COMP_NAME, IN_REP_NAME, IN_KIKCD_B_CODE, IN_ADDR, IN_LNG, IN_LAT, IN_CONTACT, IN_TRMT_BIZ_CODE, IN_BIZ_REG_CODE, IN_P_COMP_ID, IN_CREATED_AT, IN_UPDATED_AT);
		
	IF ROW_COUNT() = 1 THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 27301;
		SET msg_txt = 'An error occurred in the process of entering business information into the DB';
    END IF;
END