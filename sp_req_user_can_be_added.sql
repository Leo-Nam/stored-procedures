CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_can_be_added`(
	IN IN_SITE_ID		BIGINT,			/*사이트 고유등록번호*/
    OUT OUT_RES			TINYINT			/*사용자 추가가 가능한 경우 TRUE, 그렇지 않은 경우 FALSE 반환*/
)
BEGIN

/*
Procedure Name 		: sp_req_user_can_be_added
Input param 		: 1개
Output param 		: 1개
Job 				: 사이트의 관리자가 사이트 운영을 위한 사용자를 추가하는 경우 가능한지 여부를 반환함
Update 				: 2022.01.14
Version				: 0.0.1
AUTHOR 				: Leo Nam
*/
	
	CALL sp_req_count_of_users(
		IN_SITE_ID,
        TRUE,
        @NUMBER_OF_USERS
    );
    
    CALL sp_req_policy_direction(
		'user_registration_limit_per_site', 
        @max_number_of_users
	);
    
    SELECT CAST(@max_number_of_users AS UNSIGNED) > @NUMBER_OF_USERS INTO OUT_RES;
END