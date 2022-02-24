CREATE TABLE `WDSCM_PIC_MATCH` (
  `ID` bigint NOT NULL AUTO_INCREMENT COMMENT '등록된 사진의 고유등록번호 AUTO_INCREMENT적용',
  `WDSCM_ID` bigint NOT NULL COMMENT 'WSTE_DISPOSAL_SITE_COLLECTOR_MATCH.ID',
  `IMG_PATH` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '사진이 등록된 경로',
  `FILE_NAME` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '업로드한 파일 이름으로서 파일 이름은 애플리케이션에 의해서 만들어진 이름을 사용할 것임',
  `FILE_EXT` enum('JPG','JPEG','PNG','BMP','GIF') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '파일의 확장자',
  `IMG_SIZE` float NOT NULL DEFAULT '0' COMMENT '업로드한 사진의 파일사이즈로서 MB단위로 표시',
  `REGISTER_ID` bigint NOT NULL COMMENT '사진 등록자의 사용자 아이디(USERS.ID)',
  `ACTIVE` tinyint NOT NULL DEFAULT '1' COMMENT '사진의 상태로서 사용자가 이 사진을 삭제하는 경우에는 0 값으로 변경해야 함',
  `CREATED_AT` datetime NOT NULL COMMENT '사진이 등록된 일시',
  `UPDATED_AT` datetime NOT NULL COMMENT '사진의 상태가 변경된 일시',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='WSTE_DISPOSAL_SITE_COLLECTION_MATCH의 폐기물배출지(SITE)와 수거자(COLLECTOR)의 관계만 설정되었으며 배출자는 해당 폐기물배출지(SITE)를 위한 1 이상의 폐기물 사진을 등록하기 위하여 이 테이블을 사용하도록 한다. 배출지(SITE)와 배출자의 등록사진의 관계는 1:N의 관계가 성립한다.\n등록가능한 사진의 개수는 정책적으로 결정할 필요가 있으며 해당 정책의 내용은 sys_policy에서 정의되어 있음';
