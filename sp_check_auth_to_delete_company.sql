CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_auth_to_delete_company`(
	IN DELETER_ID					BIGINT,
    IN TARGET_COMP_ID				BIGINT,
    OUT OUT_TARGET_COMP_ID			INT,
    OUT OUT_TARGET_SITE_ID			INT,
    OUT OUT_COUNT_SITE_USERS		INT,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN
	CALL sp_req_user_exists_by_id(
    /*삭제자가 존재하며 유효한지 검사한다.*/
		DELETER_ID,
        TRUE,
        @rtn_val,
        @msg_txt
    );
    IF @rtn_val = 0 THEN
    /*삭제자가 존재하며 유효한 경우 정상처리한다.*/
		CALL sp_req_company_exists(
        /*삭제 대상 사업자가 존재하며 유효한지 검사한다*/
			TARGET_COMP_ID,
			TRUE,
			@rtn_val,
			@msg_txt
        );
        IF @rtn_val = 0 THEN
        /*삭제대상 사업자가 존재하며 유효한 경우 정상처리한다*/
			SELECT BELONG_TO, AFFILIATED_SITE, CLASS 
            INTO @DELETER_COMP_ID, @DELETER_HEAD_OFFICE, @DELETER_CLASS
            FROM V_USERS
            WHERE ID = DELETER_ID;
            
            IF TARGET_COMP_ID = @DELETER_COMP_ID THEN
            /*삭제대상 사업자가 삭제자가 소속하고 있는 사업자인 경우 정상처리한다.*/
				CALL sp_check_auth_to_delete_company_2(
					@DELETER_HEAD_OFFICE,
					@DELETER_CALSS,
					TARGET_COMP_ID,
					@TARGET_SITE_ID,
					@TARGET_SITE_HEAD_OFFICE,
					@COUNT_SITE_USERS,
					@rtn_val,
					@msg_txt
                );
                IF @rtn_val = 0 THEN
                /*사업자 삭제가 가능한 경우 정상처리한다.*/
					SET OUT_TARGET_COMP_ID = TARGET_COMP_ID;
					SET OUT_TARGET_SITE_ID = @TARGET_SITE_ID;
					SET OUT_COUNT_SITE_USERS = @COUNT_SITE_USERS;
                ELSE
                /*사업자 삭제가 불가능한 경우 예외처리한다.*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
                END IF;
            ELSE
            /*삭제대상 사업자가 삭제자가 소속하고 있는 사업자가 아닌 경우*/
				SELECT P_COMP_ID 
                INTO @TARGET_COMP_PID 
                FROM COMPANY 
                WHERE ID = TARGET_COMP_ID;
                IF @TARGET_COMP_PID = @DELETER_COMP_ID THEN
					CALL sp_check_auth_to_delete_company_2(
						@DELETER_HEAD_OFFICE,
						@DELETER_CALSS,
						TARGET_COMP_ID,
						@TARGET_SITE_ID,
						@TARGET_SITE_HEAD_OFFICE,
						@COUNT_SITE_USERS,
						@rtn_val,
						@msg_txt
					);
					IF @rtn_val = 0 THEN
					/*사업자 삭제가 가능한 경우 정상처리한다.*/
						SET OUT_TARGET_COMP_ID = TARGET_COMP_ID;
						SET OUT_TARGET_SITE_ID = @TARGET_SITE_ID;
						SET OUT_COUNT_SITE_USERS = @COUNT_SITE_USERS;
					ELSE
					/*사업자 삭제가 불가능한 경우 예외처리한다.*/
						SET rtn_val = @rtn_val;
						SET msg_txt = @msg_txt;
					END IF;
                ELSE
					SET rtn_val = 32001;
					SET msg_txt = 'impossible to delete a business that is not a subsidiary';
                END IF;
            END IF;
        ELSE
        /*삭제대상 사업자가 존재하지 않거나 유효하지 않은 경우 예외처리한다*/
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt;
        END IF;
    ELSE
    /*삭제자가 존재하지 않거나 유효하지 않은 경우 예외처리한다.*/
		SET rtn_val = @rtn_val;
		SET msg_txt = @msg_txt;
    END IF;
END