CREATE TABLE `COMP_SITE` (
  `ID` bigint NOT NULL COMMENT '사이트의 고유등록번호',
  `COMP_ID` bigint NOT NULL COMMENT '사이트가 소속된 사업자의 고유등록번호',
  `KIKCD_B_CODE` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '사이트가 소재하는 주소의 시군구코드(KIKCD_B_CODE)',
  `ADDR` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '사이트가 소재하는 주소의 시군구 주소를 제외한 상세주소',
  `CONTACT` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `LAT` decimal(12,9) DEFAULT NULL,
  `LNG` decimal(12,9) DEFAULT NULL,
  `SITE_NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '개설 사이트 이름',
  `ACTIVE` tinyint NOT NULL DEFAULT '1' COMMENT '사이트의 활성화 상태로서 1인 경우 활성화 되어 있는 경우이고 0인 경우에는 비활성화되어 있는 상태임',
  `TRMT_BIZ_CODE` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CREATOR_ID` bigint NOT NULL COMMENT '사이트를 개설한 사용자 아이디(USERS.ID)',
  `HEAD_OFFICE` tinyint NOT NULL,
  `PERMIT_REG_CODE` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `PERMIT_REG_IMG_PATH` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CS_MANAGER_ID` bigint DEFAULT NULL,
  `CONFIRMED` tinyint DEFAULT NULL,
  `CONFIRMED_AT` datetime DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL COMMENT '사이트 개설일시',
  `UPDATED_AT` datetime NOT NULL COMMENT '사이트 정보 최종 변경일시',
  `RECOVERY_TAG` datetime DEFAULT NULL,
  `PUSH_ENABLED` tinyint DEFAULT NULL COMMENT '푸시알림설정으로서 1이면 푸시알림 ON, 0이면 푸시알림 OFF',
  `NOTICE_ENABLED` tinyint DEFAULT '0',
  `LICENSE_CONFIRMED` tinyint DEFAULT '0' COMMENT '허가증 확인여부',
  `LICENSE_CONFIRMED_AT` datetime DEFAULT NULL COMMENT '허가증 확인일자',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='동일한 사업자는 다수의 사이트를 개설할 수 있다.\\\\n사업자가 최초로 등록되는 경우 등록되는 사업자의 주소지를 사이트 주소지로 하는 사이트를 기본적으로 생성하게 된다.\\\\n이런 경우에 SITE_NAME, KIKCD_B_CODE_ADDR은 기본값으로서 사업자와 동일하게 입력되고 차후 환경설정을 통하여 사업자의 관리자 또는 사이트의 관리자가SITE_NAME, KIKCD_B_CODE, ADDR을 변경할 수 있다.\\\\nSITE의 CREATOR_ID는 SITE를 개설하는 사용자의 고유등록번호가 입력된다.\\\\n기본 사이트를 제외한 추가 사이트가 생성되는 경우에는 사이트 생성자 및 사업자의 관리자가 사이트의 SITE_NAME, KIKCD_B_CODE_ADDR 값을 변경할 수 있다.\\n2개 이상의 사이트를 개설할 수 있는 사업자군은 배출자에 한정된다.'