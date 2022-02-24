CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_use_same_phone`(
	IN IN_PHONE			VARCHAR(20),			/*입력값: 체크할 전화번호*/
    IN IN_SITE_ID		BIGINT,					/*입력값: 사용자가 소속될 사업자 고유번호로서 개인회원인 경우에는 0임*/
    IN IN_ACTIVE		TINYINT,				/*입력값: 사용자 활성화된 조건이면 TRUE, 그렇지 않으면 FALSE를 입력한다.*/
    OUT rtn_val 		INT,					/*출력값 : 처리결과 반환값*/
    OUT msg_txt 		VARCHAR(100)			/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_use_same_phone
Input param 	: 3개
Output param 	: 1개
Job 			: 등록하고자 하는 휴대폰번호와 동일한 사용자가 이미 등록되어 있는지 검사
Update 			: 2022.01.15
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: 핸드폰 다중 등록정책의 변경에 대응하도록 수정함(기본 정책 : 다중등록 불가)
*/
    
    CALL sp_req_policy_direction(
		'allow_phone_multiple_registration', 
        @allow_phone_multiple_registration
	);

	IF @allow_phone_multiple_registration = '1' THEN
    /*핸드폰 번호의 다중 등록을 허용하는 경우*/
		IF IN_SITE_ID = 0 THEN
		/*개인회원으로 등록하고자 하는 경우에는 기존에 등록된 사업자회원정보에 동일한 핸드폰 번호가 등록되어 있다 하더라도 개인회원으로 핸드폰이 등록되어 있지 않다면 등록이 가능하도록 한다.*/
			SELECT COUNT(ID) INTO @CHK_COUNT 
			FROM USERS 
			WHERE 
				PHONE = IN_PHONE AND 
				ACTIVE = IN_ACTIVE AND 
				BELONG_TO = IN_SITE_ID;
		ELSE
		/*사업자회원으로 등록하고자 하는 경우에는 기존에 등록된 개인회원정보에 동일한 핸드폰 번호가 등록되어 있다 하더라도 사업자회원으로 핸드폰이 등록되어 있지 않다면 등록이 가능하도록 한다.*/
			SELECT COUNT(ID) INTO @CHK_COUNT 
			FROM USERS 
			WHERE 
				PHONE = IN_PHONE AND 
				ACTIVE = IN_ACTIVE AND 
				BELONG_TO > 0;
		END IF;
    ELSE
    /*핸드폰 번호의 다중 등록을 허용하지 않는 경우*/
		SELECT COUNT(ID) INTO @CHK_COUNT 
		FROM USERS 
		WHERE 
			PHONE = IN_PHONE; /*AND 
			ACTIVE = IN_ACTIVE;*/
    END IF;
    
    IF @CHK_COUNT = 0 THEN
    /*핸드폰 이중등록이 아닌 경우*/
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
    /*핸드폰 이중등록인 경우 예외처리한다.*/   
		SET rtn_val = 25001;
		SET msg_txt = 'Phone number is already registered';
    END IF;
END