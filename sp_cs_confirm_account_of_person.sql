CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_cs_confirm_account_of_person`(
	IN IN_USER_ID				BIGINT,								/*입력값 : 사용자 고유등록번호*/
	IN IN_SITE_ID				BIGINT,								/*입력값 : 사이트 고유등록번호*/
	IN IN_CLASS					BIGINT,								/*입력값 : 사용자 권한*/
	IN IN_TYPE					ENUM('user','company','system'),	/*입력값 : 사용자 권한*/
	IN IN_REG_DT				DATETIME,							/*입력값 : 날짜*/
	OUT rtn_val					INT,								/*출력값 : 처리결과코드*/
    OUT msg_txt 				VARCHAR(100)						/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_cs_confirm_account_of_person
Input param 	: 4개
Output param 	: 2개
Job 			: 등록된 사용자에 대한 확인 및 담당자 배정절차 진행
Update 			: 2022.03.04
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	    
	IF IN_CLASS > 101 AND IN_CLASS < 200 AND IN_SITE_ID = 0 AND IN_TYPE = 'system' THEN
	/*치움시스템 관리자 생성인 경우*/
		SET @CS_MANAGER_ID = 0;
	ELSE
	/*치움시스템 관리자가 아닌 사용자 생성인 경우*/
		CALL sp_req_cs_manager_in_charge(
			@CS_MANAGER_ID
		);
		/*CS 담당자 고유등록번호를 가져온다.*/
	END IF;
	
	UPDATE USERS 
	SET 
		CS_MANAGER_ID = @CS_MANAGER_ID,
		CONFIRMED = 0,
		/*시스템에 의한 담당자 배정이므로 CONFIRMED는 0으로 셋팅한다.*/
		/*이 부분은 배정된 담당자의 실질 확인 후 담당자가 발생시키는 이벤트(sp_cs_comfirm_account_manually)에 의하여 1로 셋팅될 수 있다.*/
		CONFIRMED_AT = NULL,
		/*CONFIRMED_AT의 값 또한 NULL로 셋팅하게 되지만 담당자의 실질 확인 후 담당자가 발생시키는 이벤트(sp_cs_comfirm_account_manually)에 의하여 날짜가 셋팅될 수 있다.*/
		UPDATED_AT = IN_REG_DT
	WHERE ID = IN_USER_ID;
		
	IF ROW_COUNT() = 1 THEN
	/*업데이트에 성공한 경우*/
		SET rtn_val = 0;
		SET msg_txt = 'Success';
	ELSE
	/*업데이트에 실패한 경우*/
		SET rtn_val = 21501;
		SET msg_txt = 'Assignment of contact to individual user failed';
	END IF;
END