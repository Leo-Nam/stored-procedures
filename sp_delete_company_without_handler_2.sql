CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_company_without_handler_2`(
    IN IN_COMPANY_ID					BIGINT,				/*입력값 : 삭제할 사업자 아이디*/
    IN IN_REG_DT						DATETIME,			/*입력값 : 실행 시간*/
    OUT rtn_val 						INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 						VARCHAR(200)		/*출력값 : 처리결과 문자열*/
    
)
BEGIN

/*
Procedure Name 	: sp_delete_company_without_handler_2
Input param 	: 2개
Job 			: 사업자를 삭제하는 기능
Update 			: 2022.01.29
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/
    
    SELECT COUNT(ID) INTO @COUNT_OF_DELETED_COMPANY
    FROM COMPANY
    WHERE 
		ACTIVE = FALSE AND
		ID = IN_COMPANY_ID;
	IF @COUNT_OF_DELETED_COMPANY = 0 THEN
    /*사업자가 아직 삭제가 되지 않은 경우 정상처리한다.*/
		UPDATE COMPANY 
		SET 
			ACTIVE 			= FALSE, 
			UPDATED_AT 		= IN_REG_DT 
		WHERE ID 			= IN_COMPANY_ID;
			
		IF ROW_COUNT() = 1 THEN
		/*모든 트랜잭션이 성공한 경우에만 로그를 한다.*/
			SET rtn_val = 0;
			SET msg_txt = 'Success';
		ELSE
		/*변경이 적용되지 않은 경우*/
			SET rtn_val = 37002;
			SET msg_txt = 'Failed to delete company account';
		END IF;
    ELSE
    /*사업자가 이미 삭제된 경우에는 예외처리한다.*/
		SET rtn_val = 37001;
		SET msg_txt = 'company already deleted';
    END IF;
END