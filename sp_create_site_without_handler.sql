CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_site_without_handler`(
	IN IN_USER_ID			BIGINT,				/*입력값 : 사이트 등록자 아이디(USER.ID)*/
	IN IN_COMP_ID			BIGINT,				/*입력값 : 사업자 고유등록번호*/
	IN IN_KIKCD_B_CODE		VARCHAR(10),		/*입력값 : 사이트가 소재하는 주소지에 대한 시군구 법정동코드*/
	IN IN_ADDR				VARCHAR(255),		/*입력값 : 사이트가 소재하는 주소지에 대한 시군구 주소를 제외한 상세주소*/
	IN IN_SITE_ID			BIGINT,				/*입력값 : 사이트 등록번호*/
	IN IN_SITE_NAME			VARCHAR(255),		/*입력값 : 사이트 이름*/
	IN IN_SITE_ORDER		INT,				/*입력값 : 활성화된 사이트 개설순서*/
	IN IN_REG_DT			DATETIME,			/*입력값 : 레코드 생성일시*/
	IN IN_CONTACT			VARCHAR(100),		/*입력값 : 사이트 연락처*/
	IN IN_TRMT_BIZ_CODE		VARCHAR(4),			/*입력값 : 사업자 분류코드로서 WSTE_TRMT_BIZ에 등록된 종류별 코드임*/
    IN IN_LNG				DECIMAL(12,9),		/*입력값 : 사이트가 소재하는 주소의 경도값*/
    IN IN_LAT				DECIMAL(12,9),		/*입력값 : 사이트가 소재하는 주소의 위도값*/
    IN IN_HEAD_OFFICE		TINYINT,			/*입력값 : 최초로 사업자가 개설될 때 동시에 개설되는 사이트는 TRUE, 추가로 개설되는 사이트는 FALSE 값을 가지게 됨*/
	OUT OUT_SITE_REG_ID		BIGINT,				/*출력값 : 사이트고유등록번호가 반환함*/
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_create_site_without_handler
Input param 	: 11개
Output param 	: 3개
Job 			: IN_COMP_REG_CODE를 사업자 등록번호로 사용하는 사이트를 개설한다.
				: 최초의 사이트(HEAD_OFFICE)를 생성할때만 사용해야 함.
				: 추가 사이트를 생성하는 경우에는 sp_create_site를 사용해야 함.
				: 사이트가 주로 사업을 영위하는 사무소로서의 지위를 가질수 있도록 관리정보를 확장함.
Update 			: 2022.02.19
Version			: 0.0.4
AUTHOR 			: Leo Nam
*/

	SET @MAX_SITE_ID = IN_SITE_ID;
    
	INSERT INTO COMP_SITE(
		ID,
		COMP_ID,
		KIKCD_B_CODE,
		ADDR,
		CONTACT,
		LNG,
		LAT,
		SITE_NAME,
		ACTIVE,
		TRMT_BIZ_CODE,
		CREATOR_ID,
		HEAD_OFFICE,
		CREATED_AT,
		UPDATED_AT
	) VALUES (
		@MAX_SITE_ID,
		IN_COMP_ID,
		IN_KIKCD_B_CODE,
		IN_ADDR,
		IN_CONTACT,
		IN_LNG,
		IN_LAT,
		IN_SITE_NAME,
		TRUE,
		IN_TRMT_BIZ_CODE,
		IN_USER_ID,
		IN_HEAD_OFFICE,
		IN_REG_DT,
		IN_REG_DT
	);
	
	IF ROW_COUNT() = 1 THEN
	/*사이트 개설에 성공한 경우*/
		INSERT INTO BUSINESS_AREA (
			SITE_ID, 
			KIKCD_B_CODE, 
			IS_DEFAULT, 
			CREATED_AT
		) 
		VALUES (
			@MAX_SITE_ID, 
			CONCAT(LEFT(IN_KIKCD_B_CODE, 5), '00000'), 
			1, 
			@REG_DT
		);
        IF ROW_COUNT() = 1 THEN
        /*영업지역에 대한 저장이 성공적인 경우*/
			SET OUT_SITE_REG_ID = @MAX_SITE_ID;
			SET rtn_val = 0;
			SET msg_txt = 'success';
        ELSE
        /*영업지역에 대한 저장에 실패한 경우 예외처리한다.*/
			SET OUT_SITE_REG_ID = 0;
			SET rtn_val = 22402;
			SET msg_txt = 'Failed to set default region';
        END IF;
	ELSE
	/*사이트 개설에 실패한 경우*/
		SET OUT_SITE_REG_ID = 0;
		SET rtn_val = 22401;
		SET msg_txt = 'Failed to open site';
	END IF;
END