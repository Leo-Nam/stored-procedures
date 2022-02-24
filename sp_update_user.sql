CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_update_user`(
    IN IN_USER_REG_ID					VARCHAR(100),		/*입력값 : 계정 정보를 업데이트 하는 사용자 JWT*/
    IN IN_TARGET_USER_REG_ID			VARCHAR(50),		/*입력값 : 변경할 사용자 아이디*/
    IN IN_PWD							VARCHAR(100),		/*입력값 : 변경할 사용자 암호*/
    IN IN_USER_NAME						VARCHAR(20),		/*입력값 : 변경할 사용자 이름*/
    IN IN_PHONE							VARCHAR(20),		/*입력값 : 변경할 사용자 등록 전화번호*/
    IN IN_BELONG_TO						BIGINT,				/*입력값 : 변경할 사용자 소속 사업자로서 어떤 사업자에도 소속되어 있지 않은 개인인 경우에는 0이며 특정 사업자에게 소속된 관리자인 사용자의 경우에는 소속 사업자의 고유번호(COMPANY.ID)가 등록됨*/
    IN IN_ACTIVE						TINYINT,			/*입력값 : 변경할 사용자의 계정 활성화 상태로서 TRUE인 경우에는 계정이 활성화 된 것이며 FALSE인 경우에는 비활성화인 상태로서 계정활성화 이후 트랜잭션이 가능함*/
    IN IN_CLASS							INT					/*입력값 : 변경할 사용자의 권한을 구분하는 클래스로서 USERS_CLASS.ID 값을 참조함*/
)
BEGIN

/*
Procedure Name 	: sp_update_user
Input param 	: 8개
Job 			: 개인회원이 본인의 정보를 수정하는 경우에는 본인의 암호(PWD), 이름(USER_NAME), 전화번호(PHONE)를 수정할 수 있음
				: 사업자의 super user(member.admin:201)가 하부 조직에 편성된 사용자에 대한 정보를 수정하는 경우에는 소속사업자 고유번호(BELONG_TO), ACTIVE(활성여부), CLASS(권한등급)을 수정할 수 있음
				: 업데이트가 발생하는 경우에는 LOG정책에 따라 로그처리됨
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.30
Version			: 0.0.4
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
    call sp_req_usr_validation(IN_USER_REG_ID, @rtn_val, @msg_txt);
    IF @state_code > 0 THEN
    /*정보변경을 요청하는 사용자가 인증되지 않은 사용자인 경우*/
		SIGNAL SQLSTATE '23000';
    ELSE   
    /*정보변경을 요청하는 사용자가 인증된 사용자인 경우*/ 
		CALL sp_req_user_management_rights(IN_USER_REG_ID, IN_TARGET_USER_REG_ID, JOB, @IS_UPDATOR_ABLE_TO_UPDATE);
		/*IN_USER_REG_ID가 IN_TARGET_USER_REG_ID에 대하여 UPDATE할 권한이 있는지 체크한 후 권한이 있다면 TRUE, 권한이 없다면 FALSE를 @permission을 통하여 반환함*/
		
		IF @IS_UPDATOR_ABLE_TO_UPDATE = FALSE THEN
		/*정보변경을 시도하는 사용자(UPDATOR)가 정보변경의 권한이 없는 사용자인 경우*/
			SIGNAL SQLSTATE '23000';
		ELSE
		/*정보변경을 시도하는 사용자(UPDATOR)가 정보변경의 권한이 있는 사용자인 경우*/
		/*sys.admin(@permission = 1) : 모든 사용자의 정보에 대한 변경권한을 가짐*/
		/*모회사관리자(@permission = 2) : 모회사를 비롯한 하위조직에 대한 모든 사용자의 정보에 대한 변경권한을 가짐*/
		/*사업자관리자(@permission = 3) : 사업자관리자가 속한 모든 사용자의 정보에 대한 변경권한을 가짐*/
			
			call sp_get_user(IN_TARGET_USER_REG_ID, @REG_ID, @PWD, @USER_NAME, @PHONE, @BELONG_TO, @ACTIVE, @CLASS, @CLASS_NM);
			/*변경전 사용자 정보를 불러온다.*/
			
			IF IN_USER_REG_ID <> IN_TARGET_USER_REG_ID THEN
			/*사용자 정보를 수정하는 사용자가 본인의 정보를 수정하지 않는 경우*/   
				UPDATE USERS SET BELONG_TO = IN_BELONG_TO, ACTIVE = IN_ACTIVE, CLASS = IN_CLASS, UPDATED_AT = @REG_DT WHERE JWT = IN_TARGET_USER_REG_ID;
				/*사업자의 super user(member.admin:201)가 다른 사용자의 정보를 변경하는 경우에는 소속사업자와 활성여부, 권한만 변경할 수 있다.*/
				SELECT 
					COUNT(ID) INTO @CHK_COUNT 
				FROM USERS 
				WHERE 
					JWT		 	= IN_TARGET_USER_REG_ID AND 
					BELONG_TO 	= IN_BELONG_TO AND 
					ACTIVE 		= IN_ACTIVE AND 
					CLASS 		= IN_CLASS;
					
				IF @CHK_COUNT = 0 THEN
				/*변경이 적용되지 않은 경우*/
					SET @rtn_val = 20502;
					SET @msg_txt = 'failed to apply database changes';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사용자 정보를 수정하는 사용자가 본인의 정보를 수정하는 경우*/
				UPDATE USERS SET PWD = IN_PWD, USER_NAME = IN_USER_NAME, PHONE = IN_PHONE, UPDATED_AT = @REG_DT WHERE JWT = IN_TARGET_USER_REG_ID;
				/*사용자가 본인의 정보를 수정하는 경우에는 암호와 본인이름, 핸드폰번호만 변경할 수 있다.*/
				SELECT 
					COUNT(ID) INTO @CHK_COUNT 
				FROM USERS 
				WHERE 
					JWT		 	= IN_TARGET_USER_REG_ID AND 
					PWD 		= IN_PWD AND 
					USER_NAME	= IN_USER_NAME AND 
					PHONE 		= IN_PHONE;
					
				IF @CHK_COUNT = 0 THEN
				/*변경이 적용되지 않은 경우*/
					SET @rtn_val = 20505;
					SET @msg_txt = 'member information updated fail';
					SIGNAL SQLSTATE '23000';
				END IF;
			END IF;
		END IF;
	END IF;
	COMMIT;
    
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END