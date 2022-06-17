CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_no_confirm_license_counts_daily`(
	IN IN_TARGET_DATE				DATE,
	IN IN_MENU_ID					INT,
    OUT OUT_COUNT					INT
)
BEGIN
    IF IN_MENU_ID IS NOT NULL THEN
		SELECT COUNT(DATE(A.CREATED_AT)) INTO OUT_COUNT
		FROM COMP_SITE A
		LEFT JOIN COMPANY B ON A.COMP_ID = B.ID
		WHERE 
			DATE(A.CREATED_AT) = IN_TARGET_DATE AND
			B.ACTIVE = TRUE AND
			A.ACTIVE = TRUE AND
            IF(IN_MENU_ID = 0,
				IF(IN_TARGET_DATE IS NOT NULL, 
					B.CONFIRMED = FALSE AND DATE(A.CREATED_AT) = IN_TARGET_DATE, 
					B.CONFIRMED = FALSE
				),
				IF(IN_MENU_ID = 1,
					IF(IN_TARGET_DATE IS NOT NULL, 
						(
							B.CONFIRMED = FALSE OR
                            A.CONFIRMED = FALSE
                        ) AND 
                        B.TRMT_BIZ_CODE = '1' AND
                        DATE(A.CREATED_AT) = IN_TARGET_DATE, 
						(
							B.CONFIRMED = FALSE OR
							A.CONFIRMED = FALSE
                        ) AND 
                        B.TRMT_BIZ_CODE = '1'
					),
					IF(IN_TARGET_DATE IS NOT NULL, 
						(
							B.CONFIRMED = FALSE OR
                            A.CONFIRMED = FALSE
                        ) AND 
                        B.TRMT_BIZ_CODE IN (
							SELECT CODE FROM WSTE_TRMT_BIZ WHERE CAST(CODE AS UNSIGNED) > 1 AND CAST(CODE AS UNSIGNED) < 9
						) AND
                        DATE(A.CREATED_AT) = IN_TARGET_DATE, 
						(
							B.CONFIRMED = FALSE OR
							A.CONFIRMED = FALSE
                        ) AND 
                        B.TRMT_BIZ_CODE IN (
							SELECT CODE FROM WSTE_TRMT_BIZ WHERE CAST(CODE AS UNSIGNED) > 1 AND CAST(CODE AS UNSIGNED) < 9
						)
					)
				)
            );
    ELSE
		SET OUT_COUNT = 0;
    END IF;
    
END