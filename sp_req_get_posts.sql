CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_get_posts`(
	IN IN_SITE_ID				BIGINT,				/*입력값 : 게시판 소유자(COMP_SITE.ID)*/
	IN IN_CATEGORY				INT,				/*입력값 : 게시판 종류(POST_CATEGORY.ID)*/   
	IN IN_PAGE_NO				INT,				/*입력값 : 현재 페이지 번호*/    
    IN IN_OFFSET				INT,				/*입력값 : 스킵할 아이템의 갯수*/
    IN IN_ITEMS					INT					/*입력값 : 폐이지당 반환할 리스트의 개수*/
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

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    CALL sp_req_get_posts_without_handler(
		IN_SITE_ID,
		IN_CATEGORY,
		IN_PAGE_NO,
		IN_OFFSET,
		IN_ITEMS,
		@rtn_val,
		@msg_txt,
		@json_data
    );
    
    IF @rtn_val > 0 THEN
    /*포스팅 리스트가 성공적으로 반환되지 않았을 경우 예외처리한다.*/
		SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END