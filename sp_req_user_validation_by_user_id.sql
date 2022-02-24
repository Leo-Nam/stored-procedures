CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_validation_by_user_id`(
    IN IN_USER_ID			BIGINT,				/*입력값 : 사용자 고유등록번호*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_validation_by_user_id
Input param 	: 1개
Output param 	: 2개
Job 			: 사용자가 유효한지 검사한다.
Update 			: 2022.01.17
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/
    
    SELECT COUNT(ID) INTO @USER_EXISTS FROM USERS WHERE ID = IN_USER_ID;
	/*USER 정보에 대한 수정요청을 한 USER_ID가 존재하는지 체크한다.*/
	/*만일 조건에 맞는 사용자가 존재한다면 @USER_EXISTS값이 1의 값을 가지게 되며 그렇지 않은 경우에는 0의 값을 가지게 된다.*/ 
    
	IF @USER_EXISTS = 0 THEN
	/*USER 정보에 대한 수정요청을 한 USER_ID가 존재하지 않는 경우 예외처리한다.*/
		SET rtn_val = 20301;
		SET msg_txt = 'user account is not existed';
		/*사용자 레코드 생성이 비정상적인 경우에는 POINT_1로 이동시켜 작업을 ROLLBACK 처리한다.*/
	ELSE  
	/*USER 정보에 대한 수정요청을 한 USER_ID가 존재하는 경우에는 정상처리 진행한다.*/
		SELECT ACTIVE INTO @ACTIVE_STAT FROM USERS WHERE ID = IN_USER_ID;
		/*사용자 아이디로 검색된 사용자의 고유등록번호와 계정활성화상태를 REG_ID, VALID_STAT에 각각 저정한다.*/
		
		IF @ACTIVE_STAT = FALSE THEN
		/*계정이 비활성화된 상태인 경우에는 예외처리한다.*/
			SET rtn_val = 20302;
			SET msg_txt = 'user account is not activated';
		ELSE
		/*계정이 활성화된 상태인 경우에는 정상처리한다.*/
			SET rtn_val = 0;
			SET msg_txt = 'user account is valid';
		END IF;
    END IF;
END