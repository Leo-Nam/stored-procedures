CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_USERS` AS
    SELECT 
        `A`.`ID` AS `ID`,
        `A`.`USER_ID` AS `USER_ID`,
        `A`.`PWD` AS `PWD`,
        `A`.`USER_NAME` AS `USER_NAME`,
        `A`.`PHONE` AS `PHONE`,
        `A`.`BELONG_TO` AS `BELONG_TO`,
        `A`.`AFFILIATED_SITE` AS `AFFILIATED_SITE`,
        `chiumdev_2`.`C`.`COMP_SITE_TRMT_BIZ_CODE` AS `TRMT_BIZ_CODE`,
        `chiumdev_2`.`C`.`COMP_SITE_TRMT_BIZ_NM` AS `TRMT_BIZ_NM`,
        `chiumdev_2`.`C`.`COMP_SITE_NAME` AS `SITE_NAME`,
        IF((`chiumdev_2`.`C`.`COMP_ID` IS NULL),
            0,
            `chiumdev_2`.`C`.`COMP_ID`) AS `COMP_ID`,
        `A`.`ACTIVE` AS `ACTIVE`,
        `A`.`JWT` AS `JWT`,
        `A`.`FCM` AS `FCM`,
        `A`.`CLASS` AS `CLASS`,
        `A`.`USER_CURRENT_TYPE` AS `USER_CURRENT_TYPE_CODE`,
        `D`.`TYPE_EN` AS `USER_CURRENT_TYPE_NM`,
        `B`.`CLASS_NM` AS `CLASS_NM`,
        IF((`A`.`BELONG_TO` = 0),
            IF((`A`.`CLASS` < 200),
                'chium',
                'person'),
            `chiumdev_2`.`C`.`USER_TYPE_EN_NM`) AS `USER_TYPE`,
        `A`.`CREATED_AT` AS `CREATED_AT`,
        `A`.`UPDATED_AT` AS `UPDATED_AT`
    FROM
        (((`chiumdev_2`.`USERS` `A`
        LEFT JOIN `chiumdev_2`.`USERS_CLASS` `B` ON ((`A`.`CLASS` = `B`.`ID`)))
        LEFT JOIN `chiumdev_2`.`V_COMP_SITE` `C` ON ((`A`.`AFFILIATED_SITE` = `chiumdev_2`.`C`.`COMP_SITE_ID`)))
        LEFT JOIN `chiumdev_2`.`USER_TYPE` `D` ON ((`A`.`USER_CURRENT_TYPE` = `D`.`ID`)))