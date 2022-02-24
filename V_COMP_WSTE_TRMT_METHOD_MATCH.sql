CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_COMP_WSTE_TRMT_METHOD_MATCH` AS
    SELECT 
        `A`.`ID` AS `ID`,
        `E`.`ID` AS `COMP_ID`,
        `E`.`COMP_NAME` AS `COMP_NAME`,
        `E`.`REP_NAME` AS `REP_NAME`,
        `E`.`KIKCD_B_CODE` AS `KIKCD_B_CODE`,
        `E`.`LAT` AS `LAT`,
        `E`.`LNG` AS `LNG`,
        `F`.`SI_DO` AS `SI_DO`,
        `F`.`SI_GUN_GU` AS `SI_GUN_GU`,
        `E`.`ADDR` AS `ADDR`,
        `G`.`NAME` AS `TRMT_BIZ_NM`,
        `B`.`WSTE_TRMT_CLS_1` AS `WSTE_TRMT_CLS_1`,
        `B`.`WSTE_TRMT_CLS_2` AS `WSTE_TRMT_CLS_2`,
        `B`.`NAME` AS `WSTE_TRMT_METHOD_NM`,
        `C`.`NAME` AS `WSTE_TRMT_CLS_1_NM`,
        `D`.`NAME` AS `WSTE_TRMT_CLS_2_NM`
    FROM
        ((((((`chiumdev_2`.`COMP_WSTE_TRMT_METHOD_MATCH` `A`
        LEFT JOIN `chiumdev_2`.`WSTE_TRMT_METHOD` `B` ON ((`A`.`WSTE_TRMT_METHOD_CODE` = `B`.`CODE`)))
        LEFT JOIN `chiumdev_2`.`WSTE_TRMT_CLS_1` `C` ON ((`B`.`WSTE_TRMT_CLS_1` = `C`.`ID`)))
        LEFT JOIN `chiumdev_2`.`WSTE_TRMT_CLS_2` `D` ON ((`B`.`WSTE_TRMT_CLS_2` = `D`.`ID`)))
        LEFT JOIN `chiumdev_2`.`COMPANY` `E` ON ((`A`.`COMP_ID` = `E`.`ID`)))
        LEFT JOIN `chiumdev_2`.`KIKCD_B` `F` ON ((`E`.`KIKCD_B_CODE` = `F`.`B_CODE`)))
        LEFT JOIN `chiumdev_2`.`WSTE_TRMT_BIZ` `G` ON ((`E`.`TRMT_BIZ_CODE` = `G`.`CODE`)))