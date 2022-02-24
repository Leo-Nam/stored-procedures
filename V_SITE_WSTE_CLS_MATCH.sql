CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_SITE_WSTE_CLS_MATCH` AS
    SELECT 
        `A`.`ID` AS `ID`,
        `A`.`SITE_ID` AS `SITE_ID`,
        `A`.`WSTE_CLS_CODE` AS `WSTE_CLS_CODE`,
        `B`.`COMP_NAME` AS `COMP_NAME`,
        `B`.`REP_NAME` AS `REP_NAME`,
        `B`.`KIKCD_B_CODE` AS `KIKCD_B_CODE`,
        `B`.`ADDR` AS `ADDR`,
        `B`.`CONTACT` AS `CONTACT`,
        `B`.`PERMIT_DT` AS `PERMIT_DT`,
        `B`.`RETURN_DT` AS `RETURN_DT`,
        `B`.`NOTE` AS `NOTE`,
        `B`.`TRMT_BIZ_CODE` AS `TRMT_BIZ_CODE`,
        `C`.`NAME` AS `WSTE_CLS_NM`,
        `D`.`NAME` AS `TRMT_BIZ_NM`,
        `E`.`SI_DO` AS `SI_DO`,
        `E`.`SI_GUN_GU` AS `SI_GUN_GU`
    FROM
        (((((`chiumdev_2`.`SITE_WSTE_CLS_MATCH` `A`
        LEFT JOIN `chiumdev_2`.`COMP_SITE` `F` ON ((`A`.`SITE_ID` = `F`.`ID`)))
        LEFT JOIN `chiumdev_2`.`COMPANY` `B` ON ((`F`.`COMP_ID` = `B`.`ID`)))
        LEFT JOIN `chiumdev_2`.`WSTE_CLS_CODE` `C` ON ((`A`.`WSTE_CLS_CODE` = `C`.`CODE`)))
        LEFT JOIN `chiumdev_2`.`WSTE_TRMT_BIZ` `D` ON ((`B`.`TRMT_BIZ_CODE` = `D`.`CODE`)))
        LEFT JOIN `chiumdev_2`.`KIKCD_B` `E` ON ((`B`.`KIKCD_B_CODE` = `E`.`B_CODE`)))
    ORDER BY `A`.`ID`