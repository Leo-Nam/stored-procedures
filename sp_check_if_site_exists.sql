CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_if_site_exists`(
	IN IN_SITE_ID		INT,
    OUT rtn_val			INT,
    OUT msg_txt			VARCHAR(200)
)
BEGIN
	SELECT COUNT(ID) INTO @SITE_EXISTS FROM COMP_SITE WHERE ID = IN_SITE_ID;
    IF @SITE_EXISTS = 0 THEN 
		SET rtn_val = 31701;
		SET msg_txt = 'SITE does not exist';		
    ELSE
		SET rtn_val = 0;
		SET msg_txt = 'success';		
    END IF;
END