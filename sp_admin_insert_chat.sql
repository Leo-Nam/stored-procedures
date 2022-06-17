CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_insert_chat`(
    IN IN_PARAMS					JSON
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
    
	SELECT USER_ID, ROOM_ID, MESSAGE, IS_READ, MEDIA
    INTO @USER_ID, @ROOM_ID, @MESSAGE, @IS_READ, @MEDIA
    FROM JSON_TABLE(IN_PARAMS, "$[*]" COLUMNS(
		USER_ID 				BIGINT 				PATH "$.USER_ID",
		ROOM_ID 				INT 				PATH "$.ROOM_ID",
		MESSAGE 				TEXT		 		PATH "$.MESSAGE",
		IS_READ 				VARCHAR(255) 		PATH "$.IS_READ",
		MEDIA	 				TINYINT		 		PATH "$.MEDIA"
	)) AS PARAMS;

    CALL sp_req_current_time(@CREATED_AT);
    
    INSERT INTO CHATS(USER_ID, ROOM_ID, MESSAGE, CREATED_AT, IS_READ, MEDIA)
    VALUES(@USER_ID, @ROOM_ID, @MESSAGE, @CREATED_AT, @IS_READ, @MEDIA);
    
    IF ROW_COUNT() = 1 THEN    
		SELECT LAST_INSERT_ID() INTO @LAST_ID;
        
		CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_INSERT_CHAT_TEMP (
			USER_ID									BIGINT,
			CHAT_ID									BIGINT,
			ROOM_ID									BIGINT,
			MESSAGE									VARCHAR(255),
			CREATED_AT								DATETIME,
			IS_READ									TINYINT,
			DELETED									TINYINT,
			MEDIA									TINYINT
		);        
		
		INSERT INTO ADMIN_INSERT_CHAT_TEMP(USER_ID, CHAT_ID, ROOM_ID, MESSAGE, CREATED_AT, IS_READ, DELETED, MEDIA)
		SELECT 
			USER_ID, 
			ID, 
			ROOM_ID, 
			IF(DELETED = FALSE, MESSAGE, '삭제된 메시지입니다.'),
			CREATED_AT, 
			IS_READ,
			DELETED,
			MEDIA
		FROM CHATS WHERE ID = @LAST_ID;
		
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'USER_ID'				, USER_ID, 
			'CHAT_ID'				, CHAT_ID, 
			'ROOM_ID'				, ROOM_ID, 
			'MESSAGE'				, MESSAGE, 
			'CREATED_AT'			, CREATED_AT, 
			'IS_READ'				, IS_READ, 
			'DELETED'				, DELETED, 
			'MEDIA'					, MEDIA
		)) 
		INTO @json_data FROM ADMIN_INSERT_CHAT_TEMP;
		DROP TABLE IF EXISTS ADMIN_INSERT_CHAT_TEMP;
		SET @rtn_val = 0;
        SET @msg_txt = 'success';
    ELSE
		SET @rtn_val = 100201;
        SET @msg_txt = 'failed to insert chat messages';
		SIGNAL SQLSTATE '23000';
        SET @json_data = IN_PARAMS;
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END