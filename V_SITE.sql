CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_SITE` AS
    SELECT 
        `D`.`ID` AS `SITE_ID`,
        `A`.`ID` AS `COMP_ID`,
        `A`.`COMP_NAME` AS `COMP_NAME`,
        `D`.`SITE_NAME` AS `SITE_NAME`,
        `A`.`REP_NAME` AS `REP_NAME`,
        `D`.`KIKCD_B_CODE` AS `KIKCD_B_CODE`,
        `D`.`ADDR` AS `ADDR`,
        `D`.`CONTACT` AS `CONTACT`,
        `D`.`LAT` AS `LAT`,
        `D`.`LNG` AS `LNG`,
        `A`.`BIZ_REG_CODE` AS `BIZ_REG_CODE`,
        `D`.`TRMT_BIZ_CODE` AS `TRMT_BIZ_CODE`,
        `D`.`PERMIT_REG_CODE` AS `PERMIT_REG_CODE`,
        `A`.`BIZ_REG_IMG_PATH` AS `BIZ_REG_IMG_PATH`,
        `D`.`PERMIT_REG_IMG_PATH` AS `PERMIT_REG_IMG_PATH`,
        `B`.`SI_DO` AS `SI_DO`,
        `B`.`SI_GUN_GU` AS `SI_GUN_GU`,
        `C`.`NAME` AS `WSTE_TRMT_NM`
    FROM
        (((`chiumdev_2`.`COMP_SITE` `D`
        LEFT JOIN `chiumdev_2`.`COMPANY` `A` ON ((`A`.`ID` = `D`.`COMP_ID`)))
        LEFT JOIN `chiumdev_2`.`KIKCD_B` `B` ON ((`A`.`KIKCD_B_CODE` = `B`.`B_CODE`)))
        LEFT JOIN `chiumdev_2`.`WSTE_TRMT_BIZ` `C` ON ((`A`.`TRMT_BIZ_CODE` = `C`.`CODE`)))
    ORDER BY `A`.`ID`