CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_write_question_without_handler`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 작성자의 고유등록번호 (USERS.ID)*/
	IN IN_CONTENTS				TEXT,				/*입력값 : 내용*/
	IN IN_PID					BIGINT,				/*입력값 : 댓글의 경우에는 원글의 번호이며 원글인 경우에는 0*/    
	IN IN_SUB_CATEGORY			INT,				/*입력값 : 서브카테고리가 있는 경우 사용(현재는 문의사항에만 존재)*/    
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(100),		/*출력값 : 처리결과 문자열*/
    OUT json_data 				JSON
)
BEGIN

/*
Procedure Name 	: sp_write_question_without_handler
Input param 	: 5개
Job 			: 문의사항작성
Update 			: 2022.02.16
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	
	CALL sp_insert_post(
		IN_USER_ID,	
		NULL,
		IN_CONTENTS,
		0,
		3,
		IN_SUB_CATEGORY,
		IN_PID,
		NULL,
		NULL,
		NULL,
		NULL,
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