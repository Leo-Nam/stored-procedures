CREATE TABLE `WSTE_REGISTRATION_PHOTO` (
  `ID` bigint NOT NULL AUTO_INCREMENT,
  `DISPOSAL_ORDER_ID` bigint DEFAULT NULL COMMENT '폐기물 고유등록코드로서 SITE_WSTE_DISPOSAL_ORDER.ID',
  `FILE_NAME` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IMG_PATH` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '사진이 저정된 경로',
  `FILE_SIZE` float DEFAULT NULL,
  `ACTIVE` tinyint DEFAULT NULL COMMENT '사진의 상태로서 TRUE이면 사용 및 참조가능, FALSE면 삭제된 상태(물리적으로 데이타베이스에서 정보를 삭제하지는 않음)',
  `CLASS_CODE` enum('입찰','처리') COLLATE utf8mb4_unicode_ci DEFAULT '입찰',
  `CREATED_AT` datetime DEFAULT NULL COMMENT '사진최초등록일',
  `UPDATED_AT` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=237 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='폐기물 등록사진';
