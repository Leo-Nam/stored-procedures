CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_site_registered_lists`(
    IN IN_USER_ID						BIGINT,
    IN IN_SEARCH						VARCHAR(255),
    IN IN_OFFSET_SIZE					INT,
    IN IN_PAGE_SIZE						INT
)
BEGIN
    
	
	SET @USER_ID 		= IN_USER_ID;
	SET @SEARCH 		= IN_SEARCH;
	SET @OFFSET_SIZE 	= IN_OFFSET_SIZE;
	SET @PAGE_SIZE 		= IN_PAGE_SIZE;
    
    SELECT A.LAT, A.LNG, C.USER_TYPE, A.ID
    INTO @LAT, @LNG, @USER_TYPE, @USER_SITE_ID
    FROM COMP_SITE A
    LEFT JOIN USERS B ON A.ID = B.AFFILIATED_SITE 
    LEFT JOIN WSTE_TRMT_BIZ C ON A.TRMT_BIZ_CODE = C.CODE
    WHERE B.ID = @USER_ID;
    
    CALL sp_retrieve_site_registered_lists_without_handler(
		IN_USER_ID,
		@USER_SITE_ID,
		@SEARCH,
		@LAT,
		@LNG,
		@OFFSET_SIZE,
		@PAGE_SIZE,
		@SITE_LISTS
    );
    
	DROP TABLE IF EXISTS RETRIEVE_SITE_REGISTERED_LISTS_TEMP;
    SET @rtn_val = 0;
    SET @msg_txt = 'success999';
	CALL sp_return_results(@rtn_val, @msg_txt, @SITE_LISTS);
END