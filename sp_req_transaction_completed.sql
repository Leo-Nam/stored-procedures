CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_transaction_completed`(
	IN IN_TRANSACTION_ID			BIGINT,					/*입력값 : 찾고자 하는 트랜잭션(폐기물처리작업) 고유등록번호*/
    OUT OUT_TRANSACTION_COMPLETED	TINYINT					/*출력값 : 트랜잭션이 완료되었으며 TRUE, 그렇지 않으면 FALSE 반환*/
)
BEGIN

/*
Procedure Name 		: sp_req_transaction_completed
Input param 		: 1개
Output param 		: 1개
Job 				: 트랜잭션이 완료된 트랜잭션이면 TRUE, 진행중이면 FALSE반환
Update 				: 2022.01.25
Version				: 0.0.1
AUTHOR 				: Leo Nam
*/
	
    SELECT CONFIRMED_AT INTO @CONFIRMED_AT FROM WSTE_CLCT_TRMT_TRANSACTION WHERE ID = IN_TRANSACTION_ID;
    /*트랜잭션이 존재하는지 검사한다.*/
    IF @CONFIRMED_AT IS NULL THEN
    /*트랜잭션이 진행중인 경우*/
		SET OUT_TRANSACTION_COMPLETED = FALSE;
    ELSE
    /*트랜잭션이 완료된 경우*/
		SET OUT_TRANSACTION_COMPLETED = TRUE;
    END IF;
END