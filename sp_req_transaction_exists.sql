CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_transaction_exists`(
	IN IN_TRANSACTION_ID		BIGINT,					/*입력값 : 찾고자 하는 트랜잭션(폐기물처리작업) 고유등록번호*/
    OUT OUT_TRANSACTION_EXIST	TINYINT					/*출력값 : 트랜잭션이 유효하면 TRUE, 그렇지 않으면 FALSE 반환*/
)
BEGIN

/*
Procedure Name 		: sp_req_transaction_exists
Input param 		: 1개
Output param 		: 1개
Job 				: 현재 트랜잭션(폐기물배출작업)이 존재하면 TRUE, 그렇지 않으면 FALSE 반환
Update 				: 2022.01.25
Version				: 0.0.1
AUTHOR 				: Leo Nam
*/
	
    SELECT COUNT(ID) INTO @CHK_COUNT FROM WSTE_CLCT_TRMT_TRANSACTION WHERE ID = IN_TRANSACTION_ID;
    /*트랜잭션이 존재하는지 검사한다.*/
    IF @CHK_COUNT = 1 THEN
    /*트랜잭션이 존재하는 경우*/
		SET OUT_TRANSACTION_EXIST = TRUE;
    ELSE
    /*트랜잭션이 존재하지 않는 경우*/
		SET OUT_TRANSACTION_EXIST = FALSE;
    END IF;
END