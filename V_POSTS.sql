CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_POSTS` AS
    SELECT 
        `A`.`ID` AS `POST_ID`,
        `A`.`SITE_ID` AS `POST_SITE_ID`,
        `B`.`SITE_NAME` AS `POST_SITE_NAME`,
        `A`.`CREATOR_ID` AS `POST_CREATOR_ID`,
        `C`.`USER_NAME` AS `POST_CREATOR_NAME`,
        `A`.`SUBJECTS` AS `POST_SUBJECTS`,
        `A`.`CONTENTS` AS `POST_CONTENTS`,
        `A`.`CATEGORY` AS `POST_CATEGORY_ID`,
        `D`.`NAME` AS `POST_CATEGORY_NAME`,
        `A`.`VISITORS` AS `POST_VISITORS`,
        `A`.`PID` AS `POST_PID`,
        `A`.`CREATED_AT` AS `POST_CREATED_AT`,
        `A`.`UPDATED_AT` AS `POST_UPDATED_AT`
    FROM
        (((`chiumdev_2`.`POSTS` `A`
        LEFT JOIN `chiumdev_2`.`COMP_SITE` `B` ON ((`A`.`SITE_ID` = `B`.`ID`)))
        LEFT JOIN `chiumdev_2`.`USERS` `C` ON ((`A`.`CREATOR_ID` = `C`.`ID`)))
        LEFT JOIN `chiumdev_2`.`POST_CATEGORY` `D` ON ((`A`.`CATEGORY` = `D`.`ID`)))