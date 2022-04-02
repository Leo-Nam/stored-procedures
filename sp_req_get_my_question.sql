CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_get_my_question`(
	IN IN_USER_ID				BIGINT				/*입력값 : 사용자 아이디(USERS.ID)*/
)
BEGIN
/*
Procedure Name 	: sp_req_get_my_question
Input param 	: 1개
Job 			: 사용자가 등록한 문의사항을 모두 반환한다
Update 			: 2022.03.17
Version			: 0.0.2
AUTHOR 			: Leo Nam
Changes			: 조건으로 사용하는 site_id는 삭제함(0.0.2)
*/		
    
    CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
		@rtn_val,
		@msg_txt        
    );
    IF @rtn_val = 0 THEN
		CALL sp_req_get_my_question_without_handler(
			IN_USER_ID,
			@rtn_val,
			@msg_txt,
			@json_data
		);
    END IF;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END