CREATE TABLE `SITE_WSTE_REGISTRATION` (
  `ID` bigint NOT NULL AUTO_INCREMENT COMMENT '폐기물 발생 고유등록번로서 AUTO_INCREMENT',
  `SITE_ID` bigint DEFAULT NULL COMMENT '폐기물이 발생한 사이트의 아이디로서 COMP_SITE.ID',
  `CREATOR_ID` bigint DEFAULT NULL COMMENT '폐기물 등록자 아이디로서 USERS.ID',
  `KIKCD_B_CODE` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물 배출지의 시군구코드 KIKCD_B.B_CODE',
  `ADDR` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '폐기물 배출지 상세주소',
  `WORK_ORDER_ID` bigint DEFAULT NULL COMMENT '작업지시서 고유등록번호(WORK_ORDER.ID)로서 현재는 NULL값이나 차후 작업지시서를 사용할 수 있는 웹버전에서 활성화할 계획임',
  `LAST_VISIT_AT` datetime DEFAULT NULL COMMENT '방문예정마감일',
  `CREATED_AT` datetime DEFAULT NULL COMMENT '레코드 최초 생성일',
  `UPDATED_AT` datetime DEFAULT NULL COMMENT '레코드 최종 변경일',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='배출지(사이트)별로 등록되는 폐기물에 대한 정보. 등록되는 사진은 별도의 테이블(WSTE_REGISTRATION_PHOTO)에서 이 테이블의 ID를 FOREIGN KEY로 등록되며 연결된 VIEW는 V_SITE_WSTE_REGISTRATION)를 통하여 사용가능함';
