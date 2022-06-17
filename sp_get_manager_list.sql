CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_manager_list`(
	IN IN_SITE_ID					BIGINT,
    OUT OUT_MANAGER_LIST			JSON
)
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'					, ID, 
			'USER_NAME'				, USER_NAME, 
			'PHONE'					, PHONE, 
			'BELONG_TO'				, BELONG_TO, 
			'AFFILIATED_SITE'		, AFFILIATED_SITE, 
			'ACTIVE'				, ACTIVE, 
			'CLASS'					, CLASS, 
			'CS_MANAGER_ID'			, CS_MANAGER_ID, 
			'CONFIRMED'				, CONFIRMED, 
			'CONFIRMED_AT'			, CONFIRMED_AT, 
			'CREATED_AT'			, CREATED_AT, 
			'UPDATED_AT'			, UPDATED_AT, 
			'AGREEMENT_TERMS'		, AGREEMENT_TERMS, 
			'USER_CURRENT_TYPE'		, USER_CURRENT_TYPE, 
			'AVATAR_PATH'			, AVATAR_PATH, 
			'PUSH_ENABLED'			, PUSH_ENABLED, 
			'NOTICE_ENABLED'		, NOTICE_ENABLED
		)
	) 
	INTO OUT_MANAGER_LIST 
	FROM USERS  
	WHERE 
		AFFILIATED_SITE 		= IN_SITE_ID AND
        ACTIVE					= TRUE;	
END