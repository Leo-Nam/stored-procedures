CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_post`(
	IN IN_USER_ID 				BIGINT,				/*입력값 : 관리자아이디(USERS.ID)*/
    IN IN_POST_ID 				BIGINT				/*입력값 : 글 등록번호*/
    )
BEGIN

/*
Procedure Name 	: sp_update_post
Input param 	: 4개
Job 			: POST 삭제
Update 			: 2022.03.14
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
    
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
	CALL sp_req_user_exists_by_id(
		IN_USER_ID, 
		TRUE, 
		@rtn_val, 
		@msg_txt
	);
	
	IF @rtn_val = 0 THEN
	/*사용자가 존재하는 경우에는 정상처리함*/
		CALL sp_req_user_own_post(
			IN_USER_ID, 
			IN_POST_ID, 
			@rtn_val,
			@msg_txt
		);
		IF @rtn_val = 0 THEN
		/*사용자가 포스트에 대한 작성자인 경우 정상처리한다.*/
			UPDATE POSTS 
			SET 
				ACTIVE 				= FALSE
			WHERE ID 				= IN_POST_ID;
			/*변경사항을 적용한다.*/
			
			IF ROW_COUNT() = 0 THEN
			/*저장이 되지 않은 경우에는 예외처리한다.*/
				SET @rtn_val = 33201;
				SET @msg_txt = 'Post has not deleted';
				SIGNAL SQLSTATE '23000';
			ELSE
				SET @rtn_val = 0;
				SET @msg_txt = 'success';
			END IF;
		ELSE
		/*사용자가 포스트에 대한 작성자가 아닌 경우 예외처리한다.*/
			SIGNAL SQLSTATE '23000';
		END IF;
	ELSE
	/*사사용자가 존재하지 않는 경우에는 예외처리함*/
		SIGNAL SQLSTATE '23000';
	END IF;
	COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END