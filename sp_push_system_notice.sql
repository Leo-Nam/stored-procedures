CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_system_notice`(
	IN IN_POST_ID					BIGINT,
    OUT OUT_TARGET_LIST				JSON
)
BEGIN
		SELECT SUBJECTS
        INTO @SUBJECTS
        FROM POST
        WHERE ID = IN_POST_ID;
            
		SET @MSG = CONCAT('[', @SUBJECTS, '] 새로운 공지가 도착했습니다.');
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'USER_ID'	, ID, 
				'FCM'		, FCM,
				'MSG'		, @MSG
			)
		) 
		INTO OUT_TARGET_LIST
		FROM USERS 
		WHERE 
			ACTIVE 					= TRUE AND
			PUSH_ENABLED			= TRUE;
END