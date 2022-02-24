CREATE TABLE `WSTE_CLS_1` (
  `ID` int NOT NULL COMMENT '폐기물 고유등록번호로서 WSTE_CODE.CODE_1에서 사용됨',
  `CLASS_NAME` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물 대분류명(시스템 사용용도)',
  `ACTIVE` tinyint DEFAULT NULL COMMENT '활성상태',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='폐기물의 대분류';
