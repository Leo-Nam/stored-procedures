CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `chiumdb`@`%` 
    SQL SECURITY DEFINER
VIEW `chiumdev_2`.`V_TRANSACTION_STATE` AS
    SELECT 
        `A`.`ID` AS `TRANSACTION_ID`,
        `A`.`DISPOSAL_ORDER_ID` AS `DISPOSAL_ORDER_ID`,
        `A`.`IN_PROGRESS` AS `IN_PROGRESS`,
        IF((`B`.`CLOSE_AT` <= NOW()),
            211,
            IF((`A`.`VISIT_END_AT` IS NOT NULL),
                IF((`A`.`VISIT_START_AT` IS NOT NULL),
                    IF((`A`.`VISIT_START_AT` <= NOW()),
                        IF((`A`.`VISIT_END_AT` <= NOW()),
                            IF((`A`.`COLLECTOR_REPORTED` IS NOT NULL),
                                IF((`A`.`CONFIRMED` IS NOT NULL),
                                    IF((`A`.`CONFIRMED` = TRUE), 248, 246),
                                    247),
                                221),
                            201),
                        217),
                    IF((`A`.`VISIT_END_AT` <= NOW()),
                        IF((`A`.`COLLECTOR_REPORTED` IS NOT NULL),
                            IF((`A`.`CONFIRMED` IS NOT NULL),
                                IF((`A`.`CONFIRMED` = TRUE), 248, 246),
                                247),
                            221),
                        201)),
                IF((`A`.`COLLECTOR_REPORTED` IS NOT NULL),
                    IF((`A`.`CONFIRMED` IS NOT NULL),
                        IF((`A`.`CONFIRMED` = TRUE), 248, 246),
                        247),
                    221))) AS `TRANSACTION_STATE_CODE`
    FROM
        (`chiumdev_2`.`WSTE_CLCT_TRMT_TRANSACTION` `A`
        LEFT JOIN `chiumdev_2`.`SITE_WSTE_DISPOSAL_ORDER` `B` ON ((`A`.`DISPOSAL_ORDER_ID` = `B`.`ID`)))