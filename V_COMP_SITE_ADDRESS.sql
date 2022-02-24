CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_COMP_SITE_ADDRESS` AS
    SELECT 
        `A`.`ID` AS `SITE_ID`,
        `A`.`COMP_ID` AS `COMP_ID`,
        `A`.`KIKCD_B_CODE` AS `KIKCD_B_CODE`,
        `B`.`SI_DO` AS `SI_DO`,
        `B`.`SI_GUN_GU` AS `SI_GUN_GU`,
        `B`.`EUP_MYEON_DONG` AS `EUP_MYEON_DONG`,
        `B`.`DONG_RI` AS `DONG_RI`,
        `A`.`ADDR` AS `ADDR`,
        `A`.`ACTIVE` AS `ACTIVE`
    FROM
        (`chiumdev_2`.`COMP_SITE` `A`
        LEFT JOIN `chiumdev_2`.`KIKCD_B` `B` ON ((`A`.`KIKCD_B_CODE` = `B`.`B_CODE`)))
    ORDER BY `A`.`ID`