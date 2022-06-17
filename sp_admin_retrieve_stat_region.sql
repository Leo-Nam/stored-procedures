CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_retrieve_stat_region`(
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
    
	SELECT USER_ID, REGION_CODE
    INTO @USER_ID, @REGION_CODE
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID",
		REGION_CODE				VARCHAR(10)			PATH "$.REGION_CODE"
	)) AS PARAMS;   
    
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_RETRIEVE_STAT_REGION_TEMP (
		USER_ID					BIGINT,
		STAT					JSON,
		INPUT_PARAM				JSON
	);
    IF @B_CODE IS NOT NULL THEN
		CALL sp_admin_retrieve_stat_region_sigungu_without_handler(
			@REGION_CODE,
			@STAT
		);
		SET @rtn_val 		= 0;
		SET @msg_txt 		= 'success';
    ELSE
		CALL sp_admin_retrieve_stat_region_sido_without_handler(
			@STAT
		);
		SET @rtn_val 		= 0;
		SET @msg_txt 		= 'success';
    END IF;
    
	INSERT INTO 
	ADMIN_RETRIEVE_STAT_REGION_TEMP(
		USER_ID
	)
	VALUES(
		@USER_ID
	);
    
    UPDATE ADMIN_RETRIEVE_STAT_REGION_TEMP
    SET STAT = @STAT, INPUT_PARAM = IN_PARAMS
    WHERE USER_ID = @USER_ID;
    
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'USER_ID'				, USER_ID,
        'STAT'					, STAT,
        'INPUT_PARAM'			, INPUT_PARAM
	)) 
    INTO @json_data FROM ADMIN_RETRIEVE_STAT_REGION_TEMP;
    
	DROP TABLE IF EXISTS ADMIN_RETRIEVE_STAT_REGION_TEMP;
	CALL sp_return_results(@json_data, @msg_txt, @json_data);
END