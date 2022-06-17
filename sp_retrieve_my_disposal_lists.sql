CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_my_disposal_lists`(
	IN IN_USER_ID							BIGINT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_my_disposal_lists
Input param 	: 1개
Job 			: 배출자 메인 페이지 로딩시 필요한 자료 반환.
Update 			: 2022.02.17
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/

	DECLARE rtn_val			INT				DEFAULT NULL;
	DECLARE msg_txt			VARCHAR(200)	DEFAULT NULL;
	DECLARE json_data		JSON			DEFAULT NULL;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;				
    /*트랜잭션 시작*/  

	CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
        rtn_val,
        msg_txt
    );
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우 정상처리한다.*/
		CALL sp_req_user_type(
			IN_USER_ID,
            @USER_TYPE
        );
		CALL sp_retrieve_my_disposal_lists_with_json(
			IN_USER_ID,
			@USER_TYPE,
			rtn_val,
			msg_txt,
			json_data
		);
        IF rtn_val > 0 THEN
			SET json_data 		= NULL;
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SET json_data 		= NULL;
		SET rtn_val 		= 28801;
		SET msg_txt 		= 'user not found';
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;   
    
	CALL sp_return_results(rtn_val, msg_txt, json_data);
END