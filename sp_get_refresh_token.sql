CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_refresh_token`(
	IN IN_USER_ID						BIGINT
)
BEGIN		
	CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        @rtn_val,
        @msg_txt
    );
    IF @rtn_val = 0 THEN
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'ID'				, ID, 
				'REFRESH_TOKEN'		, JWT
			)
		) 
		INTO @json_data 
		FROM USERS
		WHERE ID = IN_USER_ID;
		SET @rtn_val = 0;
        SET @msg_txt = 'success';
	ELSE
		SET @json_data = NULL;
		SET @rtn_val = 37101;
        SET @msg_txt = 'refresh token does not exist';
    END IF;
END