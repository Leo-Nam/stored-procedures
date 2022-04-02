CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_auth_to_delete_company_2`(
    IN DELETER_HEAD_OFFICE				TINYINT,
    IN DELETER_CALSS					INT,
    IN TARGET_COMP_ID					BIGINT,
    OUT OUT_TARGET_SITE_ID				BIGINT,
    OUT OUT_TARGET_SITE_HEAD_OFFICE		TINYINT,
    OUT OUT_COUNT_SITE_USERS			INT,
    OUT rtn_val							INT,
    OUT msg_txt							VARCHAR(200)
)
BEGIN
	IF DELETER_HEAD_OFFICE = TRUE THEN
		IF DELETER_CLASS = 201 THEN
			SELECT COUNT(ID) 
            INTO @COUNT_COMP_SITE 
            FROM COMP_SITE 
            WHERE COMP_ID = TARGET_COMP_ID;
            
            IF @COUNT_COMP_SITE = 1 THEN
				SELECT ID 
                INTO @TARGET_SITE_ID 
                FROM COMP_SITE 
                WHERE COMP_ID = TARGET_COMP_ID;
                SET OUT_TARGET_SITE_ID = @TARGET_SITE_ID ;
                
                SELECT HEAD_OFFICE 
                INTO @TARGET_SITE_HEAD_OFFICE 
                FROM COMP_SITE 
                WHERE ID = @TARGET_SITE_ID;
                
                SET OUT_TARGET_SITE_HEAD_OFFICE = @TARGET_SITE_HEAD_OFFICE ;
                
                IF @TARGET_SITE_HEAD_OFFICE = TRUE THEN
					SELECT COUNT(ID) 
                    INTO @COUNT_SITE_USERS 
                    FROM USERS 
                    WHERE AFFILIATED_SITE = @TARGET_SITE_ID;
					SET OUT_COUNT_SITE_USERS = @COUNT_SITE_USERS ;
                ELSE
					SET rtn_val = 32104;
					SET msg_txt = 'Sites other than the head office cannot be deleted when the company is to be deleted';
                END IF;
            ELSE
				SET rtn_val = 32103;
				SET msg_txt = 'A business has more than one site';
            END IF;	
        ELSE
			SET rtn_val = 32102;
			SET msg_txt = 'The deleter does not have the authority to delete the company';
        END IF;
    ELSE
		SET rtn_val = 32101;
		SET msg_txt = 'Deleter does not belong to head office';
    END IF;
END