CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_clct_trmt_transaction`(
    IN IN_USER_ID					BIGINT,					/*입력값 : 배출요청을 한 배출업체의 관리자 고유등록번호(USERS.ID)*/
	IN IN_DISPOSER_ORDER_ID			BIGINT,					/*입력값 : SITE_WSTE_DISPOSAL_ORDER.ID*/
	IN IN_COLLECTOR_SITE_ID			BIGINT,					/*입력값 : 기존거래로 들어오는 경우에는 값이 있으며 일반 입찰거래인 경우에는 NULL*/
	IN IN_VISIT_START_AT			DATETIME,				/*입력값 : 배출자가 요청하는 방문요청일*/
	IN IN_VISIT_END_AT				DATETIME,				/*입력값 : 배출자가 요청하는 방문요청일*/
    IN IN_COLLECT_ASK_END_AT		DATETIME,				/*입력값 : 배출자가 요청하는 수거마감일*/
    OUT rtn_val						INT,					/*출력값 : 처리결과 반환값*/   
    OUT msg_txt 					VARCHAR(200)			/*출력값 : 처리결과 문자열*/ 
)
BEGIN

/*
Procedure Name 	: sp_insert_clct_trmt_transaction
Input param 	: 6개
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
        COLLECTOR_SITE_ID,
        COLLECT_ASK_END_AT,
        VISIT_START_AT,
        VISIT_END_AT,
        CREATED_AT,
        UPDATED_AT
	) VALUES (
		IN_DISPOSER_ORDER_ID,
        IN_USER_ID,
        IN_COLLECTOR_SITE_ID,
        IN_COLLECT_ASK_END_AT,
        IN_VISIT_START_AT,
        IN_VISIT_END_AT,
        @REG_DT,
        @REG_DT
    );
    
    IF ROW_COUNT() = 1 THEN
    /*레코드 생성에 성공한 경우*/
        SELECT LAST_INSERT_ID() INTO @TRANSACTION_ID;
        IF IN_COLLECTOR_SITE_ID IS NOT NULL THEN
			CALL sp_req_policy_direction(
			/*수거자가 배출자의 최종입찰선정에 응답을 할 수 있는 최대의 시간으로서 배출자의 최종낙찰자선정일로부터의 기간을 반환받는다(단위:시간)*/
				'max_selection_duration',
				@max_selection_duration
			);
			SET @COLLECTOR_MAX_DECISION_AT = ADDTIME(
												@REG_DT, 
												CONCAT(
													CAST(@max_selection_duration AS UNSIGNED), 
													':00:00'
												)
											);
        END IF;
        
		UPDATE SITE_WSTE_DISPOSAL_ORDER
        SET 
			TRANSACTION_ID 				= @TRANSACTION_ID,
            UPDATED_AT 					= @REG_DT,
            COLLECTOR_MAX_DECISION_AT 	= IF(IN_COLLECTOR_SITE_ID IS NOT NULL, @COLLECTOR_MAX_DECISION_AT, COLLECTOR_MAX_DECISION_AT)
            /*기존 거래인 경우에는 위에서 계산한 @COLLECTOR_MAX_DECISION_AT으로 SITE_WSTE_DISPOSAL_ORDER의 COLLECTOR_MAX_DECISION_AT을 변경해준다.*/
        WHERE ID 			= IN_DISPOSER_ORDER_ID;
        IF ROW_COUNT() = 1 THEN
			IF IN_COLLECTOR_SITE_ID IS NOT NULL THEN
            /*기존거래인 경우*/
				UPDATE WSTE_CLCT_TRMT_TRANSACTION
				SET MAX_DECISION_AT = @COLLECTOR_MAX_DECISION_AT
				WHERE ID = @TRANSACTION_ID;
				IF ROW_COUNT() = 1 THEN
					SET rtn_val = 0;
					SET msg_txt = 'success';
				ELSE
					SET rtn_val = 25303;
					SET msg_txt = 'faild to update transaction max decision at';
				END IF;
			ELSE
            /*입찰거래인 경우*/
				SET rtn_val = 0;
				SET msg_txt = 'success';
			END IF;
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