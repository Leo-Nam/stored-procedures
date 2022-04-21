CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_write_review`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 작성자의 고유등록번호 (USERS.ID)*/
	IN IN_CONTENTS				TEXT,				/*입력값 : 내용*/
	IN IN_SITE_ID				BIGINT,				/*입력값 : 게시판 소유자(COMP_SITE.ID)*/
	IN IN_PID					BIGINT,				/*입력값 : 댓글의 경우에는 원글의 번호이며 원글인 경우에는 0*/    
	IN IN_RATING				FLOAT,				/*입력값 : 리뷰작성시 입력되는 평점*/    
	IN IN_DISPOSER_ORDER_ID		BIGINT				/*입력값 : 리뷰를 작성할 입찰등록번호*/    
    /*추후 리뷰작성에 관한 사용자권한을 구분하여야 함. 해당 DISPOSER_ORDER에 관련된 사용자만이 리뷰를 작성할 수 있도록 해야 함*/
)
BEGIN

/*
Procedure Name 	: sp_write_post
Input param 	: 5개
Job 			: 사용자들이 posting을 한다.
Update 			: 2022.02.16
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data = NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
	SET @PUSH_CATEGORY_ID = 27;
	CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
        @rtn_val,
        @msg_txt
    );
    IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우 정상처리한다.*/
		SELECT COUNT(ID) INTO @REPORT_EXISTS
		FROM TRANSACTION_REPORT 
		WHERE 
			DISPOSER_ORDER_ID = IN_DISPOSER_ORDER_ID AND
			COLLECTOR_SITE_ID = IN_SITE_ID;
		IF @REPORT_EXISTS = 1 THEN
		/*리포트가 존재하는 경우 정상처리한다.*/
			SELECT CONFIRMED, DISPOSER_SITE_ID INTO @CONFIRMED, @DISPOSER_SITE_ID
			FROM TRANSACTION_REPORT 
			WHERE 
				DISPOSER_ORDER_ID = IN_DISPOSER_ORDER_ID AND
				COLLECTOR_SITE_ID = IN_SITE_ID;
			IF @CONFIRMED = TRUE THEN
			/*폐기물 처리작업이 완료된 경우에는 정상처리한다.*/  
				SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
				IF @USER_SITE_ID > 0 THEN
				/*사용자가 사업자의 소속인 경우*/
					IF @DISPOSER_SITE_ID = @USER_SITE_ID THEN
					/*사용자가 배출자 소속인 경우 정상처리한다.*/
						SELECT CLASS INTO @USER_CLASS
						FROM USERS
						WHERE ID = IN_USER_ID;
						IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
						/*사용자에게 리뷰를 작성할 권한이 있는 경우 정상처리한다.*/
							CALL sp_write_review_without_handler(
								IN_USER_ID,
								IN_CONTENTS,
								IN_SITE_ID,
								IN_PID,
								IN_RATING,
								IN_DISPOSER_ORDER_ID,
								@rtn_val,
								@msg_txt,
								@json_data
							);
							IF @rtn_val = 0 THEN
								CALL sp_push_disposer_write_review(
									IN_USER_ID,
									IN_DISPOSER_ORDER_ID,
									IN_SITE_ID,
									@PUSH_CATEGORY_ID,
									@json_data,
									@rtn_val,
									@msg_txt
								);
								IF @rtn_val > 0 THEN
									SIGNAL SQLSTATE '23000';
								END IF;
							ELSE
							/*공지사항 작성에 실패한 경우 예외처리한다*/
								SET @rtn_val = 33806;
								SET @msg_txt = 'Failed to write a review';
								SIGNAL SQLSTATE '23000';
							END IF;
						ELSE
						/*사용자에게 리뷰를 작성할 권한이 없는 경우 예외처리한다.*/
							SET @rtn_val = 33806;
							SET @msg_txt = 'user is not authorized to write a review';
							SIGNAL SQLSTATE '23000';
						END IF;
					ELSE
					/*사용자가 배출자 소속이 아닌 경우 예외처리한다.*/
						SET @rtn_val = 33805;
						SET @msg_txt = 'user does not belong to the emitter';
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*사용자가 개인인 경우*/
					SELECT DISPOSER_ID INTO @DISPOSER_ID
                    FROM SITE_WSTE_DISPOSAL_ORDER
                    WHERE ID = IN_DISPOSER_ORDER_ID;
                    IF @DISPOSER_ID = IN_USER_ID THEN
                    /*배출자와 사용자가 동일한 경우 정상처리한다.*/
						CALL sp_write_review_without_handler(
							IN_USER_ID,
							IN_CONTENTS,
							IN_SITE_ID,
							IN_PID,
							IN_RATING,
							IN_DISPOSER_ORDER_ID,
							@rtn_val,
							@msg_txt,
							@json_data
						);
						IF @rtn_val = 0 THEN
							CALL sp_push_disposer_write_review(
								IN_USER_ID,
								IN_DISPOSER_ORDER_ID,
								IN_SITE_ID,
								@PUSH_CATEGORY_ID,
								@json_data,
								@rtn_val,
								@msg_txt
							);
							IF @rtn_val > 0 THEN
								SIGNAL SQLSTATE '23000';
							END IF;
						ELSE
						/*공지사항 작성에 실패한 경우 예외처리한다*/
							SET @rtn_val = 33804;
							SET @msg_txt = 'Failed to write a review';
							SIGNAL SQLSTATE '23000';
						END IF;
                    ELSE
                    /*배출자와 사용자가 동일하지 않은 경우 예외처리한다.*/
						SET @rtn_val = 33803;
						SET @msg_txt = 'user is not the diposer';
						SIGNAL SQLSTATE '23000';
                    END IF;
				END IF;
			ELSE
			/*폐기물 처리작업이 완료되지 않은 경우에는 예외처리한다.*/
				SET @rtn_val = 33802;
				SET @msg_txt = 'transaction does not completed';
				SIGNAL SQLSTATE '23000';
			END IF;
		ELSE
		/*리포트가 존재하지 않는 경우 예외처리한다.*/
			SET @rtn_val = 33801;
			SET @msg_txt = 'transaction report does not exist';
			SIGNAL SQLSTATE '23000';
		END IF;
	ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
    SET @json_data = NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END