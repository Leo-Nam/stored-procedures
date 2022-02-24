CREATE TABLE `sys_table_info_related_to_stored_proc` (
  `ID` bigint NOT NULL AUTO_INCREMENT COMMENT '1',
  `SP_NAME` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `TABLE_NAME` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='sp와 관련된 테이블에 대한 정보';
