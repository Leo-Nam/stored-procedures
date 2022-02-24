CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_BIDDING_DETAILS` AS
    SELECT 
        `A`.`ID` AS `ID`,
        `D`.`DISPOSAL_ORDER_ID` AS `DISPOSAL_ORDER_ID`,
        `A`.`COLLECTOR_BIDDING_ID` AS `COLLECTOR_BIDDING_ID`,
        `B`.`NAME` AS `WSTE_NM`,
        `A`.`WSTE_CODE` AS `WSTE_CODE`,
        `A`.`UNIT` AS `UNIT`,
        `A`.`UNIT_PRICE` AS `UNIT_PRICE`,
        `A`.`VOLUME` AS `VOLUME`,
        `A`.`TRMT_CODE` AS `TRMT_METHOD_CODE`,
        `C`.`NAME` AS `TRMT_METHOD_NM`,
        `A`.`ACTIVE` AS `ACTIVE`,
        `A`.`GREENHOUSE_GAS` AS `GREENHOUSE_GAS`,
        `A`.`CREATED_AT` AS `CREATED_AT`,
        `A`.`UPDATED_AT` AS `UPDATED_AT`
    FROM
        (((`chiumdev_2`.`BIDDING_DETAILS` `A`
        LEFT JOIN `chiumdev_2`.`WSTE_CODE` `B` ON ((`A`.`WSTE_CODE` = `B`.`CODE`)))
        LEFT JOIN `chiumdev_2`.`WSTE_TRMT_METHOD` `C` ON ((`A`.`TRMT_CODE` = `C`.`CODE`)))
        LEFT JOIN `chiumdev_2`.`COLLECTOR_BIDDING` `D` ON ((`A`.`COLLECTOR_BIDDING_ID` = `D`.`ID`)))