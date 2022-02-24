CREATE TABLE `USER_TYPE` (
  `ID` int NOT NULL,
  `TYPE_EN` enum('emitter','collector','system') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `TYPE_KO` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자 타입';
