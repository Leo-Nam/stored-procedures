CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_site_permit_info`(
	IN IN_USER_ID 						BIGINT,				/*입력값 : 관리자 고유등록번호*/
	IN IN_SITE_ID 						BIGINT,				/*입력값 : 사업자 고유식별 번호*/
	IN IN_WSTE_LIST						JSON,				/*입력값 : 폐기물 구분 코드(JSON)*/
	IN IN_TRMT_BIZ_CODE					VARCHAR(4),			/*입력값 : 사이트 업종구분*/
	IN IN_PERMIT_REG_CODE				VARCHAR(100),		/*입력값 : 사이트 업종구분*/
	IN In_PERMIT_REG_IMG_PATH			VARCHAR(200)		/*입력값 : 사이트 업종구분*/
    )
BEGIN

/*
Procedure Name 	: sp_update_site_permit_info
Input param 	: 6개
Job 			: 수거자등으로 등록할 사업자의 사이트 정보를 업데이트 처리한다.
Update 			: 2022.02.11
Version			: 0.0.1
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
	
    CALL sp_update_site_permit_info_without_handler(
		IN_USER_ID,
		IN_SITE_ID,
		IN_WSTE_LIST,
		IN_TRMT_BIZ_CODE,
		IN_PERMIT_REG_CODE,
		In_PERMIT_REG_IMG_PATH,
		@rtn_val,
		@msg_txt
    );
    
    IF @rtn_val = 0 THEN
	/*사이트 정보변경에 성공한 경우*/
		SET @rtn_val 		= 0;
		SET @msg_txt 		= 'Success';
    ELSE
	/*사이트 정보변경에 실패한 경우*/
		SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
		SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END