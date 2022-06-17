CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_last_report_confirmed_at`(
	IN IN_USER_ID					BIGINT,
	IN IN_COLLECTOR_SITE_ID			BIGINT,
    OUT OUT_LAST_CONFIRMED_AT		DATETIME
)
BEGIN
	SET @CONFIRMED_AT = NULL;
	SELECT A.CONFIRMED_AT INTO @CONFIRMED_AT
    FROM TRANSACTION_REPORT A 
    LEFT JOIN USERS B ON A.DISPOSER_SITE_ID = B.AFFILIATED_SITE
    WHERE B.ID = IN_USER_ID AND COLLECTOR_SITE_ID = IN_COLLECTOR_SITE_ID
    ORDER BY A.CONFIRMED_AT DESC
    LIMIT 1;
    SET OUT_LAST_CONFIRMED_AT = @CONFIRMED_AT;
END