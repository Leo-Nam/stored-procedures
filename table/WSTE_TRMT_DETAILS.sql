CREATE TABLE `WSTE_TRMT_DETAILS` (
  `ID` bigint NOT NULL AUTO_INCREMENT,
  `CREATOR_ID` bigint DEFAULT NULL COMMENT '폐기물처리정보 생성 관리자의 고유등록번호(USERS.ID)',
  `DISPOSAL_ORDER_ID` bigint DEFAULT NULL COMMENT 'DISPOSAL_ORDER.ID',
  `WSTE_CODE` varchar(8) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물코드',
  `WSTE_QUANTITY` float DEFAULT NULL COMMENT '폐기물처리량',
  `WSTE_UNIT` enum('kg','m3') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물처리단위',
  `UNIT_PRICE` float DEFAULT NULL COMMENT '폐기물처리단가',
  `WSTE_TRMT_METHOD_CODE` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물처리방법코드(WSTE_TRMT_METHOD.CODE)',
  `CREATED_AT` datetime DEFAULT NULL COMMENT '레코드 최초생성일',
  `UPDATED_AT` datetime DEFAULT NULL COMMENT '레코드 최종변경일',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='폐기물처리내역 상세정보';
