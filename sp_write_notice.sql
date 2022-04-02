CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_write_notice`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 작성자의 고유등록번호 (USERS.ID)*/
	IN IN_SUBJECT				VARCHAR(255),		/*입력값 : 제목*/
	IN IN_CONTENTS				TEXT				/*입력값 : 내용*/
    /*추후 리뷰작성에 관한 사용자권한을 구분하여야 함. 해당 DISPOSER_ORDER에 관련된 사용자만이 리뷰를 작성할 수 있도록 해야 함*/
)
BEGIN

/*
Procedure Name 	: sp_write_notice
Input param 	: 5개
Job 			: 사용자들이 posting을 한다.
Update 			: 2022.03.18
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
		SELECT CLASS INTO @USER_CLASS FROM USERS WHERE ID = IN_USER_ID;
		IF @USER_CLASS < 200 THEN
		/*사용자가 치움시스템관리자인 경우에는 리뷰작성가능*/	
			CALL sp_write_notice_without_handler(
				IN_USER_ID,
				IN_SUBJECT,
				IN_CONTENTS,
				@rtn_val,
				@msg_txt,
				@json_data
			);
			IF @rtn_val > 0 THEN
			/*공지사항 작성에 실패한 경우 예외처리한다*/
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
		/*사용자가 치움시스템관리자가 아닌 경우에는 예외처리한다*/
			SET @rtn_val = 34201;
			SET @msg_txt = 'Chium Service aministrators use only';
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