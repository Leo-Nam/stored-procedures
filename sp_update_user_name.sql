CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_user_name`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 작성자의 고유등록번호 (USERS.ID)*/
	IN IN_USER_NAME				VARCHAR(20)			/*입력값 : 사용자 이름*/
)
BEGIN

/*
Procedure Name 	: sp_update_user_name
Input param 	: 2개
Job 			: 사용자 이름 변경
Update 			: 2022.03.15
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
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
		UPDATE USERS SET USER_NAME = IN_USER_NAME WHERE ID = IN_USER_ID;
		IF ROW_COUNT() = 1 THEN
        /*변경에 성공한 경우*/
			SET @rtn_val 		= 0;
			SET @msg_txt 		= 'success';	
			SELECT JSON_ARRAYAGG(JSON_OBJECT(
				'ID', IN_USER_ID,
				'USER_NAME', IN_USER_NAME
			)) INTO @json_data;		
        ELSE
		/*변경에 실패한 경우 예외처리한다*/
			SET @rtn_val 		= 33901;
			SET @msg_txt 		= 'user name update failed';	
			SIGNAL SQLSTATE '23000';
			SELECT JSON_ARRAYAGG(JSON_OBJECT(
				'ID', IN_USER_ID,
				'USER_NAME', USER_NAME
			)) INTO @json_data
            FROM USERS WHERE ID = IN_USER_ID;
		END IF;
    ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SET @json_data = NULL;
		SIGNAL SQLSTATE '23000';
		SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'ID', IN_USER_ID,
			'USER_NAME', NULL
		)) INTO @json_data;
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END