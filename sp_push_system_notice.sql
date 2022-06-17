CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_system_notice`(
	IN IN_SUBJECT					VARCHAR(255),
    IN IN_LAST_ID					BIGINT,
    IN IN_CATEGORY_ID				INT,
    OUT OUT_TARGET_LIST				JSON,
    OUT rtn_val 					INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN
    SET msg_txt = NULL;      
    CALL sp_req_current_time(@REG_DT);  
	SET @TITLE = CONCAT('[', IN_SUBJECT, ']');
	SET @BODY = CONCAT('[', IN_SUBJECT, '] 새로운 공지가 도착했습니다.');
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'USER_ID'				, ID, 
			'USER_NAME'				, USER_NAME, 
			'FCM'					, FCM, 
			'AVATAR_PATH'			, AVATAR_PATH,
			'TITLE'					, @TITLE,
			'BODY'					, @BODY,
			'ORDER_ID'				, NULL, 
			'BIDDING_ID'			, NULL, 
			'TRANSACTION_ID'		, NULL, 
			'REPORT_ID'				, NULL, 
			'CATEGORY_ID'			, IN_CATEGORY_ID,
			'CREATED_AT'			, @REG_DT
		)
	) 
	INTO @PUSH_INFO
	FROM USERS 
	WHERE 
		ACTIVE 					= TRUE AND
		PUSH_ENABLED			= TRUE;
	
	CALL sp_insert_push(
		0,
		@PUSH_INFO,
		@rtn_val,
		@msg_txt
	);
	SET msg_txt = @msg_txt;
	IF @rtn_val = 0 THEN
		CREATE TEMPORARY TABLE IF NOT EXISTS PUSH_INFO_TEMP (
			PUSH_INFO						JSON
		);     
		INSERT PUSH_INFO_TEMP(PUSH_INFO) VALUES(@PUSH_INFO);
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'PUSH_INFO'			, PUSH_INFO
		)) 
		INTO OUT_TARGET_LIST
		FROM PUSH_INFO_TEMP;  
		DROP TABLE IF EXISTS PUSH_INFO_TEMP;  
    END IF;
	SET rtn_val = @rtn_val;
	SET msg_txt = @msg_txt;
END