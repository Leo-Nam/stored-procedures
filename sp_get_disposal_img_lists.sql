CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_disposal_img_lists`(
	IN IN_DISPOSER_ORDER_ID			BIGINT,
    IN IN_CLASS						VARCHAR(20),
    OUT OUT_IMG_LIST				JSON
)
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'FILE_NAME'			, FILE_NAME, 
			'IMG_PATH'			, IMG_PATH, 
			'FILE_SIZE'			, FILE_SIZE
		)
	) 
	INTO OUT_IMG_LIST 
	FROM WSTE_REGISTRATION_PHOTO  
	WHERE 
		DISPOSAL_ORDER_ID 		= IN_DISPOSER_ORDER_ID AND
        CALSS_CODE				= IN_CLASS;	
END