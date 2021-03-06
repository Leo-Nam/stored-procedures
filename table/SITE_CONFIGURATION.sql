CREATE TABLE `SITE_CONFIGURATION` (
  `ID` bigint NOT NULL AUTO_INCREMENT,
  `SITE_ID` bigint DEFAULT NULL,
  `NOTICE` tinyint DEFAULT '1',
  `PUSH` tinyint DEFAULT '1',
  `COLLECTOR` tinyint DEFAULT '0',
  `CREATED_AT` datetime DEFAULT NULL,
  `UPDATED_AT` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='개별 사이트의 환경설정 관리 테이블';
