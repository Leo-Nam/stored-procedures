CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_cursorDemo`(
	IN IN_COMP_ID		BIGINT
)
BEGIN
	DECLARE endOfRow BOOLEAN DEFAULT FALSE;
	DECLARE vRowCount INT DEFAULT 0 ;
	DECLARE COMP_ID BIGINT;
    
	DECLARE SUBSIDIARY_CURSOR CURSOR FOR SELECT ID FROM COMPANY WHERE P_COMP_ID = IN_COMP_ID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
	OPEN SUBSIDIARY_CURSOR;	
	cloop: LOOP
		FETCH SUBSIDIARY_CURSOR INTO COMP_ID;
		SELECT endOfRow;
		SELECT * FROM COMPANY WHERE ID = COMP_ID; 
		/*UPDATE COMPANY SET ACTIVE = FALSE, UPDATED_AT = @REG_DT, RECOVERY_TAG = @REG_DT WHERE P_COMP_ID = COMP_ID;
		SET vRowCount = vRowCount + 1;*/
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
	END LOOP;   
	CLOSE SUBSIDIARY_CURSOR;
END