CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_phone_number_duplicate`(
	IN IN_PHONE			VARCHAR(20)			/*입력값: 체크할 전화번호*/
)
BEGIN

/*
Procedure Name 	: sp_req_use_same_phone
Input param 	: 3개
Job 			: 등록하고자 하는 휴대폰번호의 이중등록여부 검사(이중등록이 아닌 경우 0 반환)
Update 			: 2022.03.10
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

	SELECT COUNT(ID) INTO @CHK_COUNT 
	FROM USERS 
	WHERE 
		PHONE = IN_PHONE AND 
		ACTIVE = TRUE;
	
    IF @CHK_COUNT = 0 THEN
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'PHONE_NUMBER', NULL
		)) INTO @json_data;
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';
    ELSE
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'PHONE_NUMBER', IN_PHONE
		)) INTO @json_data;
		SET @rtn_val = 32501;
		SET @msg_txt = 'phone number is duplicated';
    END IF;
    
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END