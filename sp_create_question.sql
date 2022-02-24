CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_question`(
	IN IN_PHONE					VARCHAR(45),
    IN IN_EMAIL					VARCHAR(100),
    IN IN_QUEST_CLASS			INT,
    IN IN_CONTENTS				VARCHAR(255)
)
BEGIN

/*
Procedure Name 	: sp_create_question
Input param 	: 4개
Job 			: 문의하기 내용 입력하기
Update 			: 2022.01.27
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.2)
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
	INSERT INTO QUESTIONS (
		PHONE, 
        EMAIL, 
        QUEST_CLASS, 
        CONTENTS
	) 
	VALUES (
		IN_PHONE, 
        IN_EMAIL, 
        IN_QUEST_CLASS, 
        IN_CONTENTS
	);
    
    IF ROW_COUNT() = 1 THEN    
		SET @rtn_val 		= 0;
		SET @msg_txt 		= 'success';
		SET @json_data 		= NULL;
    ELSE
		SET @rtn_val 		= 25501;
		SET @msg_txt 		= 'writing failure';
		SET @json_data 		= NULL;
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END