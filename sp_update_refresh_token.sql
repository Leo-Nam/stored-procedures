CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_refresh_token`(
	IN IN_USER_ID			BIGINT,
    IN IN_REFRESH_TOKEN		VARCHAR(200)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;
	START TRANSACTION;
    /*트랜잭션 시작*/
    
    CALL sp_req_current_time(@REG_DT);
	CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
        @rtn_val,
        @msg_txt
    );
    IF @rtn_val = 0 THEN
		UPDATE USERS 
        SET 
			JWT = IN_REFRESH_TOKEN ,
            UPDATED_AT = @REG_DT
        WHERE ID = IN_USER_ID;
        IF ROW_COUNT() = 1 THEN
			SET @rtn_val = 0;
			SET @msg_txt = 'success';
        ELSE
			SET @rtn_val = 29801;
			SET @msg_txt = 'Failed to save refresh token';
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
		SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END