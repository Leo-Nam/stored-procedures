CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_if_transaction_report_exists`(
	IN IN_REPORT_ID		INT,
    OUT rtn_val			INT,
    OUT msg_txt			VARCHAR(200)
)
BEGIN
	IF IN_REPORT_ID IS NOT NULL THEN
		SELECT COUNT(ID) INTO @REPORT_EXISTS 
		FROM TRANSACTION_REPORT 
		WHERE ID = IN_REPORT_ID;
		
		IF @REPORT_EXISTS = 0 THEN 
			SET rtn_val = 35902;
			SET msg_txt = 'Transaction Report ID does not exist';		
		ELSE
			SET rtn_val = 0;
			SET msg_txt = 'success';		
		END IF;
    ELSE
		SET rtn_val = 35901;
		SET msg_txt = 'Transaction Report ID should not be null';	
    END IF;
END