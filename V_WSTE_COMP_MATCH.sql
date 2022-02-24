CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_WSTE_COMP_MATCH` AS
    SELECT 
        `A`.`ID` AS `ID`,
        `A`.`COMP_ID` AS `COMP_ID`,
        `A`.`WSTE_CODE` AS `WSTE_CODE`,
        `A`.`WSTE_CLS` AS `WSTE_CLS`,
        `B`.`COMP_NAME` AS `COMP_NAME`,
        `B`.`REP_NAME` AS `REP_NAME`,
        `B`.`KIKCD_B_CODE` AS `KIKCD_B_CODE`,
        `B`.`ADDR` AS `ADDR`,
        `B`.`CONTACT` AS `CONTACT`,
        `B`.`PERMIT_DT` AS `PERMIT_DT`,
        `B`.`RETURN_DT` AS `RETURN_DT`,
        `B`.`NOTE` AS `NOTE`,
        `B`.`TRMT_BIZ_CODE` AS `TRMT_BIZ_CODE`,
        `C`.`NAME` AS `WSTE_NM`,
        `D`.`NAME` AS `WSTE_CLS_NM`,
        `E`.`SI_DO` AS `SI_DO`,
        `E`.`SI_GUN_GU` AS `SI_GUN_GU`,
        `F`.`NAME` AS `TRMT_BIZ_NM`
    FROM
        (((((`chiumdev_2`.`WSTE_COMP_MATCH` `A`
        LEFT JOIN `chiumdev_2`.`COMPANY` `B` ON ((`A`.`COMP_ID` = `B`.`ID`)))
        LEFT JOIN `chiumdev_2`.`WSTE_CODE` `C` ON ((`A`.`WSTE_CODE` = `C`.`CODE`)))
        LEFT JOIN `chiumdev_2`.`WSTE_CLS_CODE` `D` ON ((`A`.`WSTE_CLS` = `D`.`CODE`)))
        LEFT JOIN `chiumdev_2`.`KIKCD_B` `E` ON ((`B`.`KIKCD_B_CODE` = `E`.`B_CODE`)))
        LEFT JOIN `chiumdev_2`.`WSTE_TRMT_BIZ` `F` ON ((`B`.`TRMT_BIZ_CODE` = `F`.`CODE`)))