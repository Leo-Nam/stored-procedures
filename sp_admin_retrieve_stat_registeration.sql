CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_retrieve_stat_registeration`(
    IN IN_PARAMS					JSON
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		SET @json_data = NULL;
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;  
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
	SELECT USER_ID, PARAM_YEAR, PARAM_MONTH
    INTO @USER_ID, @PARAM_YEAR, @PARAM_MONTH
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID",
		PARAM_YEAR				INT					PATH "$.PARAM_YEAR",
		PARAM_MONTH				INT					PATH "$.PARAM_MONTH"
	)) AS PARAMS;   
    
    IF @PARAM_YEAR IS NOT NULL THEN
		CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_RETRIEVE_STAT_REGISTERATION_TEMP (
			USER_ID					BIGINT,
			STAT					JSON,
			INPUT_PARAM				JSON
		);
        IF @PARAM_MONTH IS NOT NULL THEN
			CALL sp_admin_retrieve_stat_registeration_month_without_handler(
				@PARAM_YEAR,
				@PARAM_MONTH,
				@STAT
			);
        ELSE
			CALL sp_admin_retrieve_stat_registeration_year_without_handler(
				@PARAM_YEAR,
				@STAT
			);
        END IF;
		SET @rtn_val 		= 0;
		SET @msg_txt 		= 'success';
    ELSE
		SET @rtn_val 		= 100101;
		SET @msg_txt 		= 'year should not be null';
        SET @json_data		= IN_PARAMS;
		SIGNAL SQLSTATE '23000';
    END IF;
    
	INSERT INTO 
	ADMIN_RETRIEVE_STAT_REGISTERATION_TEMP(
		USER_ID
	)
	VALUES(
		@USER_ID
	);
    
    UPDATE ADMIN_RETRIEVE_STAT_REGISTERATION_TEMP
    SET STAT = @STAT, INPUT_PARAM = IN_PARAMS
    WHERE USER_ID = @USER_ID;
    
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'USER_ID'				, USER_ID,
        'STAT'					, STAT,
        'INPUT_PARAM'			, INPUT_PARAM
	)) 
    INTO @json_data FROM ADMIN_RETRIEVE_STAT_REGISTERATION_TEMP;
    
	DROP TABLE IF EXISTS ADMIN_RETRIEVE_STAT_REGISTERATION_TEMP;
	CALL sp_return_results(@json_data, @msg_txt, @json_data);
END