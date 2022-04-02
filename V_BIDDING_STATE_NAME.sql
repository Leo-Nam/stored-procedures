CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_BIDDING_STATE_NAME` AS
    SELECT 
        `chiumdev_2`.`A`.`COLLECTOR_BIDDING_ID` AS `COLLECTOR_BIDDING_ID`,
        `chiumdev_2`.`A`.`STATE_CODE` AS `STATE_CODE`,
        `chiumdev_2`.`B`.`STATUS_NM_KO` AS `STATE`,
        `chiumdev_2`.`B`.`PID` AS `STATE_PID`,
        `chiumdev_2`.`B`.`STATUS_CATEGORY_ID` AS `STATE_CATEGORY_ID`,
        `chiumdev_2`.`B`.`STATUS_CATEGORY` AS `STATE_CATEGORY`,
        `chiumdev_2`.`B`.`COLLECTOR_CATEGORY_ID` AS `COLLECTOR_CATEGORY_ID`,
        `chiumdev_2`.`B`.`COLLECTOR_CATEGORY` AS `COLLECTOR_CATEGORY`
    FROM
        (`chiumdev_2`.`V_BIDDING_STATE` `A`
        LEFT JOIN `chiumdev_2`.`V_STATUS` `B` ON ((`chiumdev_2`.`A`.`STATE_CODE` = `chiumdev_2`.`B`.`ID`)))