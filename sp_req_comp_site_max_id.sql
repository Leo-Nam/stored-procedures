CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_comp_site_max_id`(
	OUT OUT_COMP_SITE_MAX_ID		BIGINT
)
BEGIN

/*
Procedure Name 	: sp_req_comp_site_max_id
Output param 	: 1개
Job 			: 등록된 사이트 중에서 가장 큰 고유번호(ID) + 1을 반환한다.
Update 			: 2022.01.13
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT max(ID) into OUT_COMP_SITE_MAX_ID FROM COMP_SITE;			
	/*현재 테이블에서 가장 큰 사용자 고유번호를 구한 후 USER_MAX_ID에 저장한다.*/
	
	IF (OUT_COMP_SITE_MAX_ID IS NULL) THEN
		SET OUT_COMP_SITE_MAX_ID = 1;
		/*사용자 테이블의 저장된 고유번호가 하나도 없는 경우에는 NULL이 반환되므로 MAX_ID를 1로 저장한다.*/
	ELSE
		SET OUT_COMP_SITE_MAX_ID = OUT_COMP_SITE_MAX_ID + 1;
		/*최대값을 구하였다면 그 값에 1을 더하여 등록할 사용자의 고유번호로 정한다.*/
	END IF;
END