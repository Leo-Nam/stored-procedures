CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_policy_direction`(
	IN IN_POLICY 		VARCHAR(255),			/*정책주제*/
	OUT OUT_RESULT 		VARCHAR(255)			/*정책추진방향*/
)
BEGIN

/*
Procedure Name 	: sp_req_policy_direction
Input param 	: 1개
Output param 	: 1개
Job 			: 정책테이블(sys_policy)에서 특정 정책에 대한 방향을 반환함
Update 			: 2022.01.03
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
    CALL sp_req_policy_exists(IN_POLICY, @POLICY_EXISTS);
    /*sys_policy에서 요청받은 정책이 존재하는지 체크한다.*/
    
    IF @POLICY_EXISTS = 0 THEN
    /*요청받은 정책이 존재하지 않는 경우*/
		SET OUT_RESULT = '0';
    ELSE
		SELECT active INTO @var_active FROM sys_policy WHERE policy = IN_POLICY;
		/*sys_policy에서 요청받은 정책에 대한 활성화 상태를 체크한다.*/
		
		IF @var_active = 1 THEN
		/*sys_policy에서 요청받은 정책이 비활성화된 상태인 경우*/
			SET OUT_RESULT = '0';
		ELSE
		/*sys_policy에서 요청받은 정책이 활성화된 상태인 경우*/
			SELECT direction INTO @direction FROM sys_policy WHERE policy = IN_POLICY;
            SET OUT_RESULT = @direction;
			/*sys_policy에서 요청받은 정책방향을 OUT_RESULT를 통하여 반환한다.*/
		END IF;
    END IF;
END