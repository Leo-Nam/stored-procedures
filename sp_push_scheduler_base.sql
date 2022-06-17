CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_scheduler_base`(
	IN IN_CATEGORY_ID			INT
)
BEGIN
	DECLARE return_val 		INT DEFAULT NULL;
	DECLARE message_txt		VARCHAR(200) DEFAULT NULL;
	DECLARE return_object	JSON DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET return_object 		= NULL;
		CALL sp_return_results(return_val, message_txt, return_object);
	END;        
	START TRANSACTION;  
    /*트랜잭션 시작*/
	IF IN_CATEGORY_ID = 8 THEN
		CALL sp_push_schedule_visit_end_3(
			IN_CATEGORY_ID,
			return_object,
			return_val,
			message_txt
		);
		CALL sp_return_results(return_val, message_txt, return_object);    
	ELSEIF IN_CATEGORY_ID = 9 THEN
		CALL sp_push_schedule_visit_end_4(
			IN_CATEGORY_ID,
			return_object,
			return_val,
			message_txt
		);
		CALL sp_return_results(return_val, message_txt, return_object);
	ELSEIF IN_CATEGORY_ID = 17 THEN
		CALL sp_push_schedule_bidding_end_2(
			IN_CATEGORY_ID,
			return_object,
			return_val,
			message_txt
		);
		CALL sp_return_results(return_val, message_txt, return_object);
	ELSEIF IN_CATEGORY_ID = 19 THEN
		CALL sp_push_schedule_bidding_end_1(
			IN_CATEGORY_ID,
			return_object,
			return_val,
			message_txt
		);
		CALL sp_return_results(return_val, message_txt, return_object);
	ELSEIF IN_CATEGORY_ID = 26 THEN
		CALL sp_push_schedule_ask_review(
			IN_CATEGORY_ID,
			return_object,
			return_val,
			message_txt
		);
		CALL sp_return_results(return_val, message_txt, return_object);
	ELSE
		SET return_val = 38801;
		SET message_txt = 'scheduler does not exist';
		SIGNAL SQLSTATE '23000';
	END IF; 
    COMMIT;
END