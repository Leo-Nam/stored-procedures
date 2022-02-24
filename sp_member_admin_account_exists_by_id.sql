CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_member_admin_account_exists_by_id`(
	IN IN_USER_ID		BIGINT,					/*입력값: 사업자의 admin인지 체크할 계정 아이디로서 USERS.ID임*/
    OUT OUT_SITE_ID		BIGINT					/*출력값: 체크한 계정이 사이트의 관리자(admin)계정인 경우 소속한 사업자의 고유등록번호(COMPANY.ID), 만일 IN_USER_ID가 어떠한 사업자의 관리자가 아닌경우에는 O 반환*/
												/*sys.admin은 종속사업자를 생성할 수 없음*/
)
BEGIN

/*
Procedure Name 	: sp_member_admin_account_exists_by_id
Input param 	: 1개
Output param 	: 1개
Job 			: 사용자가 201권한을 가진 관리자의 권한이 있다면 어느 사이트의 관리자인지 반환함. 201권한 관리자가 아니면 0을 반환함
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.17
Version			: 0.0.2
AUTHOR 			: Leo Nam
Changes			: 기존 소속사업자의 고유등록번호를 반환하는 방법에서 소속사이트의 고유등록번호를 반환하는 방식으로 변경(0.0.2)
*/

	SELECT IF(COUNT(ID) = 0, 0, AFFILIATED_SITE) 
    INTO OUT_SITE_ID 
    FROM V_USERS 
    WHERE (ID = IN_USER_ID AND CLASS = 201) ;
END