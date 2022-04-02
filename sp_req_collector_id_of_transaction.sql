CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_collector_id_of_transaction`(
	IN IN_TRANSACTION_ID		BIGINT,				/*입력값: 수거단위작업코드(WSTE_CLCT_TRMT_TRANSACTION.ID)*/
    OUT OUT_SITE_ID				BIGINT,				/*출력값 : COMP_SITE.ID*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_collector_id_of_transaction
Input param 	: 1개
Output param 	: 3개
Job 			: 수거단위작업의 수거자 사이트 아이디를 반환한다.
Update 			: 2022.03.24
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT COUNT(ID) INTO @IS_TRANSACTION_EXISTS 
    FROM WSTE_CLCT_TRMT_TRANSACTION WHERE ID = IN_TRANSACTION_ID;
    IF @IS_TRANSACTION_EXISTS = 1 THEN
    /*트랜잭션이 존재하는 경우 정상처리한다.*/
		SELECT B.COLLECTOR_ID INTO OUT_SITE_ID 
		FROM WSTE_CLCT_TRMT_TRANSACTION A 
		LEFT JOIN COLLECTOR_BIDDING B ON A.COLLECTOR_BIDDING_ID = B.ID
		WHERE A.ID = IN_TRANSACTION_ID;
		SET rtn_val 		= 0;
		SET msg_txt 		= 'success';
    ELSE
    /*트랜잭션이 존재하지 않는 경우 예외처리한다.*/
		SET rtn_val 		= 34701;
		SET msg_txt 		= 'transaction not exists';
    END IF;
END