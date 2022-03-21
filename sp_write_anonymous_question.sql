CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_write_anonymous_question`(
	IN IN_PHONE					VARCHAR(20),		/*입력값 : 전화번호*/
	IN IN_EMAIL					VARCHAR(50),		/*입력값 : 이메일*/
	IN IN_CONTENTS				TEXT,				/*입력값 : 내용*/
	IN IN_SUB_CATEGORY			INT					/*입력값 : 서브카테고리가 있는 경우 사용(현재는 문의사항에만 존재)*/    
)
BEGIN

/*
Procedure Name 	: sp_write_anonymous_question
Input param 	: 4개
Job 			: 비회원 문의사항 작성
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
    IF IN_PHONE IS NOT NULL THEN
		IF IN_EMAIL IS NOT NULL THEN
			CALL sp_write_anonymous_question_without_handler(
				IN_PHONE,
				IN_EMAIL,
				IN_CONTENTS,
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
			SET @json_data = NULL;
			SET @rtn_val 		= 34401;
			SET @msg_txt 		= 'Email should not be empty';
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
		SET @json_data = NULL;
		SET @rtn_val 		= 34402;
		SET @msg_txt 		= 'Phone number should not be empty';
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END