CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_scheduler_base`(
	IN IN_CATEGORY_ID			INT
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;  
    /*트랜잭션 시작*/  
    
	IF IN_CATEGORY_ID = 9 THEN
		CALL sp_push_schedule_visit_end_4(
			IN_CATEGORY_ID,
			@json_data,
			@rtn_val,
			@msg_txt
		);
    END IF;
    
	IF IN_CATEGORY_ID = 11 THEN
		CALL sp_push_schedule_visit_end(
			IN_CATEGORY_ID,
			@json_data,
			@rtn_val,
			@msg_txt
		);
    END IF;
    
	IF IN_CATEGORY_ID = 12 THEN
		CALL sp_push_schedule_visit_end_2(
			IN_CATEGORY_ID,
			@json_data,
			@rtn_val,
			@msg_txt
		);
    END IF;
    
	IF IN_CATEGORY_ID = 8 THEN
		CALL sp_push_schedule_visit_end_3(
			IN_CATEGORY_ID,
			@json_data,
			@rtn_val,
			@msg_txt
		);
    END IF;
    
	IF IN_CATEGORY_ID = 19 THEN
		CALL sp_push_schedule_bidding_end_1(
			IN_CATEGORY_ID,
			@json_data,
			@rtn_val,
			@msg_txt
		);
    END IF;
    
	IF IN_CATEGORY_ID = 17 THEN
		CALL sp_push_schedule_bidding_end_2(
			IN_CATEGORY_ID,
			@json_data,
			@rtn_val,
			@msg_txt
		);
    END IF;
    
	IF IN_CATEGORY_ID = 34 THEN
		CALL sp_push_schedule_bidding_end_3(
			IN_CATEGORY_ID,
			@json_data,
			@rtn_val,
			@msg_txt
		);
    END IF;
    
	IF IN_CATEGORY_ID = 35 THEN
		CALL sp_push_schedule_bidding_end_4(
			IN_CATEGORY_ID,
			@json_data,
			@rtn_val,
			@msg_txt
		);
    END IF;
    IF @rtn_val > 0 OR @rtn_val IS NULL THEN
		IF @rtn_val IS NULL THEN
			SET @rtn_val = 38801;
			SET @msg_txt = 'scheduler does not exist';
        END IF;
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
    CALL sp_return_results(@rtn_val, @msg_txt, @json_data);    
END