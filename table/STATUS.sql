CREATE TABLE `STATUS` (
  `ID` int NOT NULL,
  `USER_TYPE` int DEFAULT NULL,
  `STATUS_NM_KO` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `STATUS_NM_EN` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `PID` int DEFAULT '0',
  `ACTIVE` tinyint DEFAULT '1',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상태 정의 테이블';
