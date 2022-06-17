CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_push_to_prospective_bidders`(
	IN IN_ORDER_ID			BIGINT
)
BEGIN

/*
Procedure Name 	: sp_push_to_prospective_bidders
Input param 	: 1개
Output param 	: 1개
Job 			: 무방문신청 종료에 대한 푸시를 반환한다
Update 			: 2022.04.23
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
	DECLARE json_data			JSON DEFAULT NULL;
    DECLARE rtn_val				INT DEFAULT NULL;
    DECLARE msg_txt				VARCHAR(200) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET json_data 		= NULL;
		CALL sp_return_results(rtn_val, msg_txt, json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    CALL sp_push_to_prospective_bidders_without_handler(
		IN_ORDER_ID,
		json_data,
        rtn_val,
        msg_txt
    );
    IF rtn_val > 0 THEN
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(rtn_val, msg_txt, json_data);
END