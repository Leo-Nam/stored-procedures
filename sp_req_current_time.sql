CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_current_time`(
	OUT OUT_TIME	DATETIME
)
BEGIN

/*
Procedure Name 	: sp_req_current_time
Output param 	: 1개
Job 			: UTC + 09:00 SEOUL/ASIA TIME을 반환한다.
Update 			: 2022.01.03
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SET OUT_TIME = ADDTIME(CURRENT_TIMESTAMP, '00:00');
END