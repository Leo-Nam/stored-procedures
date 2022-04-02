CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_get_posts`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 게시판 소유자(COMP_SITE.ID)*/
	IN IN_SITE_ID				BIGINT,				/*입력값 : 게시판 소유자(COMP_SITE.ID)*/
	IN IN_CATEGORY				INT				/*입력값 : 게시판 종류(POST_CATEGORY.ID)*/   
/*    IN IN_OFFSET				INT,*/				/*입력값 : 스킵할 아이템의 갯수*/
/*    IN IN_ITEMS					INT	*/				/*입력값 : 폐이지당 반환할 리스트의 개수*/
)
BEGIN
/*
Procedure Name 	: sp_req_get_posts
Input param 	: 5개
Job 			: 게시판 목록을 반환한다.
Update 			: 2022.02.23
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/		
    
    CALL sp_req_get_posts_without_handler(
		IN_SITE_ID,
		IN_CATEGORY,
/*		IN_OFFSET,
		IN_ITEMS,*/
		@rtn_val,
		@msg_txt,
		@json_data
    );
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END