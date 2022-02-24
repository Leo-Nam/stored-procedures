CREATE TABLE `POSTS` (
  `ID` bigint NOT NULL AUTO_INCREMENT COMMENT '고유등록번호',
  `SITE_ID` bigint DEFAULT NULL COMMENT '게시판 소유자(COMP_SITE.ID)',
  `CREATOR_ID` bigint NOT NULL COMMENT '게시자의 고유등록번호(USERS.ID)',
  `SUBJECTS` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '제목',
  `CONTENTS` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '내용',
  `CATEGORY` int DEFAULT NULL COMMENT '게시판의 종류 (1: 공지사항, 2: 업무게시판)',
  `VISITORS` int DEFAULT NULL,
  `PID` bigint DEFAULT '0' COMMENT '원글인 경우 0, 댓글인 경우에는 원글의 등록번호',
  `CREATED_AT` datetime DEFAULT NULL COMMENT '생성일자',
  `UPDATED_AT` datetime DEFAULT NULL COMMENT '최종변경일자',
  PRIMARY KEY (`ID`,`CREATOR_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='공지사항';
