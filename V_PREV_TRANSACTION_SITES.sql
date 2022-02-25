CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_PREV_TRANSACTION_SITES` AS
    SELECT 
        `chiumdev_2`.`V_COLLECTOR_BIDDING`.`COLLECTOR_SITE_ID` AS `COLLECTOR_SITE_ID`,
        `chiumdev_2`.`V_COLLECTOR_BIDDING`.`COLLECTOR_SITE_NAME` AS `COLLECTOR_SITE_NM`,
        `chiumdev_2`.`V_COLLECTOR_BIDDING`.`COLLECTOR_KIKCD_B_CODE` AS `COLLECTOR_KIKCD_B_CODE`,
        `chiumdev_2`.`V_COLLECTOR_BIDDING`.`DISPOSER_SITE_ID` AS `DISPOSER_SITE_ID`,
        `chiumdev_2`.`V_COLLECTOR_BIDDING`.`DISPOSER_SI_DO` AS `DISPOSER_SI_DO`,
        `chiumdev_2`.`V_COLLECTOR_BIDDING`.`DISPOSER_SI_GUN_GU` AS `DISPOSER_SI_GUN_GU`,
        `chiumdev_2`.`V_COLLECTOR_BIDDING`.`DISPOSER_EUP_MYEON_DONG` AS `DISPOSER_EUP_MYEON_DONG`,
        `chiumdev_2`.`V_COLLECTOR_BIDDING`.`DISPOSER_DONG_RI` AS `DISPOSER_DONG_RI`,
        `chiumdev_2`.`V_COLLECTOR_BIDDING`.`DISPOSER_ADDR` AS `DISPOSER_ADDR`
    FROM
        `chiumdev_2`.`V_COLLECTOR_BIDDING`
    WHERE
        (`chiumdev_2`.`V_COLLECTOR_BIDDING`.`DISPOSER_CLOSE_AT` > NOW())