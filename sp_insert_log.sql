CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_log`(
	IN IN_USER_CLASS		VARCHAR(10),
    IN IN_PERFORMER			BIGINT,
    IN IN_DIVISION			VARCHAR(10),
    IN IN_JOB				VARCHAR(100),
    IN IN_REG_DT			DATETIME,
    OUT OUT_PARAM			TINYINT
)
BEGIN	

/*
Procedure Name 	: sp_insert_log
Input param 	: 5개
Output param 	: 1개
Job 			: sys_log에 로그 레코드를 생성한후 성공적으로 생성된 경우에는 1, 그렇지 않은 경우에는 0을 반환한다.
Update 			: 2022.01.17
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: 로깅 정책에 대한 검사를 이 프로시저 안에서 처리한다(0.0.2)
*/

	DECLARE CHK_COUNT INT;
    
	call sp_req_policy_direction(
		'transaction_log', 
		@log_policy
	);
	/*정책상 모든 트랜잭션에 대한 로그가 필요하다고 결정된 경우(sys_policy)에는 sys_log에 트랜잭션에 대한 내용을 로깅한다. - 시작*/ 
	/*db관리정책에 대한 결정은 sys_policy에서 변경할수 있다.*/
	IF @log_policy = '1' THEN
		INSERT INTO sys_log
			(user_class, performer, division, job, occurred_at)
		VALUES
			(IN_USER_CLASS, IN_PERFORMER, IN_DIVISION, IN_JOB, IN_REG_DT);
			
		SELECT COUNT(ID) INTO CHK_COUNT FROM sys_log
		WHERE
			user_class 	= IN_USER_CLASS AND
			performer 	= IN_PERFORMER AND
			division 	= IN_DIVISION AND
			job 		= IN_JOB AND
			occurred_at	= IN_REG_DT;
		IF CHK_COUNT > 0 THEN
			SET OUT_PARAM = 1;
		ELSE
			SET OUT_PARAM = 0;
		END IF;
    ELSE
		SET OUT_PARAM = 0;
    END IF;
    
END