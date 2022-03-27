CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_post`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 작성자의 고유등록번호 (USERS.ID)*/
	IN IN_SUBJECT				VARCHAR(255),		/*입력값 : 제목*/
	IN IN_CONTENTS				TEXT,				/*입력값 : 내용*/
	IN IN_SITE_ID				BIGINT,				/*입력값 : 게시판 소유자(COMP_SITE.ID)*/
	IN IN_CATEGORY				INT,				/*입력값 : 게시판 종류(1: 공지사항, 2: 업무게시판)*/
	IN IN_SUB_CATEGORY			INT,				/*입력값 : 서브카테고리가 있는 경우 사용(현재는 문의사항에만 존재)*/    
	IN IN_PID					BIGINT,				/*입력값 : 댓글의 경우 원글의 등록번호, 원글인 경우에는 0*/
    IN IN_RATING				FLOAT,				/*입력값 : 리뷰작성시 입력되는 평점*/   
	IN IN_DISPOSER_ORDER_ID		BIGINT,				/*입력값 : 리뷰를 작성할 입찰등록번호*/     
	IN IN_PHONE					VARCHAR(20),		/*입력값 : 전화번호*/
	IN IN_EMAIL					VARCHAR(50),		/*입력값 : 이메일*/ 
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(100),		/*출력값 : 처리결과 문자열*/
    OUT last_insert_id			VARCHAR(100)		/*출력값 : 최종 입력 등록번호*/
)
BEGIN
    CALL sp_req_current_time(@REG_DT);
    
	INSERT INTO POSTS(
		SITE_ID,
		CREATOR_ID,
		SUBJECTS,
		CONTENTS,
		CATEGORY,
		SUB_CATEGORY,
		PID,
		RATING,
		DISPOSER_ORDER_ID,
		PHONE,
		EMAIL,
		CREATED_AT,
		UPDATED_AT
	) VALUES (
		IN_SITE_ID,
		IN_USER_ID,
		IN_SUBJECT,
		IN_CONTENTS,
		IN_CATEGORY,
		IN_SUB_CATEGORY,
		IN_PID,
		IN_RATING,
		IN_DISPOSER_ORDER_ID,
		IN_PHONE,
		IN_EMAIL,
		@REG_DT,
		@REG_DT
	);
	IF ROW_COUNT() = 1 THEN
	/*글작성이 정상적으로 종료된 경우 정상처리한다.*/
		IF IN_USER_ID IS NOT NULL THEN
			CALL sp_req_user_class_by_user_reg_id(
				IN_USER_ID,
				@USER_CLASS
			);
			
			IF IN_CATEGORY = 3 AND @USER_CLASS < 200 AND IN_PID > 0 THEN
				UPDATE POSTS 
                SET 
					STATUS 		= TRUE,
                    UPDATED_AT 	= @REG_DT
                WHERE ID 		= IN_PID;
                
				IF ROW_COUNT() = 1 THEN
					SET rtn_val = 0;
					SET msg_txt = 'Success';
					SET last_insert_id = LAST_INSERT_ID();
				ELSE
					SET rtn_val = 30402;
					SET msg_txt = 'Failed to complete answer';
					SET last_insert_id = NULL;
				END IF;
			ELSE
				SET rtn_val = 0;
				SET msg_txt = 'Success';
				SET last_insert_id = LAST_INSERT_ID();
			END IF;
		ELSE
			IF IN_PID > 0 THEN
				SET rtn_val = 30403;
				SET msg_txt = 'Comment writing is a member-only service';
            ELSE
				SET rtn_val = 0;
				SET msg_txt = 'Success';
				SET last_insert_id = LAST_INSERT_ID();
            END IF;
        END IF;
	ELSE
	/*글작성이 정상적으로 종료되지 않은 경우 예외처리한다.*/
		SET rtn_val = 30401;
		SET msg_txt = 'Failed to write post';
        SET last_insert_id = NULL;
	END IF;
END