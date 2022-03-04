CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_is_biz_reg_code_duplicate`(
	IN IN_BIZ_REG_CODE		VARCHAR(12)				/*입력값 : 사업자등록번호*/
)
BEGIN

/*
Procedure Name 	: sp_req_is_biz_reg_code_duplicate
Input param 	: 1개
Job 			: INPUT PARAM으로 들어온 사업자등록번호가 중복되었는지 확인한 후 중복되었으면 1, 그렇지 않으면 0을 반환함
Creation		: 2022.01.16
Update 			: 2022.01.30
Version			: 0.0.3
AUTHOR 			: Leo Nam
Change			: 처리결과 코드 및 문자열 반환기능 추가(0.0.2)
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;  
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
	SELECT COUNT(ID)
	INTO @IS_DUPLICATED 
	FROM COMPANY 
	WHERE BIZ_REG_CODE = IN_BIZ_REG_CODE;
    
	IF @IS_DUPLICATED = 1 THEN
		SELECT ID 
        INTO @ID 
        FROM COMPANY 
        WHERE BIZ_REG_CODE = IN_BIZ_REG_CODE;
        
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'ID', @ID,
			'BIZ_REG_CODE', IN_BIZ_REG_CODE
		)) INTO @json_data;
		SET @rtn_val 		= 21601;
		SET @msg_txt 		= 'Business registration code already exists';
	ELSE
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'ID', NULL,
			'BIZ_REG_CODE', IN_BIZ_REG_CODE
		)) INTO @json_data;
		SET @rtn_val 		= 0;
		SET @msg_txt 		= 'Success';
	END IF;
    
    COMMIT;
    CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END