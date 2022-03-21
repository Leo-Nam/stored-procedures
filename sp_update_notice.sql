CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_notice`(
	IN IN_USER_ID				BIGINT,
    IN IN_NOTICE					TINYINT
)
BEGIN

/*
Procedure Name 	: sp_update_notice
Input param 	: 2개
Job 			: NOTICE 알림 토글
Update 			: 2022.03.14
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    CALL sp_req_current_time(@REG_DT);
    CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
        @rtn_val,
        @msg_txt
    );
    IF @rtn_val = 0 THEN
		CALL sp_req_current_time(@REG_DT);
        SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
        IF  @USER_SITE_ID = 0 THEN
        /*개인 사용자인 경우*/
			UPDATE USERS SET NOTICE_ENABLED = IN_NOTICE AND UPDATED_AT = @REG_DT WHERE ID = IN_USER_ID;
			IF ROW_COUNT() = 1 THEN
				SET @rtn_val 		= 0;
				SET @msg_txt 		= 'success';
				SELECT JSON_ARRAYAGG(JSON_OBJECT(
					'ID', IN_USER_ID,
					'NOTICE_ENABLED', IN_NOTICE
				)) INTO @json_data;
			ELSE
				SELECT JSON_ARRAYAGG(JSON_OBJECT(
					'ID'					, ID, 
					'NOTICE_ENABLED'			, NOTICE_ENABLED
				)) 
				INTO @json_data 
				FROM USERS
                WHERE ID = IN_USER_ID;
				SET @rtn_val 		= 33503;
				SET @msg_txt 		= 'Notice status update failed';
				SIGNAL SQLSTATE '23000';
			END IF;
        ELSE
        /*사업자의 관리자인 경우*/
			SELECT CLASS INTO @USER_CLASS FROM USERS WHERE ID = IN_USER_ID;
            IF @USER_CLASS = 201 THEN
				UPDATE COMP_SITE SET NOTICE_ENABLED = IN_NOTICE AND UPDATED_AT = @REG_DT WHERE ID = @USER_SITE_ID;
                IF ROW_COUNT() = 1 THEN
					SET @rtn_val 		= 0;
					SET @msg_txt 		= 'success';
					SELECT JSON_ARRAYAGG(JSON_OBJECT(
						'SITE_ID', @USER_SITE_ID,
						'NOTICE_ENABLED', IN_NOTICE
					)) INTO @json_data;
                ELSE
					SELECT JSON_ARRAYAGG(JSON_OBJECT(
						'SITE_ID'				, ID, 
						'NOTICE_ENABLED'			, NOTICE_ENABLED
					)) 
					INTO @json_data 
					FROM COMP_SITE
					WHERE ID = @USER_SITE_ID;
					SET @rtn_val 		= 33502;
					SET @msg_txt 		= 'Notice status update failed';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
				SELECT JSON_ARRAYAGG(JSON_OBJECT(
					'SITE_ID', @USER_SITE_ID,
					'NOTICE_ENABLED', IN_NOTICE
				)) INTO @json_data;
				SET @rtn_val 		= 33501;
				SET @msg_txt 		= 'No permission';
				SIGNAL SQLSTATE '23000';
            END IF;
        END IF;
    END IF;
    
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END