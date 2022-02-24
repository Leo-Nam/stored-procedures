CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_STATUS_HISTORY` AS
    SELECT 
        `A`.`ID` AS `ID`,
        `A`.`DISPOSAL_ORDER_ID` AS `DISPOSAL_ORDER_ID`,
        `A`.`COLLECTOR_ID` AS `COLLECTOR_SITE_ID`,
        `B`.`DISPOSER_ID` AS `DISPOER_SITE_ID`,
        `B`.`ORDER_CODE` AS `DISPOSAL_ORDER_CODE`,
        `A`.`STATUS_CODE` AS `STATUS_CODE`,
        `chiumdev_2`.`D`.`STATUS_NM_KO` AS `STATUS_NM_KO`,
        `chiumdev_2`.`D`.`STATUS_NM_EN` AS `STATUS_NM_EN`,
        `A`.`CREATED_AT` AS `CREATED_AT`,
        `A`.`UPDATED_AT` AS `UPDATED_AT`
    FROM
        (((`chiumdev_2`.`STATUS_HISTORY` `A`
        LEFT JOIN `chiumdev_2`.`SITE_WSTE_DISPOSAL_ORDER` `B` ON ((`A`.`DISPOSAL_ORDER_ID` = `B`.`ID`)))
        LEFT JOIN `chiumdev_2`.`COMP_SITE` `C` ON ((`A`.`COLLECTOR_ID` = `C`.`ID`)))
        LEFT JOIN `chiumdev_2`.`V_STATUS` `D` ON ((`A`.`STATUS_CODE` = `chiumdev_2`.`D`.`ID`)))