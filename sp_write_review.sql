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
		SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = IN_USER_ID;
        IF @USER_SITE_ID = 0 THEN
        /*사용자가 개인이거나 치움관리자인경우*/
			SELECT SELECTED INTO @COLLECTOR_ID FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = IN_DISPOSER_ORDER_ID;
            IF @COLLECTOR_ID IS NOT NULL THEN
				IF @COLLECTOR_ID = IN_SITE_ID THEN
                /*수집업자의 사이트와 현재의 사이트가 동일한 경우 리뷰작성가능*/
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
						SET @rtn_val = 0;
						SET @msg_txt = 'success 001';
					ELSE
					/*공지사항 작성에 실패한 경우 예외처리한다*/
						SIGNAL SQLSTATE '23000';
					END IF;
                ELSE
                /*수집업자의 사이트와 현재의 사이트가 상이한 경우 리뷰작성불가능하며 예외처리한다.*/
					SET @rtn_val = 33805;
					SET @msg_txt = 'Can not write a review for this site';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
				SET @rtn_val = 33804;
				SET @msg_txt = 'Could not write review';
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*사용자가 사업자의 관리자인경우*/
			SELECT USER_CURRENT_TYPE_CODE INTO @USER_CURRENT_TYPE_CODE FROM V_USERS WHERE ID = IN_USER_ID;
            IF @USER_CURRENT_TYPE_CODE = 2 THEN
            /*사용자가 배출자인 경우*/
				SELECT SELECTED INTO @COLLECTOR_ID FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = IN_DISPOSER_ORDER_ID;
                IF @COLLECTOR_ID = IN_SITE_ID THEN
                /*수집업자의 사이트와 현재의 사이트가 동일한 경우 리뷰작성가능*/
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
						SET @rtn_val = 0;
						SET @msg_txt = 'success 002';
					ELSE
					/*공지사항 작성에 실패한 경우 예외처리한다*/
						SIGNAL SQLSTATE '23000';
					END IF;
                ELSE
                /*수집업자의 사이트와 현재의 사이트가 상이한 경우 리뷰작성불가능하며 예외처리한다.*/
					SET @rtn_val = 33803;
					SET @msg_txt = 'Can not write a review for this site';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
				IF @USER_CURRENT_TYPE_CODE = 3 THEN
				/*사용자가 수거자인 경우*/
					SELECT SELECTED INTO @COLLECTOR_ID FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = IN_DISPOSER_ORDER_ID;
                    IF @USER_SITE_ID = @COLLECTOR_ID THEN
                    /*사용자의 사이트가 수거자사이트와 동일한 경우에는 리뷰작성 가능*/
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
							SET @rtn_val = 0;
							SET @msg_txt = 'success 003';
						ELSE
						/*공지사항 작성에 실패한 경우 예외처리한다*/
							SIGNAL SQLSTATE '23000';
						END IF;
                    ELSE
                    /*사용자의 사이트가 수거자사이트와 상이한 경우에는 리뷰작성 불가능하며 예외처리한다.*/
						SET @rtn_val = 33802;
						SET @msg_txt = 'Can1 not write a review for this site';
						SIGNAL SQLSTATE '23000';
                    END IF;
				ELSE
				/*사용자가 현재타입이 결정되지 않은 경우(USER_CURRENT_TYPE_CODE = NULL)*/	
					SELECT CLASS INTO @USER_CLASS FROM USERS WHERE ID = IN_USER_ID;
                    IF @USER_CLASS < 200 THEN
					/*사용자가 치움시스템관리자인 경우에는 리뷰작성가능*/	
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
							SET @rtn_val = 0;
							SET @msg_txt = 'success 004';
						ELSE
						/*공지사항 작성에 실패한 경우 예외처리한다*/
							SIGNAL SQLSTATE '23000';
						END IF;
                    ELSE
					/*사용자가 치움시스템관리자가 아닌 경우에는 예외처리한다*/
						SET @rtn_val = 33801;
						SET @msg_txt = 'The user current type has not been determined';
						SIGNAL SQLSTATE '23000';
                    END IF;
				END IF;
            END IF;
        END IF;
    ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SET @json_data = NULL;
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END