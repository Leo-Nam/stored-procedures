CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_clct_trmt_transaction`(
    IN IN_USER_ID					BIGINT,					/*입력값 : 배출요청을 한 배출업체의 관리자 고유등록번호(USERS.ID)*/
	IN IN_DISPOSER_ORDER_ID			BIGINT,					/*입력값 : SITE_WSTE_DISPOSAL_ORDER.ID*/
	IN IN_VISIT_START_AT			DATETIME,				/*입력값 : 배출자가 요청하는 방문요청일*/
	IN IN_VISIT_END_AT				DATETIME,				/*입력값 : 배출자가 요청하는 방문요청일*/
    IN IN_COLLECT_ASK_END_AT		DATETIME,				/*입력값 : 배출자가 요청하는 수거마감일*/
    OUT rtn_val						INT,					/*출력값 : 처리결과 반환값*/   
    OUT msg_txt 					VARCHAR(200)			/*출력값 : 처리결과 문자열*/ 
)
BEGIN

/*
Procedure Name 	: sp_insert_clct_trmt_transaction
Input param 	: 5개
Output param 	: 2개
Job 			: 폐기물처리작업을 생성한다.
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.02.17
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: VISIT_START_AT 칼럼 추가(0.0.2)
*/

    CALL sp_req_current_time(@REG_DT);
    
	INSERT INTO WSTE_CLCT_TRMT_TRANSACTION (
		DISPOSAL_ORDER_ID,
        ASKER_ID,
        COLLECT_ASK_END_AT,
        VISIT_START_AT,
        VISIT_END_AT,
        CREATED_AT,
        UPDATED_AT
	) VALUES (
		IN_DISPOSER_ORDER_ID,
        IN_USER_ID,
        IN_COLLECT_ASK_END_AT,
        IN_VISIT_START_AT,
        IN_VISIT_END_AT,
        @REG_DT,
        @REG_DT
    );
    
    IF ROW_COUNT() = 1 THEN
    /*레코드 생성에 성공한 경우*/
		SELECT MAX(ID) INTO @TRANSACTION_ID 
        FROM WSTE_CLCT_TRMT_TRANSACTION;
        
		UPDATE SITE_WSTE_DISPOSAL_ORDER
        SET 
			TRANSACTION_ID 	= @TRANSACTION_ID,
            UPDATED_AT 		= @REG_DT
        WHERE ID 			= IN_DISPOSER_ORDER_ID;
        IF ROW_COUNT() = 1 THEN
			SET rtn_val = 0;
			SET msg_txt = 'success';
        ELSE
			SET rtn_val = 25302;
			SET msg_txt = 'faild to update transaction id';
        END IF;
    ELSE
    /*레코드 생성에 실패한 경우 예외처리한다.*/
		SET rtn_val = 25301;
		SET msg_txt = 'User not found or is invalid';
    END IF;
END