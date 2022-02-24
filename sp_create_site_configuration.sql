CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_site_configuration`(
    IN IN_SITE_ID				BIGINT,						/*사이트 고유등록번호(COMP_SITE.ID)*/
    IN IN_REG_DT				DATETIME,					/*생성일시*/
	OUT rtn_val					INT,						/*출력값 : 처리결과 코드*/
	OUT msg_txt 				VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_create_site_configuration
Input param 	: 1개
Job 			: 최초의 환경설정을 구성한다.
Update 			: 2022.01.27
Version			: 0.0.2
AUTHOR 			: Leo Nam
Changes			: Create_Site에 삽입가능하도록 Nested Procedure Type으로 변경(0.0.2)
*/
    
	INSERT INTO SITE_CONFIGURATION (
		SITE_ID, 
        NOTICE, 
        PUSH, 
        CREATED_AT, 
        UPDATED_AT
	) 
	VALUES (
		IN_SITE_ID, 
        TRUE, 
        TRUE, 
        IN_REG_DT, 
        IN_REG_DT
	);
    IF ROW_COUNT() = 1 THEN
		SET rtn_val 		= 0;
		SET msg_txt 		= 'Success';
    ELSE
    /*사용자가 유효하지 않은 경우에는 예외처리한다.*/
		SET rtn_val 		= 24901;
		SET msg_txt 		= 'user account does not exist';
		SIGNAL SQLSTATE '23000';
    END IF;
END