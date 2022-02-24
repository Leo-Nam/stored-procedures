CREATE TABLE `QUEST_CLASS` (
  `ID` int NOT NULL,
  `CLASS_NM` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '문의하기 유형',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='문의하기 유형';
