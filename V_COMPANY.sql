CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_COMPANY` AS
    SELECT 
        `A`.`ID` AS `ID`,
        `A`.`COMP_NAME` AS `COMP_NAME`,
        `A`.`REP_NAME` AS `REP_NAME`,
        `A`.`KIKCD_B_CODE` AS `KIKCD_B_CODE`,
        `A`.`ADDR` AS `ADDR`,
        `A`.`CONTACT` AS `CONTACT`,
        `A`.`PERMIT_DT` AS `PERMIT_DT`,
        `A`.`RETURN_DT` AS `RETURN_DT`,
        `A`.`NOTE` AS `NOTE`,
        `A`.`TRMT_BIZ_CODE` AS `TRMT_BIZ_CODE`,
        `A`.`LAT` AS `LAT`,
        `A`.`LNG` AS `LNG`,
        `A`.`BIZ_REG_CODE` AS `BIZ_REG_CODE`,
        `B`.`SI_DO` AS `SI_DO`,
        `B`.`SI_GUN_GU` AS `SI_GUN_GU`,
        `C`.`NAME` AS `WSTE_TRMT_NM`
    FROM
        ((`chiumdev_2`.`COMPANY` `A`
        LEFT JOIN `chiumdev_2`.`KIKCD_B` `B` ON ((`A`.`KIKCD_B_CODE` = `B`.`B_CODE`)))
        LEFT JOIN `chiumdev_2`.`WSTE_TRMT_BIZ` `C` ON ((`A`.`TRMT_BIZ_CODE` = `C`.`CODE`)))
    ORDER BY `A`.`ID`