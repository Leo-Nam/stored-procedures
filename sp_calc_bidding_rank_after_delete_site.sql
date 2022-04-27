CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_bidding_rank_after_delete_site`(
	IN IN_SITE_ID			BIGINT,
    OUT rtn_val				INT,
    OUT msg_txt				VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_calc_bidding_rank_after_delete_site
Input param 	: 1개
Job 			: 사이트가 삭제된 후 모든 BIDDING RANK를 계산한다.
Update 			: 2022.04.25
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_ORDER_ID						BIGINT; 
    DECLARE CUR_BIDDING_ID						BIGINT; 
    DECLARE CUR_FIRST_RANK_DROP					TINYINT; 
    DECLARE CUR_SECOND_RANK						BIGINT;
    DECLARE SITE_CURSOR		 					CURSOR FOR 
	SELECT 
		A.ID, 
        B.ID,
        IF(C.COLLECT_ASK_END_AT IS NULL AND A.BIDDING_END_AT < NOW() AND B.BIDDING_RANK = 1,
			TRUE,
            FALSE
		),
        A.SECOND_PLACE
    FROM SITE_WSTE_DISPOSAL_ORDER A
    LEFT JOIN COLLECTOR_BIDDING B ON A.ID = B.DISPOSAL_ORDER_ID
    LEFT JOIN WSTE_CLCT_TRMT_TRANSACTION C ON A.ID = C.DISPOSAL_ORDER_ID
	WHERE 
		A.IS_DELETED = FALSE AND
		B.COLLECTOR_ID = IN_SITE_ID AND
		(	
			(
				IF(A.VISIT_END_AT IS NOT NULL,
					A.BIDDING_END_AT >= NOW() AND
					A.VISIT_END_AT < NOW(),
					A.BIDDING_END_AT >= NOW()
				)
			) OR
			(
				C.COLLECT_ASK_END_AT IS NULL AND
                A.BIDDING_END_AT < NOW()
			)
        );
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
    CALL sp_req_current_time(@REG_DT);
	SET rtn_val = 0;
	SET msg_txt = 'success';
	OPEN SITE_CURSOR;	
	cloop: LOOP
		
		FETCH SITE_CURSOR 
		INTO 
			CUR_ORDER_ID,
			CUR_BIDDING_ID,
			CUR_FIRST_RANK_DROP,
			CUR_SECOND_RANK;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
		CALL sp_req_last_bidder_set_bidding_end_date_now_for_cancel(
			CUR_ORDER_ID,
			CUR_BIDDING_ID,
			rtn_val,
			msg_txt
		);
		IF rtn_val = 0 THEN
			IF CUR_FIRST_RANK_DROP = TRUE THEN				/*1순위 예상낙찰자로서 회원탈퇴를 시도하는 경우*/
				SELECT SECOND_PLACE INTO @SECOND_PLACE
                FROM SITE_WSTE_DISPOSAL_ORDER
                WHERE ID = CUR_ORDER_ID;
                
                CALL sp_calc_bidders(
					CUR_ORDER_ID
                );
                
                UPDATE SITE_WSTE_DISPOSAL_ORDER				/*입찰등록정보에 대한 변경절차를 실시한다*/
                SET 
					FIRST_PLACE 	= @SECOND_PLACE,		/*2순위 예상낙찰자를 1순위 예상낙찰자로 변경*/
                    SECOND_PLACE 	= NULL,					/*2순위 예상낙찰자는 NULL로 처리*/
                    BIDDERS 		= BIDDERS - 1,			/*BIDDERS를 1 감소시킨다*/
					UPDATED_AT 		= @REG_DT				/*레코드의 업데이트 일자를 현재로 변경한다*/
				WHERE ID 			= CUR_ORDER_ID;
                IF ROW_COUNT() = 1 THEN						/*입찰결과 정보변경이 성공한 경우*/
					UPDATE COLLECTOR_BIDDING				/*1순위 예상낙찰자에 대한 투찰정보변경절차를 실시한다*/
                    SET 
						WINNER 			= FALSE,			/*회원탈퇴한 사용자의 투찰정보중 WINNER를 FALSE 처리한다*/
                        BIDDING_RANK 	= NULL,				/*낙찰순위를 NULL처리한다*/
                        ACTIVE			= FALSE,			/*투찰정보를 비활성화처리한다*/
                        UPDATED_AT 		= @REG_DT			/*레코드의 업데이트 일자를 현재로 변경한다*/
					WHERE ID = CUR_BIDDING_ID;
                    IF ROW_COUNT() = 1 THEN					/*1순위 예상낙찰자에 대한 투찰결과 정보변경이 성공한 경우*/
						UPDATE COLLECTOR_BIDDING			/*2순위 예상낙찰자에 대한 투찰정보변경절차를 실시한다*/
						SET 
							WINNER = 1,						/*2순위 예상낙찰자를 WINNER처리한다*/
							BIDDING_RANK = 1,				/*2순위 예상낙찰자의 순위를 1순위로 변경처리한다*/
							UPDATED_AT 		= @REG_DT		/*레코드의 업데이트 일자를 현재로 변경한다*/
						WHERE ID = @SECOND_PLACE;
						IF ROW_COUNT() = 0 THEN				/*2순위 예상낙찰자에 대한 투찰결과 정보변경이 실패한 경우*/
							SET rtn_val = 39205;
							SET msg_txt = 'failed to change second rank bidding information';
							LEAVE cloop;
						END IF;
                    ELSE									/*1순위 예상낙찰자에 대한 투찰결과 정보변경이 실패한 경우*/
						SET rtn_val = 39204;
						SET msg_txt = 'failed to change first rank bidding information';
						LEAVE cloop;
                    END IF;
				ELSE										/*입찰결과 정보변경이 실패한 경우*/
					SET rtn_val = 39203;
					SET msg_txt = 'failed to drop first place and change second place to first place';
					LEAVE cloop;
                END IF;
            ELSE											/*1순위가 아닌자로서 회원탈퇴를 시도하는 경우*/
				IF CUR_SECOND_RANK = CUR_BIDDING_ID THEN	/*2순위 예상낙찰자로서 회원탈퇴를 시도하는 경우*/                
					CALL sp_calc_bidders(
						CUR_ORDER_ID
					);
					UPDATE SITE_WSTE_DISPOSAL_ORDER			/*입찰등록정보에 대한 변경절차를 실시한다*/
					SET 
						SECOND_PLACE 	= NULL,				/*2순위 예상낙찰자를 NULL처리한다.*/
						BIDDERS 		= BIDDERS - 1,		/*BIDDERS를 1 감소시킨다*/
                        UPDATED_AT 		= @REG_DT			/*레코드의 업데이트 일자를 현재로 변경한다*/
					WHERE ID 			= CUR_ORDER_ID;
					IF ROW_COUNT() = 1 THEN
						UPDATE COLLECTOR_BIDDING			/*2순위 예상낙찰자에 대한 투찰정보변경절차를 실시한다*/
                        SET
							BIDDING_RANK 	= NULL,			/*낙찰순위를 NULL처리한다*/
							ACTIVE			= FALSE,		/*투찰정보를 비활성화처리한다*/
                            UPDATED_AT 		= @REG_DT		/*레코드의 업데이트 일자를 현재로 변경한다*/
						WHERE ID = CUR_BIDDING_ID;
						IF ROW_COUNT() = 0 THEN
							SET rtn_val = 39202;
							SET msg_txt = 'failed to change second rank bidding information';
							LEAVE cloop;
						END IF;
                    ELSE
						SET rtn_val = 39201;
                        SET msg_txt = 'failed to update second place null';
						LEAVE cloop;
					END IF;
                ELSE										/*1순위, 2순위가 아닌자로서 회원탈퇴를 시도하는 경우*/
					CALL sp_calc_bidding_rank(
						CUR_ORDER_ID
					);
                END IF;
            END IF;
		ELSE
			LEAVE cloop;
		END IF;
	END LOOP;   
	CLOSE SITE_CURSOR;
    
END