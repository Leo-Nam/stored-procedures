CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_cs_confirm_account`(
	IN IN_USER_ID				BIGINT,								/*사용자 고유등록번호*/
	IN IN_SITE_ID				BIGINT,								/*사이트 고유등록번호*/
	IN IN_CLASS					BIGINT,								/*사용자 권한*/
	IN IN_TYPE					ENUM('user','company','system'),	/*사용자 권한*/
	OUT rtn_val					INT,								/*처리결과코드*/
    OUT msg_txt 				VARCHAR(100)						/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_cs_confirm_account
Input param 	: 4개
Output param 	: 2개
Job 			: 등록된 사용자 및 사이트에 대한 확인 및 담당자 배정절차 진행
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.28
Version			: 0.0.5
AUTHOR 			: Leo Nam
CHANGE			: sp이름을 sp_cs_confirm_user => sp_cs_confirm_account로 변경(0.0.3)
				: user, company 타입의 계정을 분류(0.0.3)
				: user type에 system(치움서비스 관리자) 타입 추가(0.0.4)
*/
	
    CALL sp_req_current_time(
		@REG_DT
    );
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
    IF IN_TYPE = 'user' OR IN_TYPE = 'system' THEN
    /*담당자를 배정해야 하는 대상 type이 user인 일반개인회원이거나 type이 system인 치움서비스 관리자인 경우*/          
        CALL sp_cs_confirm_account_of_person(
			IN_USER_ID,
			IN_SITE_ID,
			IN_CLASS,
			IN_TYPE,
			@REG_DT,
			rtn_val,
			msg_txt
        );
    ELSE
    /*담당자를 배정해야 하는 대상 type이 site인 경우*/        
        CALL sp_cs_confirm_account_of_site(
			IN_USER_ID,
			IN_SITE_ID,
			IN_CLASS,
			IN_TYPE,
			@REG_DT,
			rtn_val,
			msg_txt
        );
    END IF;
END