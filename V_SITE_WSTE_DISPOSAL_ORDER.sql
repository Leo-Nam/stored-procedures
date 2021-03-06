CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_SITE_WSTE_DISPOSAL_ORDER` AS
    SELECT 
        `A`.`ID` AS `DISPOSER_ORDER_ID`,
        `A`.`DISPOSER_ID` AS `DISPOSER_ID`,
        `A`.`COLLECTOR_ID` AS `COLLECTOR_ID`,
        `chiumdev_2`.`F`.`COMP_SITE_NAME` AS `COLLECTOR_SITE_NAME`,
        `C`.`PHONE` AS `DISPOSER_PHONE`,
        `A`.`DISPOSER_TYPE` AS `DISPOSER_TYPE`,
        `A`.`SITE_ID` AS `DISPOSER_SITE_ID`,
        `chiumdev_2`.`B`.`COMP_SITE_SI_DO` AS `DISPOSER_SITE_SI_DO`,
        `chiumdev_2`.`B`.`COMP_SITE_SI_GUN_GU` AS `DISPOSER_SITE_SI_GUN_GU`,
        `chiumdev_2`.`B`.`COMP_SITE_EUP_MYEON_DONG` AS `DISPOSER_SITE_EUP_MYEON_DONG`,
        `chiumdev_2`.`B`.`COMP_SITE_DONG_RI` AS `DISPOSER_SITE_DONG_RI`,
        `chiumdev_2`.`B`.`COMP_SITE_KIKCD_B_CODE` AS `DISPOSER_SITE_KIKCD_B_CODE`,
        `chiumdev_2`.`B`.`COMP_SITE_ADDR` AS `DISPOSER_SITE_ADDR`,
        `chiumdev_2`.`B`.`COMP_SITE_CONTACT` AS `DISPOSER_SITE_CONTACT`,
        `chiumdev_2`.`B`.`COMP_SITE_LAT` AS `DISPOSER_SITE_LAT`,
        `chiumdev_2`.`B`.`COMP_SITE_LNG` AS `DISPOSER_SITE_LNG`,
        `chiumdev_2`.`B`.`COMP_SITE_NAME` AS `DISPOSER_SITE_NAME`,
        `chiumdev_2`.`B`.`COMP_SITE_ACTIVE` AS `DISPOSER_SITE_ACTIVE`,
        `chiumdev_2`.`B`.`COMP_SITE_CONFIRMED` AS `DISPOSER_SITE_CONFIRMED`,
        `E`.`SI_DO` AS `WSTE_DISPOSED_SI_DO`,
        `E`.`SI_GUN_GU` AS `WSTE_DISPOSED_SI_GUN_GU`,
        `E`.`EUP_MYEON_DONG` AS `WSTE_DISPOSED_EUP_MYEON_DONG`,
        `E`.`DONG_RI` AS `WSTE_DISPOSED_DONG_RI`,
        `A`.`KIKCD_B_CODE` AS `WSTE_DISPOSED_KIKCD_B_CODE`,
        `A`.`ADDR` AS `WSTE_DISPOSED_ADDR`,
        `A`.`ACTIVE` AS `DISPOSER_ACTIVE`,
        `A`.`ORDER_CODE` AS `DISPOSER_ORDER_CODE`,
        `A`.`MANAGER_ID` AS `CS_MANAGER_ID`,
        `D`.`PHONE` AS `CS_MANAGER_PHONE`,
        `A`.`VISIT_START_AT` AS `DISPOSER_VISIT_START_AT`,
        `A`.`VISIT_END_AT` AS `DISPOSER_VISIT_END_AT`,
        `A`.`BIDDING_END_AT` AS `DISPOSER_BIDDING_END_AT`,
        `A`.`OPEN_AT` AS `DISPOSER_OPEN_AT`,
        `A`.`CLOSE_AT` AS `DISPOSER_CLOSE_AT`,
        `A`.`SELECTED` AS `DISPOSER_SELECTED`,
        `A`.`SELECTED_AT` AS `DISPOSER_SELECTED_AT`,
        `A`.`SERVICE_INSTRUCTION_ID` AS `DISPOSER_SERVICE_INSTRUCTION_ID`,
        `A`.`VISIT_EARLY_CLOSING` AS `DISPOSER_VISIT_EARLY_CLOSING`,
        `A`.`VISIT_EARLY_CLOSED_AT` AS `DISPOSER_VISIT_EARLY_CLOSED_AT`,
        `A`.`BIDDING_EARLY_CLOSING` AS `DISPOSER_BIDDING_EARLY_CLOSING`,
        `A`.`BIDDING_EARLY_CLOSED_AT` AS `DISPOSER_BIDDING_EARLY_CLOSED_AT`,
        `A`.`IS_DELETED` AS `DISPOSER_ORDER_DELETED`,
        `A`.`DELETED_AT` AS `DISPOSER_ORDER_DELETED_AT`,
        `A`.`CREATED_AT` AS `DISPOSER_CREATED_AT`,
        `A`.`UPDATED_AT` AS `DISPOSER_UPDATED_AT`,
        `A`.`COLLECTOR_SELECTION_CONFIRMED` AS `COLLECTOR_SELECTION_CONFIRMED`,
        `A`.`COLLECTOR_SELECTION_CONFIRMED_AT` AS `COLLECTOR_SELECTION_CONFIRMED_AT`,
        `A`.`PROSPECTIVE_VISITORS` AS `PROSPECTIVE_VISITORS`,
        `A`.`BIDDERS` AS `BIDDERS`,
        `A`.`NOTE` AS `NOTE`,
        `A`.`COLLECTOR_BIDDING_ID` AS `COLLECTOR_BIDDING_ID`,
        `A`.`TRANSACTION_ID` AS `TRANSACTION_ID`,
        `H`.`COLLECTOR_SITE_ID` AS `EX_TRANSACTION_COLLECTOR_SITE_ID`,
        IF((`A`.`IS_DELETED` = TRUE),
            106,
            IF((`A`.`VISIT_END_AT` IS NOT NULL),
                IF((`A`.`VISIT_START_AT` IS NOT NULL),
                    IF((`A`.`VISIT_START_AT` <= NOW()),
                        IF((`A`.`VISIT_END_AT` <= NOW()),
                            IF((`A`.`PROSPECTIVE_VISITORS` > 0),
                                IF((`A`.`BIDDING_END_AT` <= NOW()),
                                    IF((`A`.`BIDDERS` > 0),
                                        IF((`A`.`CLOSE_AT` <= NOW()),
                                            105,
                                            IF((`A`.`COLLECTOR_SELECTION_CONFIRMED` IS NOT NULL),
                                                IF((`A`.`COLLECTOR_SELECTION_CONFIRMED` = TRUE),
                                                    IF((`A`.`CLOSE_AT` <= NOW()), 105, 118),
                                                    IF((`A`.`BIDDERS` > 1),
                                                        IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` IS NOT NULL),
                                                            IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` = TRUE),
                                                                IF((`A`.`CLOSE_AT` <= NOW()), 105, 118),
                                                                115),
                                                            IF((`A`.`COLLECTOR_MAX_DECISION2_AT` <= NOW()),
                                                                115,
                                                                111)),
                                                        115)),
                                                IF((`A`.`COLLECTOR_MAX_DECISION_AT` <= NOW()),
                                                    IF((`A`.`BIDDERS` > 1),
                                                        IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` IS NOT NULL),
                                                            IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` = TRUE),
                                                                IF((`A`.`CLOSE_AT` <= NOW()), 105, 118),
                                                                115),
                                                            IF((`A`.`COLLECTOR_MAX_DECISION2_AT` <= NOW()),
                                                                115,
                                                                111)),
                                                        115),
                                                    111))),
                                        117),
                                    103),
                                116),
                            102),
                        101),
                    IF((`A`.`VISIT_END_AT` <= NOW()),
                        IF((`A`.`PROSPECTIVE_VISITORS` > 0),
                            IF((`A`.`BIDDING_END_AT` <= NOW()),
                                IF((`A`.`BIDDERS` > 0),
                                    IF((`A`.`CLOSE_AT` <= NOW()),
                                        105,
                                        IF((`A`.`COLLECTOR_SELECTION_CONFIRMED` IS NOT NULL),
                                            IF((`A`.`COLLECTOR_SELECTION_CONFIRMED` = TRUE),
                                                IF((`A`.`CLOSE_AT` <= NOW()), 105, 118),
                                                IF((`A`.`BIDDERS` > 1),
                                                    IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` IS NOT NULL),
                                                        IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` = TRUE),
                                                            IF((`A`.`CLOSE_AT` <= NOW()), 105, 118),
                                                            115),
                                                        IF((`A`.`COLLECTOR_MAX_DECISION2_AT` <= NOW()),
                                                            115,
                                                            111)),
                                                    115)),
                                            IF((`A`.`COLLECTOR_MAX_DECISION_AT` <= NOW()),
                                                IF((`A`.`BIDDERS` > 1),
                                                    IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` IS NOT NULL),
                                                        IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` = TRUE),
                                                            IF((`A`.`CLOSE_AT` <= NOW()), 105, 118),
                                                            115),
                                                        IF((`A`.`COLLECTOR_MAX_DECISION2_AT` <= NOW()),
                                                            115,
                                                            111)),
                                                    115),
                                                111))),
                                    117),
                                103),
                            116),
                        102)),
                IF((`A`.`BIDDING_END_AT` <= NOW()),
                    IF((`A`.`BIDDERS` > 0),
                        IF((`A`.`CLOSE_AT` <= NOW()),
                            105,
                            IF((`A`.`COLLECTOR_SELECTION_CONFIRMED` IS NOT NULL),
                                IF((`A`.`COLLECTOR_SELECTION_CONFIRMED` = TRUE),
                                    IF((`A`.`CLOSE_AT` <= NOW()), 105, 118),
                                    IF((`A`.`BIDDERS` > 1),
                                        IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` IS NOT NULL),
                                            IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` = TRUE),
                                                IF((`A`.`CLOSE_AT` <= NOW()), 105, 118),
                                                115),
                                            IF((`A`.`COLLECTOR_MAX_DECISION2_AT` <= NOW()),
                                                115,
                                                111)),
                                        115)),
                                IF((`A`.`COLLECTOR_MAX_DECISION_AT` <= NOW()),
                                    IF((`A`.`BIDDERS` > 1),
                                        IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` IS NOT NULL),
                                            IF((`A`.`COLLECTOR_SELECTION_CONFIRMED2` = TRUE),
                                                IF((`A`.`CLOSE_AT` <= NOW()), 105, 118),
                                                115),
                                            IF((`A`.`COLLECTOR_MAX_DECISION2_AT` <= NOW()),
                                                115,
                                                111)),
                                        115),
                                    111))),
                        117),
                    103))) AS `STATE_CODE`
    FROM
        (((((((`chiumdev_2`.`SITE_WSTE_DISPOSAL_ORDER` `A`
        LEFT JOIN `chiumdev_2`.`V_COMP_SITE` `B` ON ((`A`.`SITE_ID` = `chiumdev_2`.`B`.`COMP_SITE_ID`)))
        LEFT JOIN `chiumdev_2`.`USERS` `C` ON ((`A`.`DISPOSER_ID` = `C`.`ID`)))
        LEFT JOIN `chiumdev_2`.`USERS` `D` ON ((`A`.`MANAGER_ID` = `D`.`ID`)))
        LEFT JOIN `chiumdev_2`.`KIKCD_B` `E` ON ((`A`.`KIKCD_B_CODE` = `E`.`B_CODE`)))
        LEFT JOIN `chiumdev_2`.`V_COMP_SITE` `F` ON ((`A`.`COLLECTOR_ID` = `chiumdev_2`.`F`.`COMP_SITE_ID`)))
        LEFT JOIN `chiumdev_2`.`WSTE_CLCT_TRMT_TRANSACTION` `H` ON ((`A`.`ID` = `H`.`DISPOSAL_ORDER_ID`)))
        JOIN `chiumdev_2`.`sys_policy` `G`)
    WHERE
        ((`G`.`policy` = 'max_selection_duration')
            AND (`H`.`IN_PROGRESS` = TRUE))