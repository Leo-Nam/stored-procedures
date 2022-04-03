CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_collector_wste_lists`(
	IN IN_DISPOSER_ORDER_ID				BIGINT,
	IN IN_TRANSACTION_ID				BIGINT,
    OUT OUT_WSTE_LIST					JSON
)
BEGIN	

/*
Procedure Name 	: sp_get_collector_wste_lists
Input param 	: 2개
Job 			: 폐기물 수집업자가 실제로 수거한 폐기물 리스트를 반환한다. 폐기물 수집업자가 투찰(견적)할 때의 폐기물 리스트는 BIDDING_DETAILS로 관리된다.
Update 			: 2022.04.03
Version			: 0.0.1
AUTHOR 			: Leo Nam
				
*/

	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'WSTE_CODE'			, A.WSTE_CODE, 
			'WSTE_NM'			, B.NAME, 
			'WSTE_APPEARANCE'	, C.KOREAN, 
			'QUANTITY'			, A.WSTE_QUANTITY, 
			'UNIT'				, A.WSTE_UNIT,
			'UPDATED_AT'		, A.CREATED_AT,
            'COLLECT_END_AT'	, A.COLLECT_END_AT
		)
	) 
	INTO OUT_WSTE_LIST 
	FROM WSTE_CLCT_TRMT_TRANSACTION A 
    LEFT JOIN WSTE_CODE B ON A.WSTE_CODE = B.CODE
    LEFT JOIN WSTE_APPEARANCE C ON A.WSTE_APPEARANCE = C.ID
	WHERE 
		A.DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND
        A.ID = IN_TRANSACTION_ID;
END