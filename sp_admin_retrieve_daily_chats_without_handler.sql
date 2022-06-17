CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_retrieve_daily_chats_without_handler`(
    IN IN_ROOM_ID					BIGINT,
    IN IN_USER_ID					BIGINT,
    IN IN_DATE						DATE,
    OUT OUT_CHAT					JSON
)
BEGIN
	DECLARE rtn_val					INT;
    DECLARE msg_txt					VARCHAR(200);
    
    CALL sp_admin_set_is_read_true(
		IN_ROOM_ID,
        IN_USER_ID,
        rtn_val,
        msg_txt
    );
    
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_RETRIEVE_DAILY_CHATS_WITHOUT_HANDLER_TEMP (
		USER_ID									BIGINT,
		CHAT_ID									BIGINT,
		ROOM_ID									VARCHAR(100),
		MESSAGE									VARCHAR(255),
        CREATED_AT								DATETIME,
        IS_READ									TINYINT,
        DELETED									TINYINT,
        MEDIA									TINYINT
	);        
    
    INSERT INTO ADMIN_RETRIEVE_DAILY_CHATS_WITHOUT_HANDLER_TEMP(
		USER_ID, 
		CHAT_ID, 
        ROOM_ID, 
        MESSAGE, 
        CREATED_AT, 
        IS_READ,
        DELETED,
        MEDIA
    )
    SELECT 
		USER_ID, 
		ID, 
        ROOM_ID, 
        IF(DELETED = FALSE, MESSAGE, '삭제된 메시지입니다.'),
        CREATED_AT, 
        IS_READ,
        DELETED,
        MEDIA
    FROM CHATS
    WHERE 
		ROOM_ID = IN_ROOM_ID AND
        DATE(CREATED_AT) = IN_DATE
    ORDER BY CREATED_AT ASC;  
	
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
    INTO OUT_CHAT 
    FROM ADMIN_RETRIEVE_DAILY_CHATS_WITHOUT_HANDLER_TEMP;
	DROP TABLE IF EXISTS ADMIN_RETRIEVE_DAILY_CHATS_WITHOUT_HANDLER_TEMP;
END