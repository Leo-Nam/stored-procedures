CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_user`(
	IN IN_USER_ID				BIGINT,
    IN IN_USER_REG_ID			VARCHAR(50),
    IN IN_PWD					VARCHAR(100),
    IN IN_USER_NAME				VARCHAR(20),
    IN IN_PHONE					VARCHAR(20),
    IN IN_BELONG_TO				BIGINT,
    IN IN_AFFILIATED_SITE		BIGINT,
    IN IN_CLASS					INT,
    IN IN_DEPARTMENT			VARCHAR(20),
    IN IN_SOCIAL_NO				VARCHAR(20),
    IN IN_AGREE_TERMS			TINYINT,
    IN IN_CREATED_AT			DATETIME,
    IN IN_UPDATED_AT			DATETIME,
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_insert_user
Input param 	: 11개
Output param 	: 2개
Job 			: 사용자 레코드를 생성한다.
Update 			: 2022.01.27
Version			: 0.0.4
AUTHOR 			: Leo Nam
Changes			: FCM, JWT 입력부분 삭제(0.0.4)
*/

	INSERT INTO USERS(
		ID, 
        USER_ID, 
        PWD, 
        USER_NAME, 
        PHONE, 
        BELONG_TO, 
        AFFILIATED_SITE, 
        CLASS, 
        DEPARTMENT, 
        SOCIAL_NO, 
        AGREEMENT_TERMS, 
        CREATED_AT, 
        UPDATED_AT
    ) 
	VALUES(
		IN_USER_ID, 
        IN_USER_REG_ID, 
        IN_PWD, 
        IN_USER_NAME, 
        IN_PHONE, 
        IN_BELONG_TO, 
        IN_AFFILIATED_SITE, 
        IN_CLASS, 
        IN_DEPARTMENT, 
        IN_SOCIAL_NO, 
        IN_AGREE_TERMS, 
        IN_CREATED_AT, 
        IN_UPDATED_AT
    );
	
    IF ROW_COUNT() = 1 THEN
    /*사용자 레코드가 정상적으로 생성된 경우*/
		SET rtn_val = 0;
        SET msg_txt = 'Success';
    ELSE
    /*사용자 레코드 생성에 실패한 경우*/
		SET rtn_val = 26001;
        SET msg_txt = 'Failed to create user';
    END IF;
END