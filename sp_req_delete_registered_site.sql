CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_delete_registered_site`(
	IN IN_USER_ID					BIGINT,
    IN IN_USER_TYPE					INT,
	IN IN_TARGET_ID					BIGINT,
    IN IN_EVENT_TYPE				INT
)
BEGIN

/*
Procedure Name 	: sp_req_delete_registered_site
Input param 	: 2개
Job 			: 관심업체로 등록한 사이트를 삭제한다.
Update 			: 2022.05.18
Version			: 0.0.1
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
    
    /*SET @EVENT_TYPE = IN_EVENT_TYPE;*/
    SET @EVENT_TYPE = 1;
    IF @EVENT_TYPE = 1 THEN
		CALL sp_req_delete_registered_site_1_without_handler(
			IN_USER_ID,
			IN_USER_TYPE,
			IN_TARGET_ID,
			@rtn_val,
			@msg_txt
		);
    ELSE
		CALL sp_req_delete_registered_site_2_without_handler(
			IN_USER_ID,
			IN_USER_TYPE,
			IN_TARGET_ID,
			@rtn_val,
			@msg_txt
		);
    END IF;
    IF @rtn_val > 0 THEN
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END