CREATE TABLE `CREATE TABLE `BIDDING_DETAILS` (
  `ID` bigint NOT NULL AUTO_INCREMENT,
  `COLLECTOR_BIDDING_ID` bigint DEFAULT NULL COMMENT '입찰자(수거업체 등)의 입찰고유등록번호(COLLECTOR_BIDDING.ID)',
  `WSTE_CODE` varchar(8) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물 분류코드(WSTE_CODE.ID)',
  `UNIT` enum('Kg','m3') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '단위',
  `UNIT_PRICE` int DEFAULT NULL COMMENT '단가',
  `VOLUME` float NOT NULL DEFAULT '1',
  `TRMT_CODE` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물처리방법',
  `ACTIVE` tinyint DEFAULT NULL,
  `GREENHOUSE_GAS` float DEFAULT NULL COMMENT '온실가스배출량',
  `CREATED_AT` datetime DEFAULT NULL,
  `UPDATED_AT` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수집업자 등의 입찰신청에 대한 상세내역 관리테이블';
` (
  `ID` bigint NOT NULL COMMENT '고유등록번호로서 PK가 아니기때문에 AUTO INCREMENT 기능을 로직으로 만들어야 한다.',
  `DISPOSAL_ORDER_ID` bigint NOT NULL COMMENT '폐기물배출요청 고유등록번호로서 SITE_WSTE_DISPOSAL_ORDER.ID',
  `ASKER_ID` bigint NOT NULL COMMENT '방문요청을 하는 사이트의 고유등록번호(COMP_SITE.ID)',
  `ACTIVE` tinyint NOT NULL DEFAULT '1' COMMENT '방문 취소요청을 하는 경우 FALSE로 변경하고 입찰자의 방문이 유효한 경우에는 TRUE로 셋팅한다.',
  `VISIT_END_AT` datetime DEFAULT NULL COMMENT '방문요청을 하는 사업자가 지정한 방문예정일',
  `CONFIRMED` tinyint NOT NULL DEFAULT '0' COMMENT '방문일정이 종료된 이후 방문사실이 있는 경우에는 TRUE, 그렇지 않으면 FALSE 처리됨. 방문사실에 대한 확인 프로세스가 QR등의 방법으로 쳬계화 되기전까지는 방문신청한자는 방문마감일이 도래되면 자동으로 방문한 것으로 임시처리 할 것임',
  `CREATED_AT` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '레코드의 최초 생성일',
  `UPDATED_AT` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '레코드의 최종 변경일',
  PRIMARY KEY (`DISPOSAL_ORDER_ID`,`ASKER_ID`,`ACTIVE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='입찰자의 배출지 방문 예정일정 관리 테이블';
