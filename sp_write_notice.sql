CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_write_notice`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 작성자의 고유등록번호 (USERS.ID)*/
	IN IN_SUBJECT				VARCHAR(255),		/*입력값 : 제목*/
	IN IN_CONTENTS				TEXT,				/*입력값 : 내용*/
	IN IN_SITE_ID				BIGINT,				/*입력값 : 게시판 소유자(COMP_SITE.ID)*/
	IN IN_PID					BIGINT				/*입력값 : 댓글의 경우에는 원글의 번호이며 원글인 경우에는 0*/    
)
BEGIN

/*
Procedure Name 	: sp_write_post
Input param 	: 5개
Job 			: 사용자들이 posting을 한다.
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
        CALL sp_req_user_class_by_user_reg_id(
			IN_USER_ID,
            @USER_CLASS
        );
		IF @USER_CLASS = 101 OR @USER_CLASS = 201 THEN
		/*사용자에게 글 작성 권한이 있는 경우 정상처리한다.*/
			CALL sp_write_notice_without_handler(
				IN_USER_ID,
				IN_CONTENTS,
				IN_SITE_ID,
				IN_PID,
				@USER_SITE_ID,
				@rtn_val,
				@msg_txt,
				@json_data
            );
            IF @rtn_val > 0 THEN
            /*공지사항 작성에 실패한 경우 예외처리한다*/
				SIGNAL SQLSTATE '23000';
            END IF;
		ELSE
		/*사용자에게 글 작성 권한이 없는 경우 예외처리한다.*/
			SET @json_data = NULL;
			SET @rtn_val = 33701;
			SET @msg_txt = 'User does not have permission to write notices';
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