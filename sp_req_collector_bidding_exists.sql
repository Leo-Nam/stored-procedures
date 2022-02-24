CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_collector_bidding_exists`(
	IN IN_COLLECTOR_BIDDING_ID				BIGINT,					/*찾고자 하는 COLLECTOR_BIDDING 고유등록번호*/
    IN IN_ACTIVE							TINYINT,				/*찾고자 하는 COLLECTOR_BIDDING의 활성화 상태, TRUE:활성화, FALSE:비활성화*/
    OUT rtn_val 							INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 							VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 		: sp_req_collector_bidding_exists
Input param 		: 2개
Output param 		: 1개
Job 				: COLLECTOR_BIDDING이 존재하는지 검사한다.
Update 				: 2022.01.25
Version				: 0.0.1
AUTHOR 				: Leo Nam
*/
	
	IF IN_ACTIVE IS NULL THEN
		SELECT COUNT(ID) INTO @CHK_COUNT FROM COLLECTOR_BIDDING WHERE ID = IN_COLLECTOR_BIDDING_ID;
	ELSE
		SELECT COUNT(ID) INTO @CHK_COUNT FROM COLLECTOR_BIDDING WHERE ID = IN_COLLECTOR_BIDDING_ID AND ACTIVE = IN_ACTIVE;
	END IF;
    
    IF @CHK_COUNT = 1 THEN
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    ELSE
		SET rtn_val = 28001;
		SET msg_txt = 'Collector has no bidding information';
    END IF;
END