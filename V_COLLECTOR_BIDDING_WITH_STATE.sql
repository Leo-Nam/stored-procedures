CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_COLLECTOR_BIDDING_WITH_STATE` AS
    SELECT 
        `chiumdev_2`.`A`.`COLLECTOR_BIDDING_ID` AS `COLLECTOR_BIDDING_ID`,
        `chiumdev_2`.`A`.`COLLECTOR_SITE_ID` AS `COLLECTOR_SITE_ID`,
        `chiumdev_2`.`A`.`COLLECTOR_SI_DO` AS `COLLECTOR_SI_DO`,
        `chiumdev_2`.`A`.`COLLECTOR_SI_GUN_GU` AS `COLLECTOR_SI_GUN_GU`,
        `chiumdev_2`.`A`.`COLLECTOR_EUP_MYEON_DONG` AS `COLLECTOR_EUP_MYEON_DONG`,
        `chiumdev_2`.`A`.`COLLECTOR_DONG_RI` AS `COLLECTOR_DONG_RI`,
        `chiumdev_2`.`A`.`COLLECTOR_KIKCD_B_CODE` AS `COLLECTOR_KIKCD_B_CODE`,
        `chiumdev_2`.`A`.`COLLECTOR_ADDR` AS `COLLECTOR_ADDR`,
        `chiumdev_2`.`A`.`COLLECTOR_CONTACT` AS `COLLECTOR_CONTACT`,
        `chiumdev_2`.`A`.`COLLECTOR_LAT` AS `COLLECTOR_LAT`,
        `chiumdev_2`.`A`.`COLLECTOR_LNG` AS `COLLECTOR_LNG`,
        `chiumdev_2`.`A`.`COLLECTOR_SITE_NAME` AS `COLLECTOR_SITE_NAME`,
        `chiumdev_2`.`A`.`COLLECTOR_HEAD_OFFICE` AS `COLLECTOR_HEAD_OFFICE`,
        `chiumdev_2`.`A`.`COLLECTOR_TRMT_BIZ_CODE` AS `COLLECTOR_TRMT_BIZ_CODE`,
        `chiumdev_2`.`A`.`TRMT_BIZ_NM` AS `TRMT_BIZ_NM`,
        `chiumdev_2`.`A`.`COLLECTOR_BID_AMOUNT` AS `COLLECTOR_BID_AMOUNT`,
        `chiumdev_2`.`A`.`COLLECTOR_GREENHOUSE_GAS` AS `COLLECTOR_GREENHOUSE_GAS`,
        `chiumdev_2`.`A`.`COLLECTOR_WINNER` AS `COLLECTOR_WINNER`,
        `chiumdev_2`.`A`.`COLLECTOR_ACTIVE` AS `COLLECTOR_ACTIVE`,
        `chiumdev_2`.`A`.`COLLECTOR_CANCEL_VISIT` AS `COLLECTOR_CANCEL_VISIT`,
        `chiumdev_2`.`A`.`COLLECTOR_CANCEL_BIDDING` AS `COLLECTOR_CANCEL_BIDDING`,
        `chiumdev_2`.`A`.`COLLECTOR_DATE_OF_VISIT` AS `COLLECTOR_DATE_OF_VISIT`,
        `chiumdev_2`.`A`.`COLLECTOR_DATE_OF_BIDDING` AS `COLLECTOR_DATE_OF_BIDDING`,
        `chiumdev_2`.`A`.`COLLECTOR_SELECTED` AS `COLLECTOR_SELECTED`,
        `chiumdev_2`.`A`.`COLLECTOR_SELECTED_AT` AS `COLLECTOR_SELECTED_AT`,
        `chiumdev_2`.`A`.`COLLECTOR_MAKE_DECISION` AS `COLLECTOR_MAKE_DECISION`,
        `chiumdev_2`.`A`.`DISPOSER_RESPONSE_VISIT` AS `DISPOSER_RESPONSE_VISIT`,
        `chiumdev_2`.`A`.`DISPOSER_REJECT_BIDDING` AS `DISPOSER_REJECT_BIDDING`,
        `chiumdev_2`.`A`.`DISPOSER_RESPONSE_VISIT_AT` AS `DISPOSER_RESPONSE_VISIT_AT`,
        `chiumdev_2`.`A`.`DISPOSER_REJECT_BIDDING_AT` AS `DISPOSER_REJECT_BIDDING_AT`,
        `chiumdev_2`.`A`.`COLLECTOR_MAKE_DECISION_AT` AS `COLLECTOR_MAKE_DECISION_AT`,
        `chiumdev_2`.`A`.`COLLECTOR_RECORD_CREATED_AT` AS `COLLECTOR_RECORD_CREATED_AT`,
        `chiumdev_2`.`A`.`COLLECTOR_RECORD_UPDATED_AT` AS `COLLECTOR_RECORD_UPDATED_AT`,
        `chiumdev_2`.`A`.`COLLECTOR_MAX_DECISION_AT` AS `COLLECTOR_MAX_DECISION_AT`,
        `chiumdev_2`.`A`.`DISPOSER_ORDER_ID` AS `DISPOSER_ORDER_ID`,
        `chiumdev_2`.`A`.`DISPOSER_ORDER_COLLECTOR_ID` AS `DISPOSER_ORDER_COLLECTOR_ID`,
        `chiumdev_2`.`A`.`DISPOSER_TYPE` AS `DISPOSER_TYPE`,
        `chiumdev_2`.`A`.`DISPOSER_SITE_ID` AS `DISPOSER_SITE_ID`,
        `chiumdev_2`.`A`.`DISPOSER_SI_DO` AS `DISPOSER_SI_DO`,
        `chiumdev_2`.`A`.`DISPOSER_SI_GUN_GU` AS `DISPOSER_SI_GUN_GU`,
        `chiumdev_2`.`A`.`DISPOSER_EUP_MYEON_DONG` AS `DISPOSER_EUP_MYEON_DONG`,
        `chiumdev_2`.`A`.`DISPOSER_DONG_RI` AS `DISPOSER_DONG_RI`,
        `chiumdev_2`.`A`.`DISPOSER_KIKCD_B_CODE` AS `DISPOSER_KIKCD_B_CODE`,
        `chiumdev_2`.`A`.`DISPOSER_ADDR` AS `DISPOSER_ADDR`,
        `chiumdev_2`.`A`.`DISPOSER_CONTACT` AS `DISPOSER_CONTACT`,
        `chiumdev_2`.`A`.`DISPOSER_LAT` AS `DISPOSER_LAT`,
        `chiumdev_2`.`A`.`DISPOSER_LNG` AS `DISPOSER_LNG`,
        `chiumdev_2`.`A`.`DISPOSER_SITE_NAME` AS `DISPOSER_SITE_NAME`,
        `chiumdev_2`.`A`.`DISPOSER_HEAD_OFFICE` AS `DISPOSER_HEAD_OFFICE`,
        `chiumdev_2`.`A`.`DISPOSER_TRMT_BIZ_CODE` AS `DISPOSER_TRMT_BIZ_CODE`,
        `chiumdev_2`.`A`.`DISPOSER_ACTIVE` AS `DISPOSER_ACTIVE`,
        `chiumdev_2`.`A`.`DISPOSER_ORDER_CODE` AS `DISPOSER_ORDER_CODE`,
        `chiumdev_2`.`A`.`DISPOSER_ORDER_MANAGER_ID` AS `DISPOSER_ORDER_MANAGER_ID`,
        `chiumdev_2`.`A`.`DISPOSER_VISIT_END_AT` AS `DISPOSER_VISIT_END_AT`,
        `chiumdev_2`.`A`.`DISPOSER_BIDDING_END_AT` AS `DISPOSER_BIDDING_END_AT`,
        `chiumdev_2`.`A`.`DISPOSER_OPEN_AT` AS `DISPOSER_OPEN_AT`,
        `chiumdev_2`.`A`.`DISPOSER_CLOSE_AT` AS `DISPOSER_CLOSE_AT`,
        `chiumdev_2`.`A`.`DISPOSER_SERVICE_INSTRUCTION_ID` AS `DISPOSER_SERVICE_INSTRUCTION_ID`,
        `chiumdev_2`.`A`.`DISPOSER_CREATED_AT` AS `DISPOSER_CREATED_AT`,
        `chiumdev_2`.`A`.`DISPOSER_VISIT_EARLY_CLOSING` AS `DISPOSER_VISIT_EARLY_CLOSING`,
        `chiumdev_2`.`A`.`DISPOSER_VISIT_EARLY_CLOSED_AT` AS `DISPOSER_VISIT_EARLY_CLOSED_AT`,
        `chiumdev_2`.`A`.`DISPOSER_UPDATED_AT` AS `DISPOSER_UPDATED_AT`,
        `chiumdev_2`.`A`.`DISPOSER_BIDDING_EARLY_CLOSING` AS `DISPOSER_BIDDING_EARLY_CLOSING`,
        `chiumdev_2`.`A`.`DISPOSER_BIDDING_EARLY_CLOSED_AT` AS `DISPOSER_BIDDING_EARLY_CLOSED_AT`,
        `chiumdev_2`.`A`.`DISPOSER_ORDER_DELETED` AS `DISPOSER_ORDER_DELETED`,
        `chiumdev_2`.`A`.`DISPOSER_ORDER_DELETED_AT` AS `DISPOSER_ORDER_DELETED_AT`,
        `chiumdev_2`.`A`.`BIDDING_RANK` AS `BIDDING_RANK`,
        `chiumdev_2`.`A`.`STRAIGHT_DISTANCE` AS `STRAIGHT_DISTANCE`,
        `chiumdev_2`.`A`.`STATE_CODE` AS `STATE_CODE`,
        `chiumdev_2`.`B`.`STATUS_NM_KO` AS `STATE`,
        `chiumdev_2`.`B`.`PID` AS `STATE_PID`,
        `chiumdev_2`.`B`.`STATUS_CATEGORY_ID` AS `STATE_CATEGORY_ID`,
        `chiumdev_2`.`B`.`STATUS_CATEGORY` AS `STATE_CATEGORY`,
        `chiumdev_2`.`A`.`DISPOSER_SELECTED2` AS `DISPOSER_SELECTED2`,
        `chiumdev_2`.`A`.`DISPOSER_SELECTED2_AT` AS `DISPOSER_SELECTED2_AT`,
        `chiumdev_2`.`A`.`COLLECTOR_SELECTION_CONFIRMED2` AS `COLLECTOR_SELECTION_CONFIRMED2`,
        `chiumdev_2`.`A`.`COLLECTOR_SELECTION_CONFIRMED2_AT` AS `COLLECTOR_SELECTION_CONFIRMED2_AT`,
        `chiumdev_2`.`A`.`DISPOSER_MAX_SELECT2_AT` AS `DISPOSER_MAX_SELECT2_AT`,
        `chiumdev_2`.`A`.`DISPOSER_NOTE` AS `DISPOSER_NOTE`
    FROM
        (`chiumdev_2`.`V_COLLECTOR_BIDDING` `A`
        LEFT JOIN `chiumdev_2`.`V_STATUS` `B` ON ((`chiumdev_2`.`A`.`STATE_CODE` = `chiumdev_2`.`B`.`ID`)))