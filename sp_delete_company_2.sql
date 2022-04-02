CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_company_2`(
    IN TARGET_COMP_ID			BIGINT,
    IN IN_TARGET_SITE_ID		BIGINT,
    IN IN_COUNT_SITE_USERS		INT,
    OUT rtn_val					INT,
    OUT msg_txt					VARCHAR(200)
)
BEGIN
                    
	UPDATE USERS 
	SET ACTIVE = FALSE 
	WHERE AFFILIATED_SITE = IN_TARGET_SITE_ID;
	
	IF ROW_COUNT() = IN_COUNT_SITE_USERS THEN
		UPDATE COMP_SITE 
		SET ACTIVE = FALSE 
		WHERE ID = IN_TARGET_SITE_ID;
		
		IF ROW_COUNT() = 1 THEN
			UPDATE COMPANY 
			SET ACTIVE = FALSE 
			WHERE ID = TARGET_COMP_ID;
			
			IF ROW_COUNT() = 1 THEN
				SET rtn_val = 0;
				SET msg_txt = 'Success';
			ELSE
				SET rtn_val = 32203;
				SET msg_txt = 'Company deactivation failed';
			END IF;
		ELSE
			SET rtn_val = 32202;
			SET msg_txt = 'Site deactivation failed';
		END IF;
	ELSE
		SET rtn_val = 32201;
		SET msg_txt = 'Users deactivation failed';
	END IF;
END