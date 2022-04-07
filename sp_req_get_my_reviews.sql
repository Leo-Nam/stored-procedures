CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_get_my_reviews`(
	IN IN_USER_ID				BIGINT
)
BEGIN
/*
Procedure Name 	: sp_req_get_my_reviews
Input param 	: 1개
Job 			: 사용자가 작성한 리뷰를 반환한다
Update 			: 2022.03.15
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/		

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
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
    /*사용자가 유효한 경우에는 정상처리한다.*/
		CALL sp_req_get_my_reviews_without_handler(
			IN_USER_ID,
			@rtn_val,
			@msg_txt,
			@json_data
		);
    ELSE
    /*사용자가 유효하지 않은 경우에는 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END