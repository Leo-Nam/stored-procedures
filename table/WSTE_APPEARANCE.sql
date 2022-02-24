CREATE TABLE `WSTE_APPEARANCE` (
  `ID` int NOT NULL COMMENT '폐기물 성상 코드',
  `KOREAN` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물성상 한글이름(고상, 액상)',
  `ENGLISH` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물성상 영어이름(solid, liquid)',
  `ACTIVE` tinyint DEFAULT NULL COMMENT '활성화 상태',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='폐기물 성상구분';
