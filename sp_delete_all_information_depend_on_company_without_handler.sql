CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_all_information_depend_on_company_without_handler`(
	IN IN_COMP_ID					BIGINT,
    OUT rtn_val						INT,				/*출력값 : 처리결과 반환값*/   
    OUT msg_txt 					VARCHAR(200)		/*출력값 : 처리결과 문자열*/ 
)
BEGIN

/*
Procedure Name 	: sp_delete_all_information_depend_on_company_without_handler
Input param 	: 1개
Output param 	: 2개
Job 			: 사업자와 관련된 종속사업자, 사이트, 사용자 모두 삭제하게 됨
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
CHANGE			: 
*/

	DECLARE endOfRow BOOLEAN DEFAULT FALSE;
	DECLARE vRowCount INT DEFAULT 0;
	DECLARE COMP_ID BIGINT;
    
	DECLARE SUBSIDIARY_CURSOR CURSOR FOR 
    /*입력 받은 사업자를 모기업으로 하는 종속사업자의 고유등록번호를 SUBSIDIARY_CURSOR에 등록한다.*/
    SELECT ID 
    FROM COMPANY 
    WHERE 
		P_COMP_ID = IN_COMP_ID AND 
        ACTIVE = TRUE;
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    /*커서가 끝에 도달하면 endOfRow를 TRUE로 셋팅한다.*/
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    SELECT COUNT(ID) INTO @COUNT_OF_CHILD_COMP 
    FROM COMPANY 
    WHERE 
		ID = IN_COMP_ID AND 
        ACTIVE = TRUE;
    /*삭제대상이 되는 레코드의 수를 @COUNT_OF_CHILD_COMP에 저장한다.*/
    
	OPEN SUBSIDIARY_CURSOR;	
	cloop: LOOP
		FETCH SUBSIDIARY_CURSOR INTO COMP_ID;
		SELECT endOfRow;
		UPDATE COMPANY 
        SET 
			ACTIVE = FALSE, 
            UPDATED_AT = @REG_DT, 
            RECOVERY_TAG = @REG_DT 
        WHERE 
			ID = COMP_ID AND 
            ACTIVE = TRUE;
            
        IF ROW_COUNT() = 1 THEN
			SET vRowCount = vRowCount + 1;
        END IF;
        
		IF endOfRow THEN
			IF vRowCount = @COUNT_OF_CHILD_COMP THEN
				SET rtn_val = 0;
				SET msg_txt = 'Success';
            ELSE
				SET rtn_val = 28201;
				SET msg_txt = 'Failed to delete company information';
				SIGNAL SQLSTATE '23000';
            END IF;
			LEAVE cloop;
		END IF;
	END LOOP;   
	CLOSE SUBSIDIARY_CURSOR;
    COMMIT;
END