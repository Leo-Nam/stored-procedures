CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_BIDDING_STATE` AS
    SELECT 
        `A`.`ID` AS `COLLECTOR_BIDDING_ID`,
        `B`.`ID` AS `DISPOER_ORDER_ID`,
        `A`.`COLLECTOR_ID` AS `COLLECTOR_ID`,
        IF((`B`.`IS_DELETED` = TRUE),
            214,
            IF((`B`.`VISIT_END_AT` IS NOT NULL),
                IF((`A`.`DATE_OF_VISIT` IS NOT NULL),
                    IF((`A`.`CANCEL_VISIT` = TRUE),
                        202,
                        IF((`A`.`RESPONSE_VISIT` IS NOT NULL),
                            IF((`A`.`RESPONSE_VISIT` = TRUE),
                                IF((`A`.`DATE_OF_BIDDING` IS NOT NULL),
                                    IF((`A`.`CANCEL_BIDDING` = TRUE),
                                        IF((`B`.`VISIT_END_AT` <= NOW()),
                                            207,
                                            254),
                                        IF((`B`.`VISIT_END_AT` <= NOW()),
                                            IF((`A`.`REJECT_BIDDING` = TRUE),
                                                231,
                                                IF((`B`.`BIDDING_END_AT` <= NOW()),
                                                    IF((`B`.`FIRST_PLACE` = `A`.`ID`),
                                                        IF((`B`.`SELECTED` = `A`.`ID`),
                                                            IF((`A`.`MAKE_DECISION` IS NOT NULL),
                                                                IF((`A`.`MAKE_DECISION` = TRUE),
                                                                    IF((`B`.`CLOSE_AT` <= NOW()), 218, 212),
                                                                    239),
                                                                IF((`A`.`MAX_DECISION_AT` <= NOW()),
                                                                    214,
                                                                    236)),
                                                            IF((`B`.`MAX_SELECT_AT` <= NOW()),
                                                                214,
                                                                236)),
                                                        IF((`B`.`SECOND_PLACE` = `A`.`ID`),
                                                            IF((`B`.`SELECTED` > 0),
                                                                IF((`B`.`COLLECTOR_SELECTION_CONFIRMED` IS NOT NULL),
                                                                    IF((`B`.`COLLECTOR_SELECTION_CONFIRMED` = TRUE),
                                                                        213,
                                                                        IF((`A`.`MAKE_DECISION` IS NOT NULL),
                                                                            IF((`A`.`MAKE_DECISION` = TRUE),
                                                                                IF((`B`.`CLOSE_AT` <= NOW()), 218, 212),
                                                                                239),
                                                                            IF((`A`.`MAX_DECISION_AT` <= NOW()),
                                                                                239,
                                                                                245))),
                                                                    IF((`B`.`COLLECTOR_MAX_DECISION_AT` <= NOW()),
                                                                        IF((`A`.`MAKE_DECISION` IS NOT NULL),
                                                                            IF((`A`.`MAKE_DECISION` = TRUE),
                                                                                IF((`B`.`CLOSE_AT` <= NOW()), 218, 212),
                                                                                239),
                                                                            IF((`A`.`MAX_DECISION_AT` <= NOW()),
                                                                                239,
                                                                                245)),
                                                                        245)),
                                                                IF((`B`.`MAX_SELECT_AT` <= NOW()),
                                                                    213,
                                                                    245)),
                                                            213)),
                                                    206)),
                                            253)),
                                    IF((`B`.`VISIT_END_AT` <= NOW()),
                                        IF((`A`.`GIVEUP_BIDDING` = TRUE),
                                            244,
                                            IF((`A`.`DATE_OF_BIDDING` IS NOT NULL),
                                                IF((`A`.`CANCEL_BIDDING` = TRUE),
                                                    207,
                                                    IF((`A`.`REJECT_BIDDING` = TRUE),
                                                        231,
                                                        IF((`B`.`BIDDING_END_AT` <= NOW()),
                                                            IF((`B`.`FIRST_PLACE` = `A`.`ID`),
                                                                IF((`B`.`SELECTED` = `A`.`ID`),
                                                                    IF((`A`.`MAKE_DECISION` IS NOT NULL),
                                                                        IF((`A`.`MAKE_DECISION` = TRUE),
                                                                            IF((`B`.`CLOSE_AT` <= NOW()), 218, 212),
                                                                            239),
                                                                        IF((`A`.`MAX_DECISION_AT` <= NOW()),
                                                                            214,
                                                                            236)),
                                                                    IF((`B`.`MAX_SELECT_AT` <= NOW()),
                                                                        214,
                                                                        236)),
                                                                IF((`B`.`SECOND_PLACE` = `A`.`ID`),
                                                                    IF((`B`.`SELECTED` > 0),
                                                                        IF((`B`.`COLLECTOR_SELECTION_CONFIRMED` IS NOT NULL),
                                                                            IF((`B`.`COLLECTOR_SELECTION_CONFIRMED` = TRUE),
                                                                                213,
                                                                                IF((`A`.`MAKE_DECISION` IS NOT NULL),
                                                                                    IF((`A`.`MAKE_DECISION` = TRUE),
                                                                                        IF((`B`.`CLOSE_AT` <= NOW()), 218, 212),
                                                                                        239),
                                                                                    IF((`A`.`MAX_DECISION_AT` <= NOW()),
                                                                                        239,
                                                                                        245))),
                                                                            IF((`B`.`COLLECTOR_MAX_DECISION_AT` <= NOW()),
                                                                                IF((`A`.`MAKE_DECISION` IS NOT NULL),
                                                                                    IF((`A`.`MAKE_DECISION` = TRUE),
                                                                                        IF((`B`.`CLOSE_AT` <= NOW()), 218, 212),
                                                                                        239),
                                                                                    IF((`A`.`MAX_DECISION_AT` <= NOW()),
                                                                                        239,
                                                                                        245)),
                                                                                245)),
                                                                        IF((`B`.`MAX_SELECT_AT` <= NOW()),
                                                                            213,
                                                                            245)),
                                                                    213)),
                                                            206))),
                                                IF((`B`.`BIDDING_END_AT` <= NOW()),
                                                    238,
                                                    224))),
                                        201)),
                                203),
                            IF((`B`.`VISIT_END_AT` <= NOW()),
                                203,
                                222))),
                    IF((`B`.`VISIT_END_AT` <= NOW()),
                        230,
                        204)),
                IF((`A`.`DATE_OF_BIDDING` IS NOT NULL),
                    IF((`A`.`GIVEUP_BIDDING` = TRUE),
                        244,
                        IF((`A`.`DATE_OF_BIDDING` IS NOT NULL),
                            IF((`A`.`CANCEL_BIDDING` = TRUE),
                                207,
                                IF((`A`.`REJECT_BIDDING` = TRUE),
                                    231,
                                    IF((`B`.`BIDDING_END_AT` <= NOW()),
                                        IF((`B`.`FIRST_PLACE` = `A`.`ID`),
                                            IF((`B`.`SELECTED` = `A`.`ID`),
                                                IF((`A`.`MAKE_DECISION` IS NOT NULL),
                                                    IF((`A`.`MAKE_DECISION` = TRUE),
                                                        IF((`B`.`CLOSE_AT` <= NOW()), 218, 212),
                                                        239),
                                                    IF((`A`.`MAX_DECISION_AT` <= NOW()),
                                                        214,
                                                        236)),
                                                IF((`B`.`MAX_SELECT_AT` <= NOW()),
                                                    214,
                                                    236)),
                                            IF((`B`.`SECOND_PLACE` = `A`.`ID`),
                                                IF((`B`.`SELECTED` > 0),
                                                    IF((`B`.`COLLECTOR_SELECTION_CONFIRMED` IS NOT NULL),
                                                        IF((`B`.`COLLECTOR_SELECTION_CONFIRMED` = TRUE),
                                                            213,
                                                            IF((`A`.`MAKE_DECISION` IS NOT NULL),
                                                                IF((`A`.`MAKE_DECISION` = TRUE),
                                                                    IF((`B`.`CLOSE_AT` <= NOW()), 218, 212),
                                                                    239),
                                                                IF((`A`.`MAX_DECISION_AT` <= NOW()),
                                                                    239,
                                                                    245))),
                                                        IF((`B`.`COLLECTOR_MAX_DECISION_AT` <= NOW()),
                                                            IF((`A`.`MAKE_DECISION` IS NOT NULL),
                                                                IF((`A`.`MAKE_DECISION` = TRUE),
                                                                    IF((`B`.`CLOSE_AT` <= NOW()), 218, 212),
                                                                    239),
                                                                IF((`A`.`MAX_DECISION_AT` <= NOW()),
                                                                    239,
                                                                    245)),
                                                            245)),
                                                    IF((`B`.`MAX_SELECT_AT` <= NOW()),
                                                        213,
                                                        245)),
                                                213)),
                                        206))),
                            IF((`B`.`BIDDING_END_AT` <= NOW()),
                                238,
                                224))),
                    206))) AS `STATE_CODE`
    FROM
        (`chium`.`COLLECTOR_BIDDING` `A`
        LEFT JOIN `chium`.`SITE_WSTE_DISPOSAL_ORDER` `B` ON ((`A`.`DISPOSAL_ORDER_ID` = `B`.`ID`)))