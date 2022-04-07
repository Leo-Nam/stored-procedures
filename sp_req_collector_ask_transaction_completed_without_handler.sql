CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_collector_ask_transaction_completed_without_handler`(
	IN IN_USER_ID					BIGINT,								/*입렦값 : 폐기물 처리보고서 작성자(USERS.ID)*/
	IN IN_TRANSACTION_ID			BIGINT,								/*입렦값 : 폐기물 처리작업 코드(WSTE_CLCT_TRMT_TRANSACTION.ID)*/
	IN IN_WSTE_CODE					VARCHAR(8),							/*입렦값 : 폐기물코드(WSTE_CODE.CODE)*/
	IN IN_QUANTITY					FLOAT,								/*입렦값 : 폐기물수량*/
	IN IN_COMPLETED_AT				DATETIME,							/*입렦값 : 폐기물 최종처리일자*/
	IN IN_PRICE						INT,								/*입렦값 : 폐기물 처리가격*/
	IN IN_UNIT						ENUM('Kg','m3','식','전체견적가'),		/*입렦값 : 폐기물 처리단위*/
	IN IN_TRMT_METHOD				VARCHAR(4),							/*입렦값 : 폐기물 처리방법(WSTE_TRMT_METHOD.CODE)*/
	IN IN_IMG_LIST					JSON,								/*입렦값 : 폐기물 처리사진*/
	IN IN_REG_DT					DATETIME,							/*입렦값 : 현재시간*/
	IN IN_COLLECTOR_SITE_ID			BIGINT,								/*입렦값 : 수거자 사이트 아이디*/
	IN IN_DISPOSER_SITE_ID			BIGINT,								/*입렦값 : 배출자 사이트 아이디*/
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_req_collector_ask_transaction_completed_without_handler
Input param 	: 12개
Job 			: 폐기물처리보고서를 작성한다
Update 			: 2022.04.07
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	INSERT INTO TRANSACTION_REPORT (
		TRANSACTION_ID,
		COLLECTOR_SITE_ID,
		DISPOSER_SITE_ID,
		COLLECTOR_MANAGER_ID,
		TRANSACTION_COMPLETED_AT,
		QUANTITY,
		UNIT,
		PRICE,
		WSTE_CODE,
		CREATED_AT,
		UPDATED_AT,
		DISPOSER_ORDER_ID,
		TRMT_METHOD
	) VALUES (
		IN_TRANSACTION_ID,
		IN_COLLECTOR_SITE_ID,
		IN_DISPOSER_SITE_ID,
		IN_USER_ID,
		IN_COMPLETED_AT,
		IN_QUANTITY,
		IN_UNIT,
		IN_PRICE,
		IN_WSTE_CODE,
		IN_REG_DT,
		IN_REG_DT,
		@DISPOSER_ORDER_ID,
		IN_TRMT_METHOD
	);
	IF ROW_COUNT() = 1 THEN   
		SET @rtn_val = 0;
		SET @msg_txt = 'success';
	ELSE
		SET @rtn_val = 36701;
		SET @msg_txt = 'Failed to change database record';
	END IF;
END