CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_disposer_select_collector`(
	IN IN_USER_ID					BIGINT,
	IN IN_ORDER_ID					BIGINT,
	IN IN_BIDDING_ID				BIGINT
)
BEGIN
	DECLARE rtn_val					INT				DEFAULT NULL;
    DECLARE msg_txt					VARCHAR(200)	DEFAULT NULL;
    DECLARE json_data				JSON			DEFAULT NULL;
    DECLARE PUSH_CATEGORY_ID		INT;
    
    SET PUSH_CATEGORY_ID = 21;
	CALL sp_push_disposer_select_collector_without_handler(
		IN_USER_ID,
		IN_DISPOSER_ORDER_ID,
		IN_COLLECTOR_BIDDING_ID,
		PUSH_CATEGORY_ID,
		json_data,
		rtn_val,
		msg_txt
	);
	CALL sp_return_results(rtn_val, msg_txt, json_data);
END