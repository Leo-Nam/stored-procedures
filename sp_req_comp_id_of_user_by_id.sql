CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_comp_id_of_user_by_id`(
	IN IN_USER_ID		BIGINT,
	OUT OUT_BELONG_TO		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_comp_id_of_user_by_id
Input param 	: 1개
Output param 	: 1개
Job 			: 사용자 고유등록번호로 사용자의 소속 사업자의 고유등록번호 반환
Update 			: 2022.01.17
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT BELONG_TO INTO OUT_BELONG_TO FROM USERS WHERE ID = IN_USER_ID;
END