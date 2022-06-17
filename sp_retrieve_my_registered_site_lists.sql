CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_my_registered_site_lists`(
	IN IN_USER_ID							BIGINT,
	IN IN_USER_TYPE							INT,
    IN IN_OFFSET_SIZE						INT,
    IN IN_PAGE_SIZE							INT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_my_registered_site_lists
Input param 	: 1개
Job 			: 배출자가 등록한 사이트 및 수거자를 등록한 배출자 사이트의 리스트를 반환한다.
Update 			: 2022.05.13
Version			: 0.0.3
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
    
    CALL sp_retrieve_my_registered_site_lists_without_handler(
		IN_USER_ID,
		IN_USER_TYPE,
        IN_OFFSET_SIZE,
        IN_PAGE_SIZE,
        @rtn_val,
        @msg_txt,
        @json_data
    );
    IF @rtn_val > 0 THEN
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END