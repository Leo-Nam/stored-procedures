CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_WSTE_TRMT_METHOD` AS
    SELECT 
        `A`.`CODE` AS `CODE`,
        `A`.`WSTE_TRMT_CLS_1` AS `WSTE_TRMT_CLS_1`,
        `A`.`WSTE_TRMT_CLS_2` AS `WSTE_TRMT_CLS_2`,
        `A`.`NAME` AS `NAME`,
        `B`.`NAME` AS `WSTE_TRMT_CLS_NM_1`,
        `C`.`NAME` AS `WSTE_TRMT_CLS_NM_2`
    FROM
        ((`chiumdev_2`.`WSTE_TRMT_METHOD` `A`
        JOIN `chiumdev_2`.`WSTE_TRMT_CLS_1` `B`)
        JOIN `chiumdev_2`.`WSTE_TRMT_CLS_2` `C`)
    WHERE
        ((`A`.`WSTE_TRMT_CLS_1` = `B`.`ID`)
            AND (`A`.`WSTE_TRMT_CLS_2` = `C`.`ID`))
    ORDER BY `A`.`CODE`