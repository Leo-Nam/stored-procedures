CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_write_anonymous_question_without_handler`(
	IN IN_PHONE					VARCHAR(20),		/*입력값 : 전화번호*/
	IN IN_EMAIL					VARCHAR(50),		/*입력값 : 이메일*/
	IN IN_CONTENTS				TEXT,				/*입력값 : 내용*/
	IN IN_SUB_CATEGORY			INT,				/*입력값 : 서브카테고리가 있는 경우 사용(현재는 문의사항에만 존재)*/    
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(100),		/*출력값 : 처리결과 문자열*/
    OUT json_data 				JSON
)
BEGIN

/*
Procedure Name 	: sp_write_anonymous_question_without_handler
Input param 	: 5개
Job 			: 비회원의 문의사항작성
Update 			: 2022.03.19
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	
	CALL sp_insert_post(
		NULL,	
		NULL,
		IN_CONTENTS,
		0,
		3,
		IN_SUB_CATEGORY,
		0,
		NULL,
		NULL,
		IN_PHONE,
		IN_EMAIL,
		@rtn_val,
		@msg_txt,
		@last_insert_id
	);
	IF @rtn_val = 0 THEN
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'LAST_ID', @last_insert_id
			)
		) 
		INTO json_data;
		SET rtn_val = @rtn_val;
		SET msg_txt = @msg_txt;
	ELSE
	/*posting이 비정상적으로 종료된 경우 예외처리한다.*/
		SET json_data = NULL;
		SET rtn_val = @rtn_val;
		SET msg_txt = @msg_txt;
	END IF;
END