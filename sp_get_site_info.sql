CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_site_info`(
	IN IN_SITE_ID			BIGINT,
    OUT OUT_SITE_INFO		JSON
)
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'SITE_ID'			, A.ID, 
			'SITE_NAME'			, A.SITE_NAME, 
			'B_CODE'			, A.KIKCD_B_CODE, 
			'SI_DO'				, B.SI_DO,
			'SI_GUN_GU'			, B.SI_GUN_GU,
			'EUP_MYEON_DONG'	, B.EUP_MYEON_DONG,
			'DONG_RI'			, B.DONG_RI,
			'ADDR'				, A.ADDR
		)
	) 
	INTO OUT_SITE_INFO 
	FROM COMP_SITE A 
    LEFT JOIN KIKCD_B B ON A.KIKCD_B_CODE = B.B_CODE
	WHERE A.ID = IN_SITE_ID;	
END