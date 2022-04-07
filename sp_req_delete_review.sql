CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_delete_review`(
	IN IN_USER_ID					BIGINT,
	IN IN_POST_ID					BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_delete_review
Input param 	: 2개
Job 			: 배출자가 리뷰를 삭제한다
Update 			: 2022.04.07
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
    /*사용자가 유효한 경우에는 정상처리한다.*/	
		SELECT COUNT(ID) INTO @POST_EXISTS
        FROM POSTS
        WHERE ID = IN_POST_ID;
        IF @POST_EXISTS = 1 THEN
        /*리뷰가 존재하는 경우 정상처리한다.*/            
            SELECT AFFILIATED_SITE, CLASS INTO @USER_SITE_ID, @USER_CLASS
            FROM USERS
            WHERE ID = IN_USER_ID;
            IF @CREATOR_ID = IN_USER_ID THEN
            /*사용자가 리뷰작성자인 경우*/
				CALL sp_delete_review_without_handler(
					IN_USER_ID,
					IN_POST_ID,
					@rtn_val,
					@msg_txt
				);
				IF @rtn_val > 0 THEN
					SIGNAL SQLSTATE '23000';
				END IF;
            ELSE
            /*사용자가 리뷰작성자가 아닌 경우*/
				SELECT CREATOR_ID
				INTO @CREATOR_ID
				FROM POSTS 
				WHERE ID = IN_POST_ID;
                
				SELECT AFFILIATED_SITE, CLASS 
                INTO @CREATOR_SITE_ID, @CREATOR_CLASS
                FROM USERS
                WHERE ID = @CREATOR_ID;
                IF @CREATOR_SITE_ID = @USER_SITE_ID THEN
                /*사용자가 삭제자와 같은 소속인 경우 정상처리한다.*/
					IF @USER_CLASS > @CREATOR_CLASS THEN
                    /*사용자가 작성자보다 높은 권한을 가진 경우 정상처리한다.*/
						CALL sp_delete_review_without_handler(
							IN_USER_ID,
							IN_POST_ID,
							@rtn_val,
							@msg_txt
						);
						IF @rtn_val > 0 THEN
							SIGNAL SQLSTATE '23000';
						END IF;
                    ELSE
                    /*사용자가 작성자보다 높은 권한을 가지지 않은 경우 예외처리한다.*/
						SET @rtn_val = 36603;
						SET @msg_txt = 'user not autorized';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*사용자가 삭제자와 다른 소속인 경우 예외처리한다.*/
					SET @rtn_val = 36602;
					SET @msg_txt = 'user does not belong to the site of creator';
					SIGNAL SQLSTATE '23000';
                END IF;
            END IF;
        ELSE
        /*리뷰가 존재하지 않는 경우 예외처리한다.*/
			SET @rtn_val = 36601;
			SET @msg_txt = 'No Reivew exists';
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*사용자가 유효하지 않은 경우에는 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END