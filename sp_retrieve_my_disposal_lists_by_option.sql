CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_my_disposal_lists_by_option`(
	IN IN_USER_ID							BIGINT,
	IN IN_STATE_CODE						INT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_my_disposal_lists_by_option
Input param 	: 2개
Job 			: 배출자의 현재 배출중인 작업의 상태별로 리스트 반환
Update 			: 2022.01.23
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

	CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
        @rtn_val,
        @msg_txt
    );
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우 정상처리한다.*/
		CALL sp_req_user_type(
			IN_USER_ID,
            @USER_TYPE
        );
		CALL sp_retrieve_my_disposal_lists_by_option_with_json(
			IN_USER_ID,
			IN_STATE_CODE,
			@USER_TYPE,
			@rtn_val,
			@msg_txt,
			@json_data
		);
        IF @rtn_val > 0 THEN
			SET @json_data 		= NULL;
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SET @json_data 		= NULL;
		SET @rtn_val 		= 28701;
		SET @msg_txt 		= 'user not found';
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;   
    
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END