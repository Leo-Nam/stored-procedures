CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_write_notice_without_handler`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 작성자의 고유등록번호 (USERS.ID)*/
	IN IN_SUBJECT				VARCHAR(255),		/*입력값 : 제목*/
	IN IN_CONTENTS				TEXT,				/*입력값 : 내용*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(100),		/*출력값 : 처리결과 문자열*/
    OUT last_id 				BIGINT
)
BEGIN

/*
Procedure Name 	: sp_write_notice_without_handler
Input param 	: 3개
Job 			: 공지작성
Update 			: 2022.03.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	
	CALL sp_insert_post(
		IN_USER_ID,	
		IN_SUBJECT,
		IN_CONTENTS,
		0,
		1,
		NULL,
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		@rtn_val,
		@msg_txt,
		@last_insert_id
	);
	IF @rtn_val = 0 THEN
		SET last_id = @last_insert_id;
		SET rtn_val = @rtn_val;
		SET msg_txt = @msg_txt;
	ELSE
	/*posting이 비정상적으로 종료된 경우 예외처리한다.*/
		SET last_id = NULL;
		SET rtn_val = @rtn_val;
		SET msg_txt = @msg_txt;
	END IF;
END