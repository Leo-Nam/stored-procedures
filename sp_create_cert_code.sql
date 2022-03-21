CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_cert_code`(
	IN IN_PHONE_NO			VARCHAR(20)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;  
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    IF IN_PHONE_NO IS NULL OR IN_PHONE_NO = '' THEN
		SET @rtn_val = 32303;
		SET @msg_txt = 'Phone number should not be null or empty';
		SIGNAL SQLSTATE '23000';
    ELSE
		SELECT COUNT(ID) INTO @DUPLICATED_NUMBER FROM USERS WHERE PHONE = IN_PHONE_NO;
        SET @DUPLICATED_NUMBER = 0;
		IF @DUPLICATED_NUMBER = 0 THEN
			CALL sp_req_policy_direction(
				'min_req_cert_code_duration', 
				@min_req_cert_code_duration
			);
			SELECT COUNT(ID) INTO @RECENT_CALL_COUNT FROM CELL_PHONE_CERTIFICATION WHERE PHONE_NO = IN_PHONE_NO AND NOW() <= ADDTIME(CREATED_AT, CONCAT('00:00:', @min_req_cert_code_duration));
			IF @RECENT_CALL_COUNT > 0 THEN
				SELECT MAX(ID) INTO @ID FROM CELL_PHONE_CERTIFICATION WHERE PHONE_NO = IN_PHONE_NO;
				SELECT PHONE_NO, CERT_CODE INTO @PHONE_NO, @CERT_CODE FROM CELL_PHONE_CERTIFICATION WHERE ID = @ID;
				SELECT JSON_ARRAYAGG(JSON_OBJECT(
					'ID', @ID,
					'PHONE_NO', IN_PHONE_NO,
					'CERT_CODE', @CERT_CODE,
					'MIN_GEN_CYCLE', @min_req_cert_code_duration,
					'CERT_CODE_TIMEOUT', @min_req_cert_code_duration
				)) INTO @json_data;
				SET @rtn_val = 0;
				SET @msg_txt = 'success';
			ELSE            
				SELECT CAST(RAND()* 900000 AS UNSIGNED) + 100000 INTO @CERT_CODE; 
				INSERT INTO CELL_PHONE_CERTIFICATION(
					PHONE_NO,
					CERT_CODE
				) VALUES(
					IN_PHONE_NO,
					@CERT_CODE
				);
				
				SELECT LAST_INSERT_ID() INTO @ID;
				IF @ID IS NOT NULL THEN
					SELECT JSON_ARRAYAGG(JSON_OBJECT(
						'ID', @ID,
						'PHONE_NO', IN_PHONE_NO,
						'CERT_CODE', @CERT_CODE,
						'MIN_GEN_CYCLE', @min_req_cert_code_duration,
						'CERT_CODE_TIMEOUT', @min_req_cert_code_duration
					)) INTO @json_data;
					SET @rtn_val = 0;
					SET @msg_txt = 'success';
				ELSE
					SELECT JSON_ARRAYAGG(JSON_OBJECT(
						'ID', NULL,
						'PHONE_NO', NULL,
						'CERT_CODE', NULL,
						'MIN_GEN_CYCLE', @min_req_cert_code_duration,
						'CERT_CODE_TIMEOUT', @min_req_cert_code_duration
					)) INTO @json_data; 
					SET @rtn_val = 32301;
					SET @msg_txt = 'Failed to generate verification code';
					SIGNAL SQLSTATE '23000';
				END IF;
			END IF;
        ELSE
			SET @rtn_val = 32302;
			SET @msg_txt = 'Phone number already registered';
			SIGNAL SQLSTATE '23000';
        END IF;
    END IF;
    
    CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END