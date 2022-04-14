CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_fcm_token`(
	IN IN_USER_ID					BIGINT
)
BEGIN
	SELECT COUNT(ID) INTO @USER_COUNT
    FROM USERS
    WHERE ID = IN_USER_ID AND ACTIVE = TRUE;
    IF @USER_COUNT = 1 THEN
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'USER_ID'	, ID, 
				'FCM'		, FCM
			)
		) 
		INTO @json_data
		FROM USERS 
		WHERE ID = IN_USER_ID AND ACTIVE = TRUE;
		SET @rtn_val 	= 0;
		SET @msg_txt 	= 'success';
		SET @json_data 	= NULL;
    ELSE
		SET @rtn_val 	= 37601;
		SET @msg_txt 	= 'user not found';
		SET @json_data 	= NULL;
    END IF;
END