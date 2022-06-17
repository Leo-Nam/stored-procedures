CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_delete_chat`(
    IN IN_PARAMS					JSON
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= IN_PARAMS;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작1*/  
    
	SELECT USER_ID, CHAT_ID_LIST
    INTO @USER_ID, @CHAT_ID_LIST
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID",
		CHAT_ID_LIST			VARCHAR(255)		PATH "$.CHAT_ID_LIST"
	)) AS PARAMS;    
    
    CALL sp_req_current_time(@REG_DT);
    
    SET @CHAT_ID = NULL;
    SET @SEPERATOR = ',' COLLATE utf8mb4_unicode_ci;
    /*리스트의 아이템을 분리하는 식별자로서 comma(,)를 사용하는 것으로 정의함. 식별자는 언제든지 변경가능함*/
    SET @INVALID_COUNT = 0;
    
    SET @COUNT_OF_LIST_ADDED = 0;
    IF @CHAT_ID_LIST IS NULL OR @CHAT_ID_LIST = '' THEN
		SET @LIST_COUNT = 0;
    ELSE
		SET @LIST_COUNT = 1;
		WHILE (LOCATE(@SEPERATOR, @CHAT_ID_LIST) > 0) DO
			SET @CHAT_ID = SUBSTRING(@CHAT_ID_LIST, 1, LOCATE(@SEPERATOR, @CHAT_ID_LIST) - 1);
			SET @CHAT_ID_LIST = SUBSTRING(@CHAT_ID_LIST, LOCATE(@SEPERATOR, @CHAT_ID_LIST) + 1);  
            
			CALL sp_admin_delete_chat_without_handler(
				@USER_ID,
				@CHAT_ID,
				@REG_DT,
				@rtn_val,
				@msg_txt
			);
		END WHILE;
            
		CALL sp_admin_delete_chat_without_handler(
			@USER_ID,
			@CHAT_ID_LIST,
			@REG_DT,
			@rtn_val,
			@msg_txt
		);
    END IF;    
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END