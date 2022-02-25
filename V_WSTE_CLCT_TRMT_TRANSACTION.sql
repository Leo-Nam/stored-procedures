CREATE 
	ALGORITHM=UNDEFINED 
    DEFINER=`chiumdb`@`%` 
    SQL SECURITY DEFINER 
VIEW `chiumdev_2`.`V_WSTE_CLCT_TRMT_TRANSACTION` AS 
	select 
		`A`.`ID` AS `TRANSACTION_ID`,
        `A`.`DISPOSAL_ORDER_ID` AS `DISPOSER_ORDER_ID`,
        `A`.`COLLECTOR_BIDDING_ID` AS `COLLECTOR_BIDDING_ID`,
        `chiumdev_2`.`E`.`COLLECTOR_ID` AS `COLLECTOR_SITE_ID`,
        `chiumdev_2`.`E`.`COLLECTOR_SITE_NAME` AS `COLLECTOR_SITE_NAME`,
        `chiumdev_2`.`E`.`WSTE_DISPOSED_SI_DO` AS `DISPOSER_SI_DO`,
        `chiumdev_2`.`E`.`WSTE_DISPOSED_SI_GUN_GU` AS `DISPOSER_SI_GUN_GU`,
        `chiumdev_2`.`E`.`WSTE_DISPOSED_EUP_MYEON_DONG` AS `DISPOSER_EUP_MYEON_DONG`,
        `chiumdev_2`.`E`.`WSTE_DISPOSED_DONG_RI` AS `DISPOSER_DONG_RI`,
        `chiumdev_2`.`E`.`WSTE_DISPOSED_ADDR` AS `DISPOSER_ADDR`,
        `chiumdev_2`.`E`.`WSTE_DISPOSED_KIKCD_B_CODE` AS `DISPOSER_KIKCD_B_CODE`,
        `chiumdev_2`.`E`.`COLLECTOR_ID` AS `DISPOSER_ORDER_COLLECTOR_ID`,
        `chiumdev_2`.`E`.`DISPOSER_OPEN_AT` AS `DISPOSER_OPEN_AT`,
        `chiumdev_2`.`E`.`DISPOSER_CLOSE_AT` AS `DISPOSER_CLOSE_AT`,
        `chiumdev_2`.`E`.`DISPOSER_ORDER_CODE` AS `DISPOSER_ORDER_CODE`,
        `A`.`ASKER_ID` AS `ASKER_ID`,
        `chiumdev_2`.`C`.`AFFILIATED_SITE` AS `DISPOSER_SITE_ID`,
        `chiumdev_2`.`C`.`SITE_NAME` AS `DISPOSER_SITE_NM`,
        `A`.`COLLECT_ASK_END_AT` AS `COLLECT_ASK_END_AT`,
        `A`.`COLLECTING_TRUCK_ID` AS `COLLECTING_TRUCK_ID`,
        `A`.`TRUCK_DRIVER_ID` AS `TRUCK_DRIVER_ID`,
        `A`.`TRUCK_START_AT` AS `TRUCK_START_AT`,
        `A`.`COLLECT_END_AT` AS `COLLECT_END_AT`,
        `A`.`WSTE_CODE` AS `WSTE_CODE`,
        `B`.`WSTE_CLASS` AS `WSTE_CLASS`,
        `B`.`NAME` AS `WSTE_NM`,
        `A`.`WSTE_QUANTITY` AS `WSTE_QUANTITY`,
        `A`.`WSTE_UNIT` AS `WSTE_UNIT`,
        `A`.`PRICE_UNIT` AS `PRICE_UNIT`,
        `A`.`TRMT_METHOD_CODE` AS `TRMT_METHOD_CODE`,
        `D`.`NAME` AS `TRMT_METHOD_NM`,
        `A`.`CONTRACT_ID` AS `CONTRACT_ID`,
        `A`.`CONFIRMER_ID` AS `CONFIRMER_ID`,
        `A`.`CONFIRMED_AT` AS `CONFIRMED_AT`,
        `A`.`DATE_OF_VISIT` AS `DATE_OF_VISIT`,
        `A`.`VISIT_START_AT` AS `VISIT_START_AT`,
        `A`.`VISIT_END_AT` AS `VISIT_END_AT`,
        `A`.`CREATED_AT` AS `CREATED_AT`,
        `A`.`UPDATED_AT` AS `UPDATED_AT`,
        if((`A`.`CONFIRMED_AT` is not null),
			'처리완료',
            if((`A`.`VISIT_END_AT` is not null),
				if((`A`.`VISIT_END_AT` > now()),
					'방문대기중',
                    '처리중'
				),
                '처리중'
			)
		) AS `TRANSACTION_STATE` 
        from ((((`chiumdev_2`.`WSTE_CLCT_TRMT_TRANSACTION` `A` 
			left join `chiumdev_2`.`WSTE_CODE` `B` on((`A`.`WSTE_CODE` = `B`.`CODE`))) 
            left join `chiumdev_2`.`V_USERS` `C` on((`A`.`ASKER_ID` = `chiumdev_2`.`C`.`ID`))) 
            left join `chiumdev_2`.`WSTE_TRMT_METHOD` `D` on((`A`.`TRMT_METHOD_CODE` = `D`.`CODE`))) 
            left join `chiumdev_2`.`V_SITE_WSTE_DISPOSAL_ORDER` `E` on((`A`.`DISPOSAL_ORDER_ID` = `chiumdev_2`.`E`.`DISPOSER_ORDER_ID`)))