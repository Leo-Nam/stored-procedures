CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_review_without_handler`(
	IN IN_USER_ID					BIGINT,
	IN IN_POST_ID					BIGINT,
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
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

    CALL sp_req_current_time(@REG_DT);
    
	SELECT DELETED
	INTO @DELETED
	FROM POSTS 
	WHERE ID = IN_POST_ID;
    
	IF @DELETED = FALSE THEN
		UPDATE POSTS
		SET 
			DELETED = TRUE,
			DELETED_AT = @REG_DT,
			UPDATED_AT = @REG_DT,
			DELETER_ID = IN_USER_ID
		WHERE ID = IN_POST_ID;
		IF ROW_COUNT() = 1 THEN
		/*삭제가 성공적으로 마무리 된 경우 정상처리한다.*/
			SET rtn_val = 0;
			SET msg_txt = 'success';
		ELSE
		/*삭제가 성공적으로 마무리 되지 않은 경우 예외처리한다.*/
			SET rtn_val = 36502;
			SET msg_txt = 'fail to delete the review';
		END IF;
	ELSE
	/*이전에 이미 삭제한 경우 예외처리한다.*/
		SET @rtn_val = 36501;
		SET @msg_txt = 'Review already deleted';
	END IF;
END