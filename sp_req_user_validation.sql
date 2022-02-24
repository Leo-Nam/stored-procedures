CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_validation`(
    IN IN_USER_REG_ID		VARCHAR(50),		/*입력값 : 사용자 아이디*/
    OUT STATE_CODE 			INT,				/*출력값 : 처리결과 반환값*/
    OUT MSG_TXT 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_validation
Input param 	: 1개
Output param 	: 2개
Job 			: COMPANY테이블과 USERS테이블에 각각 입력 PARAM값을 분리하여 INSERT 하는 작업을 수행(COMMIT)하며 중도에 에러발생시 ROLLBACK처리함
Update 			: 2022.01.03
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	DECLARE REG_ID			BIGINT;				/*사용자의 고유등록번호를 저장할 변수 선언*/
	DECLARE ACTIVE_STAT		TINYINT;			/*사용자계정의 활성화 상태를 저장할 변수 선언*/
    
    /*트랜잭션 이상으로 ROLLBACK을 해야하는 경우 되돌릴 위치(SAVEPOINT)를 정한다.*/
    /*SAVEPOINT는 여러군데 정할 수 있다.*/
    
    SELECT COUNT(ID) INTO @USER_EXISTS FROM USERS WHERE USER_ID = IN_USER_REG_ID;
	/*USER 정보에 대한 수정요청을 한 USER_ID가 존재하는지 체크한다.*/
	/*만일 조건에 맞는 사용자가 존재한다면 @USER_EXISTS값이 1의 값을 가지게 되며 그렇지 않은 경우에는 0의 값을 가지게 된다.*/ 
    
	IF @USER_EXISTS = 0 THEN
	/*USER 정보에 대한 수정요청을 한 USER_ID가 존재하지 않는 경우 예외처리한다.*/
		SET STATE_CODE = 20301;
		SET MSG_TXT = 'user account is not existed';
		/*사용자 레코드 생성이 비정상적인 경우에는 POINT_1로 이동시켜 작업을 ROLLBACK 처리한다.*/
	ELSE  
	/*USER 정보에 대한 수정요청을 한 USER_ID가 존재하는 경우에는 정상처리 진행한다.*/
		SELECT ID, ACTIVE INTO REG_ID, ACTIVE_STAT FROM USERS WHERE USER_ID = IN_USER_REG_ID;
		/*사용자 아이디로 검색된 사용자의 고유등록번호와 계정활성화상태를 REG_ID, VALID_STAT에 각각 저정한다.*/
		
		IF ACTIVE_STAT = FALSE THEN
		/*계정이 비활성화된 상태인 경우에는 예외처리한다.*/
			SET STATE_CODE = 20302;
			SET MSG_TXT = 'user account is not activated';
		ELSE
		/*계정이 활성화된 상태인 경우에는 정상처리한다.*/
			SET STATE_CODE = 0;
			SET MSG_TXT = 'user account is valid';
		END IF;
    END IF;
END