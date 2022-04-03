CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_collector_bidding_wste_lists`(
	IN IN_COLLECTOR_BIDDING_ID			BIGINT,
    OUT OUT_WSTE_LIST					JSON
)
BEGIN	

/*
Procedure Name 	: sp_get_collector_bidding_wste_lists
Input param 	: 1개
Job 			: 폐기물 수집업자가 투찰(견적)할 때의 폐기물 리스트를 반환한다. 폐기물 수집업자가 실제로 수거한 폐기물 리스트는 WSTE_CLCT_TRMT_TRANSACTION에서 관리된다. 
Update 			: 2022.04.03
Version			: 0.0.1
AUTHOR 			: Leo Nam
				
*/
        
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'WSTE_NM'			, WSTE_NM, 
            'UNIT'				, UNIT, 
            'UNIT_PRICE'		, UNIT_PRICE, 
            'VOLUME'			, VOLUME, 
            'TRMT_METHOD_NM'	, TRMT_METHOD_NM
		)) 
        INTO OUT_WSTE_LIST 
        FROM V_BIDDING_DETAILS 
        WHERE COLLECTOR_BIDDING_ID = IN_COLLECTOR_BIDDING_ID;
		/*DISPOSAL_ORDER_ID에 등록된 폐기물 종류 중 하나만 불러온다.*/
END