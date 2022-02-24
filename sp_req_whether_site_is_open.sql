CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_whether_site_is_open`(
	IN IN_COMP_ID				BIGINT,				/*사이트를 개설하고자 하는 사업자*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 		: whether_site_is_open
Input param 		: 1개
Output param 		: 2개
Job 				: 사업자가 치움서비스의 정책제한에 불구하고 추가 사이트를 개설할 수 있는지 여부를 반환함
Update 				: 2022.01.29
Version				: 0.0.2
AUTHOR 				: Leo Nam
*/
	
	CALL sp_req_count_of_sites(
		IN_COMP_ID,
        TRUE,
        @NUMBER_OF_SITES
    );
    
    CALL sp_req_policy_direction(
		'max_number_of_sites', 
        @max_number_of_sites
	);
    
    IF CAST(@max_number_of_sites AS UNSIGNED) > @NUMBER_OF_SITES THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 27801;
		SET msg_txt = 'Cannot open additional sites';
    END IF;
END