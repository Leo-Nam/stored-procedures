CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_userid_by_user_reg_id`(
	IN IN_USER_ID			BIGINT,
	OUT OUT_USER_ID				VARCHAR(50)
)
BEGIN

/*
Procedure Name 	: sp_req_userid_by_user_reg_id
Input param 	: 1개
Output param 	: 1개
Job 			: 사용자의 고유등록번호로 사용자의 아이디를 반환함
				: 조건에 맞는 사용자가 없는 경우 NULL값 반환
Update 			: 2022.01.17
Version			: 0.0.1
AUTHOR 			: Leo Nam
CHANGE			: 
*/
	
	SELECT USER_ID INTO OUT_USER_ID FROM USERS WHERE ID = IN_USER_ID;
END