CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_order_details_122`(
	IN IN_ORDER_ID				BIGINT,
    OUT OUT_DETAILS				JSON
)
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS ORDER_DETAILS_122_TEMP (
		TRANSACTION_ID								INT,
		REJECT_REASON								VARCHAR(255)   
	);        
    
    INSERT INTO ORDER_DETAILS_122_TEMP(
		TRANSACTION_ID, 
        REJECT_REASON
    )
    SELECT ID, REJECT_REASON
    FROM WSTE_CLCT_TRMT_TRANSACTION 
    WHERE DISPOSAL_ORDER_ID = IN_ORDER_ID;  
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'TRANSACTION_ID'				, TRANSACTION_ID, 
        'REJECT_REASON'					, REJECT_REASON
	)) 
    INTO OUT_DETAILS 
    FROM ORDER_DETAILS_122_TEMP;
	DROP TABLE IF EXISTS ORDER_DETAILS_122_TEMP;
END