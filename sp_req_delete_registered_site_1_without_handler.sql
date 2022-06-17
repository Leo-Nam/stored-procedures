CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_delete_registered_site_1_without_handler`(
	IN IN_USER_ID					BIGINT,
    IN IN_USER_TYPE					INT,
	IN IN_TARGET_ID					BIGINT,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_req_delete_registered_site
Input param 	: 2개
Job 			: 관심업체로 등록한 사이트를 삭제한다.
Update 			: 2022.05.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
    CALL sp_req_current_time(@REG_DT);
	CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
		rtn_val,
		msg_txt
    );    
    IF rtn_val = 0 THEN
    /*사용자가 유효한 경우에는 정상처리한다.*/
		SELECT CLASS, AFFILIATED_SITE INTO @USER_CLASS, @USER_SITE_ID
        FROM USERS
        WHERE ID = IN_USER_ID;
        IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
        /*관심업체를 삭제하고자 하는 사용자에게 권한이 있는 경우 정상처리한다*/
			IF IN_USER_TYPE = 2 THEN
            /*사용자가 배출자인 경우*/
				SELECT COUNT(ID) INTO @RECORD_EXISTS
                FROM REGISTERED_SITE
                WHERE 
					SITE_ID = @USER_SITE_ID AND
                    TARGET_ID = IN_TARGET_ID AND
                    DELETED_AT IS NULL AND
                    REGISTER_TYPE = 1;
                IF @RECORD_EXISTS = 1 THEN
                /*삭제가능한 레코드가 존재하는 경우 정상처리한다.*/
					UPDATE REGISTERED_SITE
                    SET 
						DELETED_AT = @REG_DT,
						ACTIVE = FALSE,
                        UPDATED_AT = @REG_DT
					WHERE 
						SITE_ID = @USER_SITE_ID AND 
                        TARGET_ID = IN_TARGET_ID AND
						REGISTER_TYPE = 1 AND
                        DELETED_AT IS NULL;
					IF ROW_COUNT() = 1 THEN
                    /*삭제처리에 성공한 경우에는 정상처리한다.*/
						SET rtn_val = 0;
						SET msg_txt = 'success';
                    ELSE
                    /*삭제처리에 실패한 경우에는 예외처리한다.*/
						SET rtn_val = 39605;
						SET msg_txt = 'failed to delete record';
                    END IF;
                ELSE
                /*삭제가능한 레코드가 존재하지 않는 경우 예외처리한다.*/
					SET rtn_val = 39604;
					SET msg_txt = 'record not found';
                END IF;
            ELSE
            /*사용자가 수거자인 경우*/
				SELECT COUNT(ID) INTO @RECORD_EXISTS
                FROM REGISTERED_SITE
                WHERE 
					TARGET_ID = @USER_SITE_ID AND
                    SITE_ID = IN_TARGET_ID AND
                    DELETED2_AT IS NULL AND
                    REGISTER_TYPE = 1;
                IF @RECORD_EXISTS = 1 THEN
                /*삭제가능한 레코드가 존재하는 경우 정상처리한다.*/
					UPDATE REGISTERED_SITE
                    SET 
						DELETED2_AT = @REG_DT,
						ACTIVE = FALSE,
                        UPDATED_AT = @REG_DT
					WHERE 
						TARGET_ID = @USER_SITE_ID AND 
                        SITE_ID = IN_TARGET_ID AND
						REGISTER_TYPE = 1 AND
                        DELETED_AT IS NULL;
					IF ROW_COUNT() = 1 THEN
                    /*삭제처리에 성공한 경우에는 정상처리한다.*/
						SET rtn_val = 0;
						SET msg_txt = 'success';
                    ELSE
                    /*삭제처리에 실패한 경우에는 예외처리한다.*/
						SET rtn_val = 39603;
						SET msg_txt = 'failed to delete record';
                    END IF;
                ELSE
                /*삭제가능한 레코드가 존재하지 않는 경우 예외처리한다.*/
					SET rtn_val = 39602;
					SET msg_txt = 'record not found';
                END IF;
            END IF;
        ELSE
        /*관심업체를 삭제하고자 하는 사용자에게 권한이 없는 경우 예외처리한다*/
			SET rtn_val = 39601;
			SET msg_txt = 'users not authorized';
        END IF;
    END IF;
END