CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_cs_manager_in_charge`(
	OUT MANAGER_ID			BIGINT		/*CS 담당 매니저 고유등록번호*/
)
BEGIN

/*
Procedure Name 	: sp_req_cs_manager_in_charge
Input param 	: 0개
Output param 	: 1개
Job 			: CS의 현재 진행작업 및 개별 업무상황을 고려하여 자동으로 담당자를 선택하여 반환함
				: 추후 알고리즘 개발하여야 함
				: 지금은 USER_ID = 20이 자동 반환되도록 함
Update 			: 2022.01.15
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	SELECT MIN(ID) INTO MANAGER_ID FROM USERS WHERE BELONG_TO = 0 AND ACTIVE = TRUE AND DEPARTMENT = 'CS' AND CLASS = 102;

END