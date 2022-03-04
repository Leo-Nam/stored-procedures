CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_cs_confirm_account_of_site`(
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
Procedure Name 	: sp_cs_confirm_account
Input param 	: 4개
Output param 	: 2개
Job 			: 등록된 사이트에 대한 확인 및 담당자 배정절차 진행
Update 			: 2022.03.04
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
	    
	CALL sp_req_cs_manager_id_of_company(
	/*사이트와 사이트가 속한 사업자에 대한 담당자 배정등의 작업을 */
		IN_SITE_ID,					/*사이트의 고유등록번호*/
		@CS_COMPANY_MANAGER_ID		/*사이트가 소속한 사업자를 관리하는 치움서비스 관리담당자의 고유등록번호*/
	);
	
	IF @CS_COMPANY_MANAGER_ID IS NOT NULL THEN
	/*사이트가 소속한 사업자를 관리하는 치움서비스 관리담당자가 이미 결정되어 있는 경우*/
	/*사이트에 대한 치움서비스 담당관리자를 사이트가 소속하고 있는 사업자의 담당관리자로 결정한다.*/
		UPDATE COMP_SITE 
		SET 
			CS_MANAGER_ID = @CS_COMPANY_MANAGER_ID,
			CONFIRMED = 0,
			/*시스템에 의한 담당자 배정이므로 CONFIRMED는 0으로 셋팅한다.*/
			/*이 부분은 배정된 담당자의 실질 확인 후 담당자가 발생시키는 이벤트(sp_cs_comfirm_account_manually)에 의하여 1로 셋팅될 수 있다.*/
			CONFIRMED_AT = NULL,
			/*CONFIRMED_AT의 값 또한 NULL로 셋팅하게 되지만 담당자의 실질 확인 후 담당자가 발생시키는 이벤트(sp_cs_comfirm_account_manually)에 의하여 날짜가 셋팅될 수 있다.*/
			UPDATED_AT = IN_REG_DT
		WHERE ID = IN_SITE_ID;
		
		IF ROW_COUNT() = 1 THEN
		/*업데이트에 성공한 경우*/
			SET rtn_val = 0;
			SET msg_txt = 'Success';
		ELSE
		/*업데이트에 실패한 경우*/
			SET rtn_val = 21502;
			SET msg_txt = 'Failed to assign contact to site';
		END IF;
	ELSE
	/*사이트가 소속한 사업자를 관리하는 치움서비스 관리담당자가 없는 경우*/
		CALL sp_req_comp_id_of_site(
		/*사이트가 소속한 사업자의 고유 등록번호를 @COMP_ID를 통하여 반환한다.*/
			IN_SITE_ID,				/*사이트의 고유등록번호*/
			@COMP_ID				/*사이트가 소속한 사업자의 고유등록번호*/
		);
		
		CALL sp_req_cs_manager_in_charge(
			@CS_MANAGER_ID
		);
		/*CS_MANAGER 아이디를 @CS_MANAGER_ID을 통하여 반환받는다.*/
		UPDATE COMPANY
		SET 
			CS_MANAGER_ID = @CS_MANAGER_ID,
			CONFIRMED = 0,
			/*시스템에 의한 담당자 배정이므로 CONFIRMED는 0으로 셋팅한다.*/
			/*이 부분은 배정된 담당자의 실질 확인 후 담당자가 발생시키는 이벤트(sp_cs_comfirm_account_manually)에 의하여 1로 셋팅될 수 있다.*/
			CONFIRMED_AT = NULL,
			/*CONFIRMED_AT의 값 또한 NULL로 셋팅하게 되지만 담당자의 실질 확인 후 담당자가 발생시키는 이벤트(sp_cs_comfirm_account_manually)에 의하여 날짜가 셋팅될 수 있다.*/
			UPDATED_AT = IN_REG_DT
		WHERE ID = @COMP_ID;
		
		IF ROW_COUNT() = 0 THEN
		/*업데이트에 실패한 경우*/
			SET rtn_val = 21503;
			SET msg_txt = 'Failed to assign contact to company';
		ELSE
		/*업데이트에 성공한 경우*/
		/*사이트에도 CS 담당 관리자를 배정한다.*/
			UPDATE COMP_SITE
			SET 
				CS_MANAGER_ID = @CS_MANAGER_ID,
				CONFIRMED = 0,
				/*시스템에 의한 담당자 배정이므로 CONFIRMED는 0으로 셋팅한다.*/
				/*이 부분은 배정된 담당자의 실질 확인 후 담당자가 발생시키는 이벤트(sp_cs_comfirm_account_manually)에 의하여 1로 셋팅될 수 있다.*/
				CONFIRMED_AT = NULL,
				/*CONFIRMED_AT의 값 또한 NULL로 셋팅하게 되지만 담당자의 실질 확인 후 담당자가 발생시키는 이벤트(sp_cs_comfirm_account_manually)에 의하여 날짜가 셋팅될 수 있다.*/
				UPDATED_AT = IN_REG_DT
			WHERE ID = IN_SITE_ID;                
		
			IF ROW_COUNT() = 0 THEN
			/*업데이트에 실패한 경우*/
				SET rtn_val = 21504;
				SET msg_txt = 'Failed to assign contact to site';
			ELSE
			/*업데이트에 성공한 경우*/
				SET rtn_val = 0;
				SET msg_txt = 'Success';
			END IF;
		END IF;            
	END IF;
END