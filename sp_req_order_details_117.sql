CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_order_details_117`(
	IN IN_ORDER_ID				BIGINT,
    OUT OUT_DETAILS				JSON
)
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS ORDER_DETAILS_117_TEMP (
		VISITORS								INT,
		BIDDERS									INT   
	);        
    
    INSERT INTO ORDER_DETAILS_117_TEMP(
		VISITORS, 
        BIDDERS
    )
    SELECT PROSPECTIVE_VISITORS, BIDDERS
    FROM SITE_WSTE_DISPOSAL_ORDER 
    WHERE ID = IN_ORDER_ID;  
	
	SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'VISITORS'				, VISITORS, 
        'BIDDERS'				, BIDDERS
	)) 
    INTO OUT_DETAILS 
    FROM ORDER_DETAILS_117_TEMP;
	DROP TABLE IF EXISTS ORDER_DETAILS_117_TEMP;
END