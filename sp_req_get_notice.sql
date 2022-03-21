CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_get_notice`(
	IN IN_USER_ID				BIGINT
)
BEGIN
/*
Procedure Name 	: sp_req_get_notice
Input param 	: 1개
Job 			: 공지사항을 반환한다
Update 			: 2022.03.15
Version			: 0.0.2
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
		CALL sp_req_get_notice_without_handler(
			IN_USER_ID,
			@rtn_val,
			@msg_txt,
			@json_data
		);
		IF @rtn_val > 0 THEN
		/*공지사항 반환에 실패한 경우 예외처리한다*/
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
		SET @json_data = NULL;
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END