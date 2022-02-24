CREATE TABLE `WDSCM_WSTE_MATCH` (
  `ID` bigint NOT NULL COMMENT '이 칼럼은 고유등록번호로 사용되지만 PK로 정의할 수 없으므로 AUTO_INCREMENT를 할 수 없고 별도의 기능을 부여하여 AUTO_INCREMENT의 효과를 만들어야 한다.',
  `CREATOR_ID` bigint DEFAULT NULL COMMENT '데이타 생성자(USERS.ID)',
  `WDSCM_ID` bigint NOT NULL COMMENT 'WSTE_DISPOSAL_SITE_COLLECTION_MATCH의 폐기물배출지(SITE)와 수거자(COLLECTOR)의 관계에 대한 고유등록번호로서 WSTE_DISPOSAL_SITE_COLLECTION_MATCH.ID를 참조함',
  `WSTE_CODE` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '실제 수거완료된 폐기물의 종류로서 WSTE_CODE.CODE를 참조하게 되며 NULL값은 업음. 최소한 대분류(지정폐기물:1, 사업장폐기물:2, 생활폐기물:3)는 해야 함.',
  `UNIT` enum('Kg','Ton','M3','Set') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Ton' COMMENT '폐기물의 배출단위로서 ''Kg'', ''Ton'', ''M3'', ''Set'' 중 하나를 선택할 수 있다.',
  `QTY` float NOT NULL DEFAULT '0' COMMENT '단위가 식(Set)인 경우에는 이 값을 0으로 처리한다.',
  `UNIT_PRICE_TRANPORT` float DEFAULT '0' COMMENT '폐기물 운반단가',
  `UNIT_PRICE_PROCESS` float DEFAULT '0' COMMENT '폐기물 처리단가',
  `UNIT_PRICE_SUM` float DEFAULT '0' COMMENT '운반단가(UNIT_PRICE_TRANPORT)와 처리단가(UNIT_PRICE_PROCESS)가 모두 입력되지 않은 경우에는 이 값은 화면에서 입력되는 값으로 강제 입력되고 그렇지 않은 경우에는 단가의 합계(UNIT_PRICE_SUM) = 운반단가(UNIT_PRICE_TRANPORT) + 처리단가(UNIT_PRICE_PROCESS)와 같은 방식으로 산정한다.',
  `PRICE` float DEFAULT '0' COMMENT '단가가 명시 되어 있는 경우 : 금액(PRICE) = 단가(UNIT_PRICE_SUM) * 수량(QTY), 단가가 명시되지 않은 경우에는 수식이 아닌 입력되는 값으로 사용한다.',
  `STATUS` enum('BID','CONTRACT','COLLECT') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'BID' COMMENT '상태는 3가지(BID, CONTRACT, COLLECT)의 3가지로 구분하며, 입찰과 계약, 수거중일때 폐기물의 종류가 달라질수 있으므로 각각의 상태별로 폐기물에 대한 관리를 달리 해야 한다.',
  `CREATED_AT` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '레코드가 생성된 일시로서 UTC+0900이 적용된 sp_req_current_time의 결과값으로 입력하도록 한다.',
  `UPDATED_AT` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '레코드가 변경된 일시로서 UTC+0900이 적용된 sp_req_current_time의 결과값으로 입력하도록 한다.',
  PRIMARY KEY (`WDSCM_ID`,`WSTE_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='WSTE_DISPOSAL_SITE_COLLECTION_MATCH의 폐기물배출지(SITE)와 수거자(COLLECTOR)의 관계만 설정되었으며 수거자(COLLECTOR)는 해당 폐기물배출지(SITE)에서 1 종류 이상의 폐기물을 수거할 수 있으므로 폐기물배출지(STIE)와 수거자(COLLECTOR)의 관계에서 생성되는 여러종류의 수거대상 폐기물(WSTE)에 대한 정보를 이 테이블에서 관리한다. \\n사이트에서 발생하는 폐기물 종류를 하나의 세트로 묶어서 동일한 상태에서 동일한 사이트와 동일한 폐기물의 종류로 묶인 레코드가 여러개 발생하는 것을 방지해야 한다. \\n상태벼로 사이트와 폐기물 종류의 관계는 1:1이 되어야 하므로 WDSCM_ID와 WSTE_CODE, STATUS가 PK가 되어야 한다.\\n상태의 구분은 입찰, 계약, 수거의 3가지 상태(BID, CONTRACT, COLLECT)로 구분되며 입찰 및 계약과 수거중일때 폐기물의 종류가 달라질수 있음을 고려하여 관리하도록 한다.';
