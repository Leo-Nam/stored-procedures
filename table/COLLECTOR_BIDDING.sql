CREATE TABLE `COLLECTOR_BIDDING` (
  `ID` bigint NOT NULL,
  `COLLECTOR_ID` bigint NOT NULL COMMENT '수집업체등의 입찰을 신청한 업체 사이트의 고유등록번호(COMP_SIZE.ID)',
  `DISPOSAL_ORDER_ID` bigint NOT NULL COMMENT '폐기물배출요청 고유등록번호로서 SITE_WSTE_DISPOSAL_ORDER.ID',
  `BID_AMOUNT` float DEFAULT NULL COMMENT '총입찰금액(BIDDING_DETAILS의 합계)',
  `TRMT_METHOD` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물처리방법',
  `GREENHOUSE_GAS` float DEFAULT NULL COMMENT '온실가스 총배출량(BIDDING_DETAILS의 온실가스 총합)',
  `WINNER` tinyint DEFAULT NULL COMMENT '입찰순위',
  `ACTIVE` tinyint NOT NULL COMMENT '입찰 취소요청을 하는 경우 FALSE로 변경하고 입찰진행중인 상태에서는 TRUE임',
  `CANCEL_VISIT` tinyint DEFAULT '0' COMMENT '방문취소를 하는 경우 TRUE, 기본값 FALSE',
  `CANCEL_BIDDING` tinyint DEFAULT '0' COMMENT '방문취소를 하는 경우 TRUE, 기본값 FALSE',
  `STATUS_CODE` int DEFAULT NULL COMMENT '상태코드로서 방문을 신청할 때, 입찰신청할 때, 낙찰 될 때 등의 시기에 변경된다.',
  `DATE_OF_VISIT` datetime DEFAULT NULL COMMENT '수거자의 방문예정일',
  `DATE_OF_BIDDING` datetime DEFAULT NULL COMMENT '수거자등의 입찰신청일',
  `SELECTED` tinyint DEFAULT NULL COMMENT '배출자에 의하여 최종선정되면 TRUE, 그렇지 않으면 FALSE',
  `REJECT_DECISION` tinyint DEFAULT NULL COMMENT '배출자의 선정완료 후 수거자가 수락하게 되면 TRUE, 수락하지 않으면 FALSE',
  `RESPONSE_VISIT` tinyint DEFAULT '1' COMMENT '배출자가 수거자의 방문신청을 거절하면 TRUE로 셋팅된다.',
  `REJECT_BIDDING` tinyint DEFAULT NULL COMMENT '배출자가 수거자의 입찰을 거절하는 경우 TRUE로 셋팅된다.',
  `RESPONSE_VISIT_AT` datetime DEFAULT NULL COMMENT '배출자가 수거자의 방문신청을 거절한 일시',
  `REJECT_BIDDING_AT` datetime DEFAULT NULL COMMENT '배출자가 수거자의 입찰을 거절한 일시',
  `SELECTED_AT` datetime DEFAULT NULL COMMENT '배출자에 의하여 최종선정된 일시',
  `REJECTED_AT` datetime DEFAULT NULL COMMENT '수거자가 배출자의 낙찰자 선정에 대한 거절을 할 때의 거절 일시',
  `CREATED_AT` datetime DEFAULT NULL COMMENT '레코드의 최초 생성일',
  `UPDATED_AT` datetime DEFAULT NULL COMMENT '레코드의 최종 변경일',
  PRIMARY KEY (`COLLECTOR_ID`,`DISPOSAL_ORDER_ID`,`ACTIVE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수집운반업체등의 입찰내역 관리 테이블, 입찰상세내역은 BIDDING_DETAILS로 관리함';
