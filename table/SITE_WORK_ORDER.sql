CREATE TABLE `SITE_WORK_ORDER` (
  `ID` bigint NOT NULL AUTO_INCREMENT COMMENT '작업지시서 고유등록번호 AUTO_INCREMENT',
  `REGISTER_ID` bigint DEFAULT NULL COMMENT '등록자 아이디(USERS.ID)',
  `SITE_ID` bigint DEFAULT NULL COMMENT '작업지시서가 등록된 사이트의 고유등록번호(COMP_SITE.ID)',
  `ACTIVE` tinyint DEFAULT NULL,
  `WORK_ORDER_TITLE` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '작업지시서의 타이틀',
  `CONTENTS` text COLLATE utf8mb4_unicode_ci COMMENT '작업지시서의 내용으로서 차후 내용을 별도의 파일로 저장하고 파일의 저장경로를 테이블에 대신 저장하는 방식으로 변경할 계획임',
  `CREATED_AT` datetime DEFAULT NULL COMMENT '작업지시서의 최초 작성일',
  `UPDATED_AT` datetime DEFAULT NULL COMMENT '작업지시서의 최종 변경일',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사이트에서 배출되는 폐기물을 처리하기 위한 작업지시서 관리테이블';
