CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_if_class_exists`(
	IN CLASS_ID			INT,
    OUT rtn_val			INT,
    OUT msg_txt			VARCHAR(200)
)
BEGIN
	SELECT COUNT(CLASS_ID) INTO @CLASS_EXISTS FROM USERS_CLASS WHERE ID = CLASS_ID;
    IF @CLASS_EXISTS = 0 THEN 
		SET rtn_val = 31501;
		SET msg_txt = 'CLASS does not exist';		
    ELSE
		SET rtn_val = 0;
		SET msg_txt = 'success';		
    END IF;
END