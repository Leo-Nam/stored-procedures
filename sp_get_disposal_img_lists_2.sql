CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_disposal_img_lists_2`(
	IN IN_DISPOSER_ORDER_ID			BIGINT,
    IN IN_CLASS						ENUM('입찰', '처리'),
    OUT OUT_IMG_LIST				JSON
)
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'				, ID, 
			'PATH'				, IMG_PATH
		)
	) 
	INTO OUT_IMG_LIST 
	FROM WSTE_REGISTRATION_PHOTO 
	WHERE 
		DISPOSAL_ORDER_ID 		= IN_DISPOSER_ORDER_ID AND 
		CLASS_CODE 				= IN_CLASS AND
        ACTIVE					= TRUE;
END