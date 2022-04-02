CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_TRANSACTION_STATE_NAME` AS
    SELECT 
        `chiumdev_2`.`A`.`TRANSACTION_ID` AS `TRANSACTION_ID`,
        `chiumdev_2`.`A`.`DISPOSAL_ORDER_ID` AS `DISPOSAL_ORDER_ID`,
        `chiumdev_2`.`A`.`IN_PROGRESS` AS `IN_PROGRESS`,
        `chiumdev_2`.`A`.`TRANSACTION_STATE_CODE` AS `STATE_CODE`,
        `chiumdev_2`.`B`.`STATUS_NM_KO` AS `STATE`,
        `chiumdev_2`.`B`.`STATUS_CATEGORY_ID` AS `STATE_CATEGORY_ID`,
        `chiumdev_2`.`B`.`STATUS_CATEGORY` AS `STATE_CATEGORY`
    FROM
        (`chiumdev_2`.`V_TRANSACTION_STATE` `A`
        LEFT JOIN `chiumdev_2`.`V_STATUS` `B` ON ((`chiumdev_2`.`A`.`TRANSACTION_STATE_CODE` = `chiumdev_2`.`B`.`ID`)))