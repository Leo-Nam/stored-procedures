CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_policy_exists`(
	IN IN_POLICY 		VARCHAR(50),	/*정책주제*/
    OUT OUT_RESULT		TINYINT			/*찾고자 하는 정책이 존재하면 1, 그렇지 않으면 0을 반환함*/
)
BEGIN

/*
Procedure Name 	: sp_req_policy_exists
Input param 	: 1개
Output param 	: 1개
Job 			: 입력 param의 IN_POLICY 정책이 sys_policy에 존재하는지 여부 반환
Update 			: 2022.01.04
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) INTO OUT_RESULT FROM sys_policy WHERE policy = IN_POLICY;
    /*sys_policy에서 요청받은 정책이 존재하는지 체크한다.*/
END