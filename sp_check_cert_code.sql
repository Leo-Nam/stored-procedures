CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_cert_code`(
	IN IN_ID				BIGINT,
    IN IN_PHONE_NO			VARCHAR(20),
    IN IN_CERT_CODE			INT
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;  
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    
    SELECT COUNT(ID) 
    INTO @DUPLICATED_NUMBER 
    FROM USERS 
    WHERE PHONE = IN_PHONE_NO;
    IF @DUPLICATED_NUMBER = 0 THEN
		SELECT COUNT(ID) 
		INTO @HAVE_SENT 
		FROM CELL_PHONE_CERTIFICATION 
		WHERE 
			ID 			= IN_ID AND 
			PHONE_NO 	= IN_PHONE_NO;			
		IF @HAVE_SENT = 1 THEN        
			SELECT COUNT(ID) 
			INTO @IS_CERTIFICATED 
			FROM CELL_PHONE_CERTIFICATION 
			WHERE ID = IN_ID;
			IF @IS_CERTIFICATED = 1 THEN
				CALL sp_req_policy_direction(
					'max_verification_time_out', 
					@max_verification_time_out
				);
				SELECT CERT_CODE, CREATED_AT 
				INTO @CERT_CODE, @CREATED_AT
				FROM CELL_PHONE_CERTIFICATION 
				WHERE ID = IN_ID;
				IF NOW() >= ADDTIME(@CREATED_AT, CONCAT('0:', @max_verification_time_out, ':00')) THEN
					IF @CERT_CODE = IN_CERT_CODE THEN
						UPDATE CELL_PHONE_CERTIFICATION
						SET 
							CERTIFICATED_AT = NOW(),
                            RESULT = TRUE
						WHERE ID = IN_ID;
						IF ROW_COUNT() = 1 THEN
							SELECT JSON_ARRAYAGG(JSON_OBJECT(
								'ID', IN_ID,
								'PHONE_NO', IN_PHONE_NO,
								'CERT_CODE', IN_CERT_CODE,
								'CREATED_AT', @CREATED_AT,
								'TIMEOUT', @max_verification_time_out
							)) INTO @json_data;
							SET @rtn_val = 0;
							SET @msg_txt = 'success';
						ELSE
							SELECT JSON_ARRAYAGG(JSON_OBJECT(
								'ID', IN_ID,
								'PHONE_NO', IN_PHONE_NO,
								'CERT_CODE', IN_CERT_CODE,
								'CREATED_AT', @CREATED_AT,
								'TIMEOUT', @max_verification_time_out
							)) INTO @json_data;
							SET @rtn_val = 32405;
							SET @msg_txt = 'Failed to record authentication after completion';
						END IF;
					ELSE
						SELECT JSON_ARRAYAGG(JSON_OBJECT(
							'ID', IN_ID,
							'PHONE_NO', IN_PHONE_NO,
							'CERT_CODE', IN_CERT_CODE,
							'CREATED_AT', @CREATED_AT,
							'TIMEOUT', @max_verification_time_out
						)) INTO @json_data;
						SET @rtn_val = 32404;
						SET @msg_txt = 'Verification code does not match';
					END IF;
				ELSE
					SELECT JSON_ARRAYAGG(JSON_OBJECT(
						'ID', IN_ID,
						'PHONE_NO', IN_PHONE_NO,
						'CERT_CODE', IN_CERT_CODE,
						'CREATED_AT', @CREATED_AT,
						'TIMEOUT', @max_verification_time_out
					)) INTO @json_data;
					SET @rtn_val = 32403;
					SET @msg_txt = 'authentication timeout';
				END IF;
			ELSE
				SELECT JSON_ARRAYAGG(JSON_OBJECT(
					'ID', IN_ID,
					'PHONE_NO', IN_PHONE_NO,
					'CERT_CODE', IN_CERT_CODE,
					'CREATED_AT', NULL,
					'TIMEOUT', NULL
				)) INTO @json_data;
				SET @rtn_val = 32402;
				SET @msg_txt = 'Verification code does not exist';
			END IF;
		ELSE
			SELECT JSON_ARRAYAGG(JSON_OBJECT(
				'ID', IN_ID,
				'PHONE_NO', IN_PHONE_NO,
				'CERT_CODE', IN_CERT_CODE,
				'CREATED_AT', NULL,
				'TIMEOUT', NULL
			)) INTO @json_data;
			SET @rtn_val = 32401;
			SET @msg_txt = 'not the phone number that generated the verification code';
		END IF;
    ELSE
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'ID', IN_ID,
			'PHONE_NO', IN_PHONE_NO,
			'CERT_CODE', IN_CERT_CODE,
			'CREATED_AT', NULL,
			'TIMEOUT', NULL
		)) INTO @json_data;
		SET @rtn_val = 32406;
		SET @msg_txt = 'Phone number already exists';
    END IF;
    COMMIT;
    CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END