CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_KIKCD_B` AS
    SELECT 
        `A`.`B_CODE` AS `B_CODE`,
        `A`.`SI_DO` AS `SI_DO`,
        `A`.`SI_GUN_GU` AS `SI_GUN_GU`,
        `A`.`EUP_MYEON_DONG` AS `EUP_MYEON_DONG`,
        `A`.`DONG_RI` AS `DONG_RI`,
        `A`.`CREATED_DATE` AS `CREATED_DATE`,
        `A`.`CANCELED_DATE` AS `CANCELED_DATE`,
        `B`.`DIVISION_CODE` AS `DIVISION_CODE`,
        `B`.`KIKCD_SIDO_CODE` AS `KIKCD_SIDO_CODE`,
        IF((`A`.`SI_GUN_GU` IS NULL),
            NULL,
            SUBSTR(`A`.`B_CODE`, 3, 3)) AS `KIKCD_SIGUNGU_CODE`,
        IF((`A`.`EUP_MYEON_DONG` IS NULL),
            NULL,
            SUBSTR(`A`.`B_CODE`, 6, 3)) AS `KIKCD_EUP_MYEON_DONG_CODE`,
        IF((`A`.`DONG_RI` IS NULL),
            NULL,
            RIGHT(`A`.`B_CODE`, 2)) AS `KIKCD_DONGRI_CODE`,
        `C`.`NAME` AS `KIKCD_DIVISION_NM`
    FROM
        ((`chiumdev_2`.`KIKCD_DIVISION_MATCH` `B`
        LEFT JOIN `chiumdev_2`.`KIKCD_B` `A` ON ((LEFT(`A`.`B_CODE`, 2) = `B`.`KIKCD_SIDO_CODE`)))
        JOIN `chiumdev_2`.`KIKCD_DIVISION` `C`)
    WHERE
        ((`A`.`CANCELED_DATE` IS NULL)
            AND (`C`.`CODE` = `B`.`DIVISION_CODE`))
    ORDER BY `B`.`ID`