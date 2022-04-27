CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_calc_bidding_rank_after_delete_company`(
	IN IN_COMP_ID			BIGINT
)
BEGIN

/*
Procedure Name 	: sp_calc_bidding_rank_after_delete_company
Input param 	: 1개
Job 			: 사업자가 삭제된 후 모든 BIDDING RANK를 계산한다.
Update 			: 2022.04.25
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    DECLARE vRowCount_comp						INT DEFAULT 0;
    DECLARE endOfRow_comp						TINYINT DEFAULT FALSE;    
    DECLARE CUR_SITE_ID							BIGINT; 
    DECLARE COMP_CURSOR		 					CURSOR FOR 
	SELECT ID FROM COMP_SITE WHERE COMP_ID = IN_COMP_ID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow_comp = TRUE;
	
	OPEN COMP_CURSOR;	
	cloop_comp: LOOP
		
		FETCH COMP_CURSOR 
		INTO 
			CUR_SITE_ID;
		
		SET vRowCount_comp = vRowCount_comp + 1;
		IF endOfRow_comp THEN
			LEAVE cloop_comp;
		END IF;
        CALL sp_calc_bidding_rank_after_delete_site(
			CUR_SITE_ID
        );
	END LOOP;   
	CLOSE COMP_CURSOR;
    
END