CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_user`(
    IN IN_USER_ID						BIGINT,				/*입력값 : 계정 정보를 삭제하는 사용자 아이디*/
    IN IN_TARGET_USER_ID				BIGINT				/*입력값 : 삭제할 사용자 아이디*/
)
BEGIN

/*
Procedure Name 	: sp_delete_user
Input param 	: 2개
Job 			: 개인정보를 삭제하는 기능
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.29
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    CALL sp_req_current_time(
		@REG_DT
    );
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
    call sp_req_user_validation_by_user_id(
		IN_USER_ID, 
        @rtn_val, 
        @msg_txt
    );
    
    IF @rtn_val > 0 THEN
    /*요청자가 인증되지 않은 사용자인 경우*/
		SIGNAL SQLSTATE '23000';
    ELSE   
    /*요청자가 인증된 사용자인 경우*/ 
		call sp_req_user_validation_by_user_id(
			IN_TARGET_USER_ID, 
            @rtn_val, 
            @msg_txt
        );
        
		IF @rtn_val > 0 THEN
		/*요청자가 인증되지 않은 사용자인 경우*/
			SIGNAL SQLSTATE '23000';
		ELSE  
			CALL sp_req_user_management_rights_by_user_id(
			/*IN_UPDATOR가 IN_TARGET_USER_ID에 대하여 UPDATE할 권한이 있는지 체크한 후 권한이 있다면 TRUE, 권한이 없다면 FALSE를 @permission을 통하여 반환함*/
				IN_USER_ID, 
                IN_TARGET_USER_ID, 
                JOB, 
                @IS_DELETER_ABLE_TO_DELETE
            );
			
			IF @IS_DELETER_ABLE_TO_DELETE = FALSE THEN
			/*요청자(DELETER)가 정보삭제의 권한이 없는 사용자인 경우*/
				SET @rtn_val = 20701;
				SET @msg_txt = 'attempts to delete users who do not have permission to delete';
				SIGNAL SQLSTATE '23000';
			ELSE
				UPDATE USERS 
                SET 
					ACTIVE = FALSE, 
                    UPDATED_AT = @REG_DT 
                WHERE ID = IN_TARGET_USER_ID;
					
				IF ROW_COUNT() = 0 THEN
				/*변경이 적용되지 않은 경우*/
					SET @rtn_val = 20702;
					SET @msg_txt = 'failed to delete from database';
					SIGNAL SQLSTATE '23000';
				ELSE
				/*모든 트랜잭션이 성공한 경우에만 로그를 한다.*/
					SET @rtn_val = 0;
					SET @msg_txt = 'Success';
				END IF;
			END IF;
        END IF;
	END IF;
	COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END