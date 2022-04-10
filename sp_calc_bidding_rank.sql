CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_bidding_rank`(
	IN IN_DISPOSER_ORDER_ID			BIGINT
)
BEGIN

/*
Procedure Name 	: sp_calc_bidding_rank
Input param 	: 1개
Job 			: 투찰한 업체의 낙찰순위를 일괄 계산한다. 향후 탄소배출량 등을 추가한 계산방식을 적용하는 경우 이 프로시저의 ORDER BY BID_AMOUNT 부분을 수정하면 된다.
Update 			: 2022.03.19
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    CALL sp_req_current_time(@REG_DT);
    
	UPDATE COLLECTOR_BIDDING 
    SET 
		WINNER 			= FALSE, 
		BIDDING_RANK 	= NULL,
        UPDATED_AT		= @REG_DT
    WHERE DISPOSAL_ORDER_ID = IN_DISPOSER_ORDER_ID;
	/*COLLECTOR_BIDDING 전체 레코드에 대해서 BIDDING_RANK를 NULL로 셋팅한다.*/
    
	SET @rank:=0;
	UPDATE COLLECTOR_BIDDING 
	SET 
		BIDDING_RANK			= @rank := @rank+1,
		UPDATED_AT				= @REG_DT
	WHERE 
		BID_AMOUNT 				IS NOT NULL AND
		DISPOSAL_ORDER_ID 		= IN_DISPOSER_ORDER_ID AND 
		DATE_OF_BIDDING			IS NOT NULL AND
		CANCEL_BIDDING 			= FALSE AND
		REJECT_BIDDING 			<> TRUE AND
		REJECT_BIDDING_APPLY	<> TRUE AND
        GIVEUP_BIDDING			<> TRUE AND
		ACTIVE					= TRUE
	ORDER BY BID_AMOUNT ASC;
	/*COLLECTOR_BIDDING 전체 레코드에 대해서 BIDDING_RANK를 다시 계산한다.*/
    
	UPDATE COLLECTOR_BIDDING 
    SET 
		WINNER 				= TRUE, 
        UPDATED_AT 			= @REG_DT 
    WHERE 
		DISPOSAL_ORDER_ID 	= IN_DISPOSER_ORDER_ID AND 
        BIDDING_RANK 		= 1;
	/*COLLECTOR_BIDDINGD 레코드 중에서 BIDDING_RANK가 1인 레코드의 WINNER를 TRUE로 셋팅한다.*/    
    
	SELECT COUNT(ID) INTO @BIDDERS 
	FROM COLLECTOR_BIDDING 
	WHERE 
		BID_AMOUNT 				IS NOT NULL AND
		DISPOSAL_ORDER_ID 		= IN_DISPOSER_ORDER_ID AND 
		DATE_OF_BIDDING			IS NOT NULL AND
		CANCEL_BIDDING 			= FALSE AND
		REJECT_BIDDING 			<> TRUE AND
        REJECT_BIDDING_APPLY	<> TRUE AND
        GIVEUP_BIDDING			<> TRUE AND
        ACTIVE					= TRUE;
        
	UPDATE SITE_WSTE_DISPOSAL_ORDER 
    SET 
		BIDDERS 		= @BIDDERS,
        UPDATED_AT 		= @REG_DT
    WHERE ID = IN_DISPOSER_ORDER_ID;
    
    IF @BIDDERS > 0 THEN
    /*투찰자가 1이상 존재하는 경우*/
		SELECT ID INTO @FIRST_PLACE 
		FROM COLLECTOR_BIDDING 
		WHERE 
			BIDDING_RANK 		= 1 AND 
			DISPOSAL_ORDER_ID 	= IN_DISPOSER_ORDER_ID;
		/*COLLECTOR_BIDDING에서 RANK가 1인 COLLECTOR_BIDDING.ID를 구하여 @FIRST_PLACE에 반환한다.*/
		IF @BIDDERS = 1 THEN
        /*적합투찰자인 BIDDER가 1인 경우*/
			UPDATE SITE_WSTE_DISPOSAL_ORDER 
			SET 
				FIRST_PLACE 	= @FIRST_PLACE, 
				SECOND_PLACE 	= NULL,
                UPDATED_AT		= @REG_DT
			WHERE ID = IN_DISPOSER_ORDER_ID;
			/*SITE_WSTE_DISPOSAL_ORDER에서 FIRST_PLACE에는 @FIRST_PLACE를, SECOND_PLACE에는 NULL을 저장한다.*/
		ELSE
			SELECT ID INTO @SECOND_PLACE 
			FROM COLLECTOR_BIDDING 
			WHERE 
				BIDDING_RANK 		= 2 AND 
				DISPOSAL_ORDER_ID 	= IN_DISPOSER_ORDER_ID;
			/*COLLECTOR_BIDDING에서 RANK가 2인 COLLECTOR_BIDDING.ID를 구하여 @SECOND_PLACE에 반환한다.*/
				
			UPDATE SITE_WSTE_DISPOSAL_ORDER 
			SET 
				FIRST_PLACE 	= @FIRST_PLACE, 
				SECOND_PLACE 	= @SECOND_PLACE,
                UPDATED_AT		= @REG_DT
			WHERE ID = IN_DISPOSER_ORDER_ID;
			/*SITE_WSTE_DISPOSAL_ORDER에서 FIRST_PLACE에는 @FIRST_PLACE를, SECOND_PLACE에는 @SECOND_PLACE를 저장한다.*/
		END IF;
	ELSE
    /*투찰자가 존재하지 않는 경우*/
		UPDATE SITE_WSTE_DISPOSAL_ORDER 
		SET 
			FIRST_PLACE 	= NULL, 
			SECOND_PLACE 	= NULL,
            UPDATED_AT		= @REG_DT
		WHERE ID = IN_DISPOSER_ORDER_ID;
        /*SITE_WSTE_DISPOSAL_ORDER에 등록된 1순위자와 2순위자에 대한 정보를 모두 NULL로 교체한다.*/
    END IF;
    
END