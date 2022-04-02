CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_have_bidding_record`(
	IN IN_DISPOSER_ORDER_ID			BIGINT,				/*입력값 : 배출자의 폐기물 배출신청 번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
    OUT rtn_val 					INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_have_bidding_record
Input param 	: 1개
Job 			: 입찰한 내역이 존재하는지 검사한 후 입찰사실이 있다면 0, 그렇지 않으면 예외처리한다.
Update 			: 2022.02.24
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/		

	SELECT COUNT(ID) INTO @COUNT_BIDDING FROM COLLECTOR_BIDDING WHERE DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID AND ACTIVE = TRUE;
    IF @COUNT_BIDDING > 0 THEN
    /*수거자가 입찰한 기록이 존재하는 경우 정상처리한다.*/
		SET rtn_val = 0;
		SET msg_txt = 'success'; 
    ELSE
    /*수거자가 입찰한 기록이 존재하지 않는 경우 예외처리한다.*/
		SET rtn_val = 31301;
		SET msg_txt = 'No bidding record'; 
    END IF;
END