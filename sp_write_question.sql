CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_write_question`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 작성자의 고유등록번호 (USERS.ID)*/
	IN IN_CONTENTS				TEXT,				/*입력값 : 내용*/
	IN IN_PID					BIGINT,				/*입력값 : 댓글의 경우에는 원글의 번호이며 원글인 경우에는 0*/   
	IN IN_SUB_CATEGORY			INT					/*입력값 : 서브카테고리가 있는 경우 사용(현재는 문의사항에만 존재)*/    
)
BEGIN

/*
Procedure Name 	: sp_write_question
Input param 	: 4개
Job 			: 문의사항 작성
Update 			: 2022.02.16
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
	CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
        @rtn_val,
        @msg_txt
    );
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우 정상처리한다.*/
		CALL sp_write_question_without_handler(
			IN_USER_ID,
			IN_CONTENTS,
			IN_PID,
			IN_SUB_CATEGORY,
			@rtn_val,
			@msg_txt,
			@json_data
		);
		IF @rtn_val > 0 THEN
		/*공지사항 작성에 실패한 경우 예외처리한다*/
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SET @json_data = NULL;
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END