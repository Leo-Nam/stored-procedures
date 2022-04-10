CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_collector_can_ask_visit`(
	IN IN_DISPOSER_ORDER_ID				BIGINT,				/*폐기물 배출내역 고유등록번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
    OUT	OUT_COLLECTOR_CAN_VISIT			TINYINT				/*방문신청가능한 경우 TRUE, 그렇지 않은 경우 FALSE 반환*/,
    OUT rtn_val								INT,
    OUT msg_txt								VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_req_collector_can_ask_visit
Output param 	: 1개
Input param 	: 1개
Job 			: 수집운반업자등이 배출자의 방문예정일 안에 방문신청이 가능한지 검사한다. 
Update 			: 2022.01.19
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    CALL sp_req_current_time(@CURRENT_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
	CALL sp_req_policy_direction('minimum_visit_required', @minimum_required_time);

	SET @time_plue = CONCAT(@minimum_required_time, ':00:00');
	SET @time_new = ADDTIME(@CURRENT_DT, @time_plue);
    
    SELECT VISIT_END_AT INTO @VISIT_END_AT FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = IN_DISPOSER_ORDER_ID;
    /*배출자가 지정한 방문예정일을 구해온다.*/
    
    IF @VISIT_END_AT IS NULL THEN
    /*배출자의 방문예정일이 NULL인 경우로서 배출자가 방문예정일을 정하지 않은 경우*/
		SET OUT_COLLECTOR_CAN_VISIT = FALSE;
		SET rtn_val 				= 31302;
		SET msg_txt 				= 'no scheduled visit date set by the emitter';
    ELSE
    /*배출자의 방문예정일이 NULL이 아닌 경우로서 배출자가 방문예정일을 정하고 있는 경우*/
		IF @VISIT_END_AT >= @time_new THEN
		/*배출자의 방문예정일에 여유가 있는 경우*/
			SET OUT_COLLECTOR_CAN_VISIT = TRUE;
			SET rtn_val 				= 0;
			SET msg_txt 				= 'success';
        ELSE
		/*배출자의 방문예정일에 여유가 없는 경우*/
			SET OUT_COLLECTOR_CAN_VISIT = FALSE;
			SET rtn_val 				= 31301;
			SET msg_txt 				= CONCAT('Request for visit must be made at least ', @minimum_required_time, ' hours in advance');
        END IF;
    END IF;
END