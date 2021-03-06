CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_transaction_wste_lists`(
	IN IN_TRANSACTION_ID				BIGINT,
    OUT OUT_TRANSACTION_WSTE_LIST			JSON
)
BEGIN
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'WSTE_CODE'					, A.WSTE_CODE,
		'WSTE_NM'					, B.NAME,
		'WSTE_QUANTITY'				, A.WSTE_QUANTITY,
		'WSTE_UNIT'					, A.WSTE_UNIT,
		'TRMT_METHOD_CODE'			, A.TRMT_METHOD_CODE,
		'TRMT_METHOD_NM'			, C.NAME
	)) 
	INTO OUT_TRANSACTION_WSTE_LIST
	FROM WSTE_CLCT_TRMT_TRANSACTION A
    LEFT JOIN WSTE_CODE B ON A.WSTE_CODE = B.CODE
    LEFT JOIN WSTE_TRMT_METHOD C ON A.TRMT_METHOD_CODE = C.CODE
    WHERE A.ID = IN_TRANSACTION_ID; 

END