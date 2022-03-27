CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_company_without_handler`(
	IN IN_USER_ID			BIGINT,				/*사용자 아이디*/
	IN IN_COMP_ID			BIGINT,				/*사업자의 고유등록번호*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_delete_company_without_handler
Input param 	: 2개
Output param 	: 2개
Job 			: 사업자 등록정보 삭제시 종속 사이트와 종속 사용자 모두 삭제 처리한다.
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.17
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/
    
    CALL sp_req_current_time(@REG_DT);
    
	UPDATE COMPANY 
    SET 
		ACTIVE 			= FALSE, 
        UPDATED_AT 		= @REG_DT, 
        RECOVERY_TAG 	= @REG_DT 
    WHERE ID = IN_COMP_ID;
    /*대상이 되는 사업자의 ACTIVE 상태를 FALSE로 변경해준다.*/
    
	IF ROW_COUNT() = 1 THEN
	/*사업자가 성공적으로 삭제된 경우에는 종속 사이트를 모두 삭제한다.*/
		UPDATE COMP_SITE 
        SET 
			ACTIVE 				= FALSE, 
            UPDATED_AT 			= @REG_DT, 
            RECOVERY_TAG 		= @REG_DT 
		WHERE COMP_ID 			= IN_COMP_ID;
		/*삭제 대상 사업자의 종속 사이트에 대한 모든 정보를 삭제처리한다.*/
		IF ROW_COUNT() = 1 THEN
		/*사이트 삭제가 정상적으로 처리된 경우*/   
			UPDATE USERS 
            SET 
				ACTIVE 			= FALSE, 
                UPDATED_AT 		= @REG_DT, 
                RECOVERY_TAG 	= @REG_DT 
            WHERE BELONG_TO 	= IN_COMP_ID;
			/*삭제 대상 사업자를 모기업으로 하는 모든 종속 사업자에 대한 정보 삭제처리 진행한다.*/
			IF ROW_COUNT() = 0 THEN
			/*사용자가 삭제되지 않은 상태인 경우에는 예외처리함*/
				SET rtn_val = 21803;
				SET msg_txt = 'Failure to delete user information related to the company';
			ELSE
			/*사업자 삭제가 정상적으로 처리된 경우*/  
				SET rtn_val = 0;
				SET msg_txt = 'Success';
			END IF;
		ELSE
		/*사이트가 삭제되지 않은 상태인 경우에는 예외처리함*/
			SET rtn_val = 21802;
			SET msg_txt = 'Deletion Failed for Subsidiaries';
		END IF;
	ELSE
	/*사업자가 삭제되지 않은 상태인 경우에는 예외처리함*/
		SET rtn_val = 21801;
		SET msg_txt = 'Company information has not been deleted';
	END IF;
END