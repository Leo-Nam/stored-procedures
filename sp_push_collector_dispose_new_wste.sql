CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_collector_dispose_new_wste`(
	IN IN_USER_ID					BIGINT,
	IN IN_ORDER_ID					BIGINT,
	IN IN_COLLECTOR_SITE_ID			BIGINT
)
BEGIN

	DECLARE json_data				JSON			DEFAULT NULL;
	DECLARE rtn_val					INT				DEFAULT NULL;
	DECLARE msg_txt					VARCHAR(200)	DEFAULT NULL;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET json_data 		= NULL;
		CALL sp_return_results(rtn_val, msg_txt, json_data);
	END;        
	START TRANSACTION;				
    /*트랜잭션 시작*/  
    
	CALL sp_push_collector_dispose_new_wste_sub(
		IN_USER_ID,
        IN_ORDER_ID,
        IN_COLLECTOR_SITE_ID,
        28,
        json_data,
        rtn_val,
        msg_txt
    );
    IF rtn_val > 0 THEN
		SET json_data 		= NULL;
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;      
	CALL sp_return_results(rtn_val, msg_txt, json_data);
END