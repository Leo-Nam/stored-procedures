CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_WSTE_CODE` AS
    SELECT 
        `A`.`CODE` AS `CODE`,
        `A`.`CODE_1` AS `CODE_1`,
        `A`.`CODE_2` AS `CODE_2`,
        `A`.`CODE_3` AS `CODE_3`,
        `A`.`CODE_4` AS `CODE_4`,
        `A`.`NAME` AS `NAME`,
        `A`.`LAW_REV` AS `LAW_REV`,
        `A`.`WSTE_REPT_CLS_CODE` AS `WSTE_REPT_CLS_CODE`,
        `A`.`DISPLAY` AS `DISPLAY`,
        `B`.`NAME` AS `WSTE_REPT_CLS_NM`,
        `C`.`ID` AS `CLASS_ID`,
        `C`.`CLASS_NAME` AS `CLASS_NAME`
    FROM
        ((`chiumdev_2`.`WSTE_CODE` `A`
        LEFT JOIN `chiumdev_2`.`WSTE_REPT_CLS` `B` ON ((`A`.`WSTE_REPT_CLS_CODE` = `B`.`CODE`)))
        LEFT JOIN `chiumdev_2`.`WSTE_CLS_1` `C` ON ((`A`.`WSTE_CLASS` = `C`.`ID`)))
    ORDER BY `A`.`CODE`