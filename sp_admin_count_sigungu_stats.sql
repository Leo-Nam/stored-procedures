CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_count_sigungu_stats`(
	IN IN_SIGUNGU_CODE					VARCHAR(10),
    OUT OUT_COUNT_COL					INT,
    OUT OUT_COUNT_EMI					INT
)
BEGIN  
	SELECT COUNT(ID) INTO @COUNT_COL
    FROM COMP_SITE A
    LEFT JOIN WSTE_TRMT_BIZ B ON A.TRMT_BIZ_CODE = B.CODE
    WHERE 
		LEFT(A.KIKCD_B_CODE, 5) = LEFT(IN_SIGUNGU_CODE, 5) AND
		A.TEST = FALSE AND
        B.USER_TYPE = 3;
        
	SELECT COUNT(ID) INTO @COUNT_EMI
    FROM COMP_SITE A
    LEFT JOIN WSTE_TRMT_BIZ B ON A.TRMT_BIZ_CODE = B.CODE
    WHERE 
		LEFT(A.IN_SIGUNGU_CODE, 5) = LEFT(IN_SIGUNGU_CODE, 5) AND
		A.TEST = FALSE AND
        B.USER_TYPE = 2;
        
	SET OUT_COUNT_COL = @COUNT_COL;
	SET OUT_COUNT_EMI = @COUNT_EMI;
END