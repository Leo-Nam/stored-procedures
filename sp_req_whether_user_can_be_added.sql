CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_whether_user_can_be_added`(
	IN IN_SITE_ID				BIGINT,				/*사이트를 개설하고자 하는 사업자*/
	IN IN_ACTIVE				TINYINT,			/*사이트의 활성화 상태*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 		: sp_req_whether_user_can_be_added
Input param 		: 2개
Output param 		: 2개
Job 				: 사업자가 치움서비스의 정책제한에 불구하고 사이트가 사용자를 추가할 수 있는지 여부를 반환함
Update 				: 2022.01.29
Version				: 0.0.2
AUTHOR 				: Leo Nam
*/
	
	CALL sp_req_count_of_users(
		IN_SITE_ID,
        IN_ACTIVE,
        @NUMBER_OF_USERS
    );
    
    CALL sp_req_policy_direction(
		'user_registration_limit_per_site', 
        @max_number_of_users
	);
        
    IF CAST(@max_number_of_users AS UNSIGNED) > @NUMBER_OF_USERS THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 28101;
		SET msg_txt = 'Cannot add additional users';
    END IF;
END