CREATE TABLE `COMPANY` (
  `ID` bigint NOT NULL COMMENT '사업자의 고유등록번호',
  `COMP_NAME` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '사업자 등록증에 기재된 상호',
  `REP_NAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '사업자 등록증에 기재된 대표자 이름',
  `KIKCD_B_CODE` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '사업자 등록증에 기재된 사무소 소재지 주소에 대한 시군구 법정코드 10자리',
  `ADDR` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '사업자 등록증에 기재된 주소에서 시군구 이하 상세 주소',
  `CONTACT` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '사업자 소재지에 있는 전화번호',
  `PERMIT_DT` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '허가 또는 사업자 등록일',
  `RETURN_DT` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '사업자 등록 말소 또는 허가 만료일',
  `NOTE` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '비고',
  `TRMT_BIZ_CODE` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '사업자의 사업분류코드로서 WSTE_TRMT_BIZ.ID 값임',
  `LAT` decimal(12,9) DEFAULT NULL COMMENT '사업자 소재지의 위도값',
  `LNG` decimal(12,9) DEFAULT NULL COMMENT '사업자 소재지의 경도값',
  `BIZ_REG_CODE` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '사업자등록번호',
  `PERMIT_REG_CODE` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '허가증 또는 신고증명서의 등의 발급번호',
  `ACTIVE` tinyint DEFAULT '1' COMMENT '사업자의 활성화 상태로서 1인 경우는 활성화 된 상태이며 0인 경우에는 사업자 삭제 등의 사유로 비활성화 된 상태임',
  `P_COMP_ID` bigint DEFAULT '0' COMMENT '자회사의 경우 모회사의 고유등록번호로서 COMPANY.ID값임',
  `BIZ_REG_IMG_PATH` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '사업자등록증 이미지 저장 경로',
  `PERMIT_REG_IMG_PATH` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '허가증 또는 신고증명서 등의 이미지 저장 경로',
  `CS_MANAGER_ID` bigint DEFAULT NULL COMMENT 'sys.admin 중에서 사업자에 대한 최종 승인을 한 관리자의 아이디로서 USERS.ID값임',
  `CONFIRMED` tinyint DEFAULT '0' COMMENT 'CHECKER_ID에 의하여 등록 승인 완료된 경우에는 1값을 가지며, 그렇지 않은 경우에는 0값을 가지게 됨',
  `CONFIRMED_AT` datetime DEFAULT NULL COMMENT 'CHECKER_ID에 의한 사업자 최종 승인일시',
  `CREATED_AT` datetime DEFAULT NULL COMMENT '레코드의 생성일시',
  `UPDATED_AT` datetime DEFAULT NULL COMMENT '레코드의 최종 변경일시',
  `RECOVERY_TAG` datetime DEFAULT NULL,
  PRIMARY KEY (`BIZ_REG_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
