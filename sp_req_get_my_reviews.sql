CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_get_my_reviews`(
	IN IN_USER_ID				BIGINT
)
BEGIN
/*
Procedure Name 	: sp_req_get_my_reviews
Input param 	: 1개
Job 			: 사용자가 작성한 리뷰를 반환한다
Update 			: 2022.03.15
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/		
    
    CALL sp_req_get_my_reviews_without_handler(
		IN_USER_ID,
		@rtn_val,
		@msg_txt,
		@json_data
    );
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END