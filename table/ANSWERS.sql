CREATE TABLE `ANSWERS` (
  `ID` bigint NOT NULL AUTO_INCREMENT,
  `USER_ID` bigint DEFAULT NULL COMMENT '사용자 아이디(USERS.ID)로서 회원만 사용가능',
  `ANSWER` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '문의하기에 대한 답변',
  `CREATED_AT` datetime DEFAULT NULL COMMENT '작성일자',
  `UPDATED_AT` datetime DEFAULT NULL COMMENT '최종변경일시',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='문의하기에 대한 답변';
