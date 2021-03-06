CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_collector_bidding`(
	IN IN_COLLECTOR_SITE_ID		BIGINT, 
	IN IN_DISPOSER_ORDER_ID		BIGINT, 
	IN IN_ACTIVE				TINYINT, 
	IN IN_DATE_OF_VISIT			DATETIME, 
	IN IN_REG_DT				DATETIME,
    OUT OUT_BIDDING_ID			BIGINT,
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)		/*출력값 : 처리결과 문자열*/

)
BEGIN
    
    SELECT COUNT(ID) INTO @ALREADY_BIDDING 
    FROM COLLECTOR_BIDDING 
    WHERE 
		COLLECTOR_ID 		= IN_COLLECTOR_SITE_ID AND 
        DISPOSAL_ORDER_ID 	= IN_DISPOSER_ORDER_ID AND 
        ACTIVE 				= IN_ACTIVE;
        
    IF @ALREADY_BIDDING = 0 THEN
    /*이미 입찰한 사실이 없는 경우 정상처리한다.*/
		INSERT INTO COLLECTOR_BIDDING (
			COLLECTOR_ID, 
			DISPOSAL_ORDER_ID, 
			ACTIVE, 
			DATE_OF_VISIT, 
			CREATED_AT, 
			UPDATED_AT
		) VALUES (
			IN_COLLECTOR_SITE_ID, 
			IN_DISPOSER_ORDER_ID, 
			IN_ACTIVE, 
			IN_DATE_OF_VISIT, 
			IN_REG_DT, 
			IN_REG_DT
		);
		IF ROW_COUNT() = 1 THEN
		/*정상적으로 입력완료된 경우*/
        /*
			CALL sp_req_collect_bidding_max_id(
				@COLLECTOR_BIDDING_ID
			);
			SET OUT_BIDDING_ID = @COLLECTOR_BIDDING_ID;
		*/
            SELECT LAST_INSERT_ID() INTO OUT_BIDDING_ID;
			INSERT INTO FINAL_BIDDER_MANAGEMENT (
				DISPOSER_ORDER_ID,
				COLLECTOR_BIDDING_ID
			) VALUES (
				IN_DISPOSER_ORDER_ID,
				OUT_BIDDING_ID
			);
            IF ROW_COUNT() = 1 THEN
				SET rtn_val = 0;
				SET msg_txt = 'success';
            ELSE
				SET rtn_val = 25203;
				SET msg_txt = 'Failed to create final bidder management rocord';
            END IF;
		ELSE
		/*정상적으로 입력되지 않은 경우*/
			SET rtn_val = 25201;
			SET msg_txt = 'Failed to create collector_bidding record';
		END IF;
    ELSE
    /*이미 입찰한 사실이 있는 경우 정상처리한다.*/
		SET rtn_val = 25202;
		SET msg_txt = 'already bid';
    END IF;

END