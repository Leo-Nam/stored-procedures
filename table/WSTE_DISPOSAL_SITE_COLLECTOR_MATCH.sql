CREATE TABLE `WSTE_DISPOSAL_SITE_COLLECTOR_MATCH` (
  `ID` bigint NOT NULL AUTO_INCREMENT COMMENT 'AUTO INCREMENT NUMBER로서 SITE-COLLECTOR의 고유등록번호로 사용됨',
  `SITE_ID` bigint NOT NULL COMMENT '배출지에 대한 고유등록번호(WSTE_DISPOSAL_SITE.ID)임',
  `COLLECTOR_ID` bigint NOT NULL COMMENT '수거자에 대한 고유등록번호(SITE.ID)임',
  `ACTIVE` tinyint NOT NULL DEFAULT '1' COMMENT '폐기물 배출지(SITE)와 수거자(COLLECTOR)의 업무관계의 종료등의 사유로 인하여 관계가 유효하지 않게 되는 경우에 이 값을 FALSE로 셋팅하고 관계가 유효한 경우에는 TRUE로 셋팅한다. \n이 값이 TRUE인 레코드의 수를 파악하게 되면 해당 시점에 폐기물 배출 작업이 실제로 진행되고 있는 SITE의 개소수를 파악할 수 있다.\n이 값은 sys.admin과 COLLECTOR의 관리자(manager.admin:201)만이 수정할 수 있다.',
  `CREATED_AT` datetime NOT NULL COMMENT '폐기물 배출지와 해당 배출지에 대한 폐기물 수거자의 관계가 성립된 일시',
  `UPDATED_AT` datetime NOT NULL COMMENT '테이블의 정보가 변경된 일시',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='폐기물 배출지 사이트(SITE)와 수거자(COLLECTOR)의 관계를 저장하는 테이블로서 SITE와 COLLECTOR는 1:N의 관계가 성립된다. COLLECTOR가 수거하는 폐기물의 종류는 사이트에서 발생하는 여러종류의 폐기물 중에서 1종류 이상의 폐기물에 대한 수거가 가능하므로 폐기물배출지(SITE)와 수거대상 폐기물의 종류(WSTE_CLS)는 1:N의 관계로 별도의 테이블(WDSCM_WSTE_MATCH)에서 관리하도록 한다.';
