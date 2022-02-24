CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_write_post`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 작성자의 고유등록번호 (USERS.ID)*/
	IN IN_SUBJECT				VARCHAR(255),		/*입력값 : 제목*/
	IN IN_CONTENTS				TEXT,				/*입력값 : 내용*/
	IN IN_SITE_ID				BIGINT,				/*입력값 : 게시판 소유자(COMP_SITE.ID)*/
	IN IN_CATEGORY				INT,				/*입력값 : 게시판 종류(1: 공지사항, 2: 업무게시판, 3: 문의사항, 4: 리뷰)*/    
	IN IN_PID					BIGINT				/*입력값 : 댓글의 경우에는 원글의 번호이며 원글인 경우에는 0*/    
)
BEGIN

/*
Procedure Name 	: sp_write_post
Input param 	: 6개
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
        CALL sp_req_user_class_by_user_reg_id(
			IN_USER_ID,
            @USER_CLASS
        );
        IF IN_CATEGORY = 1 THEN
        /*게시판의 종류가 공지사항인 경우*/
			IF @USER_CLASS = 101 OR @USER_CLASS = 201 THEN
			/*사용자에게 글 작성 권한이 있는 경우 정상처리한다.*/
				CALL sp_req_site_id_of_user_reg_id(
					IN_USER_ID,
					@USER_SITE_ID,
					@rtn_val,
					@msg_txt
				);
                IF @rtn_val = 0 THEN
					IF IN_SITE_ID = @USER_SITE_ID THEN
					/*사용자가 사이트의 소속관리자인 경우 정상처리한다.*/
						CALL sp_insert_post(
							IN_USER_ID,	
							IN_SUBJECT,
							IN_CONTENTS,
							IN_SITE_ID,
							IN_CATEGORY,
							IN_PID,
							@rtn_val,
							@msg_txt,
							@last_insert_id
						);
						IF @rtn_val = 0 THEN
							SELECT JSON_ARRAYAGG(
								JSON_OBJECT(
									'LAST_ID', @last_insert_id
								)
							) 
							INTO @json_data;
						ELSE
						/*posting이 비정상적으로 종료된 경우 예외처리한다.*/
							SET @json_data = NULL;
						END IF;
					ELSE
					/*사용자가 사이트의 소속관리자가 아닌 경우 예외처리한다.*/
						SET @json_data = NULL;
						SET @rtn_val = 30307;
						SET @msg_txt = 'User is not part of the site';
					END IF;
                ELSE
					SET @json_data = NULL;
					SET @rtn_val = 30306;
					SET @msg_txt = 'Site does not exist';
                END IF;
			ELSE
			/*사용자에게 글 작성 권한이 없는 경우 예외처리한다.*/
				SET @json_data = NULL;
				SET @rtn_val = 30305;
				SET @msg_txt = 'User does not have permission to write notices';
			END IF;
        ELSE
        /*게시판의 종류가 공지사항이 아닌 경우*/
			IF IN_CATEGORY = 2 THEN
            /*게시판의 종류가 업무게시판인 경우*/
				CALL sp_req_site_id_of_user_reg_id(
					IN_USER_ID,
					@USER_SITE_ID,
					@rtn_val,
					@msg_txt
				);
                IF @rtn_val = 0 THEN
					IF IN_SITE_ID = @USER_SITE_ID THEN
					/*사용자가 사이트의 소속관리자인 경우 정상처리한다.*/
						CALL sp_insert_post(
							IN_USER_ID,	
							IN_SUBJECT,
							IN_CONTENTS,
							IN_SITE_ID,
							IN_CATEGORY,
							IN_PID,
							@rtn_val,
							@msg_txt,
							@last_insert_id
						);
						IF @rtn_val = 0 THEN
							SELECT JSON_ARRAYAGG(
								JSON_OBJECT(
									'LAST_ID', @last_insert_id
								)
							) 
							INTO @json_data;
						ELSE
						/*posting이 비정상적으로 종료된 경우 예외처리한다.*/
							SET @json_data = NULL;
						END IF;
					ELSE
					/*사용자가 사이트의 소속관리자가 아닌 경우 예외처리한다.*/
						SET @json_data = NULL;
						SET @rtn_val = 30304;
						SET @msg_txt = 'User is not part of the site';
					END IF;
                ELSE
					SET @json_data = NULL;
					SET @rtn_val = 30303;
					SET @msg_txt = 'Site does not exist';
                END IF;
            ELSE
            /*게시판의 종류가 존재하지 않는 경우 예외처리한다.*/
				SET @json_data = NULL;
				SET @rtn_val = 30302;
				SET @msg_txt = 'Bulletin board does not exist';
            END IF;
        END IF;
    ELSE
    /*사용자가 존재하지 않는 경우 예외처리한다.*/
		SET @json_data = NULL;
		SET @rtn_val = 30301;
		SET @msg_txt = 'user not found';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END