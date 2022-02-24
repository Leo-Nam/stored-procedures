CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_WSTE_TRMT_BIZ` AS
    SELECT 
        `A`.`CODE` AS `CODE`,
        `A`.`NAME` AS `NAME`,
        `A`.`NOTE` AS `NOTE`,
        `A`.`USER_TYPE` AS `USER_TYPE`,
        `B`.`TYPE_EN` AS `USER_TYPE_EN_NM`,
        `B`.`TYPE_KO` AS `USER_TYPE_KO_NM`
    FROM
        (`chiumdev_2`.`WSTE_TRMT_BIZ` `A`
        LEFT JOIN `chiumdev_2`.`USER_TYPE` `B` ON ((`A`.`USER_TYPE` = `B`.`ID`)))