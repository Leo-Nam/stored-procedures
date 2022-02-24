CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_STATUS_GROUP` AS
    SELECT 
        `A`.`USER_TYPE` AS `USER_TYPE`,
        `B`.`TYPE_EN` AS `USER_TYPE_NM_EN`,
        `B`.`TYPE_KO` AS `USER_TYPE_NM_KO`,
        `A`.`ACTIVE` AS `ACTIVE`,
        IF((`A`.`PID` = 0), `A`.`ID`, `C`.`ID`) AS `DISP_ID`,
        IF((`A`.`PID` = 0),
            `A`.`STATUS_NM_KO`,
            `C`.`STATUS_NM_KO`) AS `DISP_NM_KO`,
        IF((`A`.`PID` = 0),
            `A`.`STATUS_NM_EN`,
            `C`.`STATUS_NM_EN`) AS `DISP_NM_EN`
    FROM
        ((`chiumdev_2`.`STATUS` `A`
        LEFT JOIN `chiumdev_2`.`USER_TYPE` `B` ON ((`A`.`USER_TYPE` = `B`.`ID`)))
        LEFT JOIN `chiumdev_2`.`STATUS` `C` ON ((`A`.`PID` = `C`.`ID`)))
    GROUP BY `DISP_ID`
    ORDER BY `A`.`ID`