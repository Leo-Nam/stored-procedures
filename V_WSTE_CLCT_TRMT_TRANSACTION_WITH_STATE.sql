CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_WSTE_CLCT_TRMT_TRANSACTION_WITH_STATE` AS
    SELECT 
        `chiumdev_2`.`A`.`TRANSACTION_ID` AS `TRANSACTION_ID`,
        `chiumdev_2`.`A`.`DISPOSER_ORDER_ID` AS `DISPOSER_ORDER_ID`,
        `chiumdev_2`.`A`.`COLLECTOR_BIDDING_ID` AS `COLLECTOR_BIDDING_ID`,
        `chiumdev_2`.`A`.`COLLECTOR_SITE_ID` AS `COLLECTOR_SITE_ID`,
        `chiumdev_2`.`A`.`COLLECTOR_SITE_NAME` AS `COLLECTOR_SITE_NAME`,
        `chiumdev_2`.`A`.`DISPOSER_SI_DO` AS `DISPOSER_SI_DO`,
        `chiumdev_2`.`A`.`DISPOSER_SI_GUN_GU` AS `DISPOSER_SI_GUN_GU`,
        `chiumdev_2`.`A`.`DISPOSER_EUP_MYEON_DONG` AS `DISPOSER_EUP_MYEON_DONG`,
        `chiumdev_2`.`A`.`DISPOSER_DONG_RI` AS `DISPOSER_DONG_RI`,
        `chiumdev_2`.`A`.`DISPOSER_ADDR` AS `DISPOSER_ADDR`,
        `chiumdev_2`.`A`.`DISPOSER_KIKCD_B_CODE` AS `DISPOSER_KIKCD_B_CODE`,
        `chiumdev_2`.`A`.`DISPOSER_ORDER_COLLECTOR_ID` AS `DISPOSER_ORDER_COLLECTOR_ID`,
        `chiumdev_2`.`A`.`DISPOSER_OPEN_AT` AS `DISPOSER_OPEN_AT`,
        `chiumdev_2`.`A`.`DISPOSER_CLOSE_AT` AS `DISPOSER_CLOSE_AT`,
        `chiumdev_2`.`A`.`DISPOSER_ORDER_CODE` AS `DISPOSER_ORDER_CODE`,
        `chiumdev_2`.`A`.`ASKER_ID` AS `ASKER_ID`,
        `chiumdev_2`.`A`.`DISPOSER_SITE_ID` AS `DISPOSER_SITE_ID`,
        `chiumdev_2`.`A`.`DISPOSER_SITE_NM` AS `DISPOSER_SITE_NM`,
        `chiumdev_2`.`A`.`COLLECT_ASK_END_AT` AS `COLLECT_ASK_END_AT`,
        `chiumdev_2`.`A`.`COLLECTING_TRUCK_ID` AS `COLLECTING_TRUCK_ID`,
        `chiumdev_2`.`A`.`TRUCK_DRIVER_ID` AS `TRUCK_DRIVER_ID`,
        `chiumdev_2`.`A`.`TRUCK_START_AT` AS `TRUCK_START_AT`,
        `chiumdev_2`.`A`.`COLLECT_END_AT` AS `COLLECT_END_AT`,
        `chiumdev_2`.`A`.`WSTE_CODE` AS `WSTE_CODE`,
        `chiumdev_2`.`A`.`WSTE_CLASS` AS `WSTE_CLASS`,
        `chiumdev_2`.`A`.`WSTE_NM` AS `WSTE_NM`,
        `chiumdev_2`.`A`.`WSTE_QUANTITY` AS `WSTE_QUANTITY`,
        `chiumdev_2`.`A`.`WSTE_UNIT` AS `WSTE_UNIT`,
        `chiumdev_2`.`A`.`PRICE_UNIT` AS `PRICE_UNIT`,
        `chiumdev_2`.`A`.`TRMT_METHOD_CODE` AS `TRMT_METHOD_CODE`,
        `chiumdev_2`.`A`.`TRMT_METHOD_NM` AS `TRMT_METHOD_NM`,
        `chiumdev_2`.`A`.`CONTRACT_ID` AS `CONTRACT_ID`,
        `chiumdev_2`.`A`.`CONFIRMER_ID` AS `CONFIRMER_ID`,
        `chiumdev_2`.`A`.`CONFIRMED_AT` AS `CONFIRMED_AT`,
        `chiumdev_2`.`A`.`DATE_OF_VISIT` AS `DATE_OF_VISIT`,
        `chiumdev_2`.`A`.`VISIT_START_AT` AS `VISIT_START_AT`,
        `chiumdev_2`.`A`.`VISIT_END_AT` AS `VISIT_END_AT`,
        `chiumdev_2`.`A`.`CREATED_AT` AS `CREATED_AT`,
        `chiumdev_2`.`A`.`UPDATED_AT` AS `UPDATED_AT`,
        `chiumdev_2`.`A`.`TRANSACTION_STATE_CODE` AS `TRANSACTION_STATE_CODE`,
        `chiumdev_2`.`B`.`STATUS_NM_KO` AS `STATE`
    FROM
        (`chiumdev_2`.`V_WSTE_CLCT_TRMT_TRANSACTION` `A`
        LEFT JOIN `chiumdev_2`.`V_STATUS` `B` ON ((`chiumdev_2`.`A`.`TRANSACTION_STATE_CODE` = `chiumdev_2`.`B`.`ID`)))