CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_company`(
	IN IN_USER_REG_ID			VARCHAR(50),		/*입력값 : 관리자아이디*/
    IN IN_PWD 					VARCHAR(100),		/*입력값 : 관리자암호*/
    IN IN_USER_NAME 			VARCHAR(20),		/*입력값 : 관리자이름*/
    IN IN_PHONE 				VARCHAR(20),		/*입력값 : 관리자 핸드폰 번호*/
    IN IN_COMP_NAME 			VARCHAR(100),		/*입력값 : 사업자 상호*/
    IN IN_REP_NAME 				VARCHAR(50),		/*입력값 : 대표자 이름*/
    IN IN_KIKCD_B_CODE 			VARCHAR(10),		/*입력값 : 사무실 소재지 시군구 법정동코드로서 10자리 코드*/
    IN IN_ADDR 					VARCHAR(255),		/*입력값 : 사무실 소재지 상세주소*/
    IN IN_LNG 					DECIMAL(12,9),		/*입력값 : 사무실 좌표 경도*/
    IN IN_LAT 					DECIMAL(12,9),		/*입력값 : 사무실 좌표 위도*/
    IN IN_CONTACT 				VARCHAR(100),		/*입력값 : 사무실 연락처*/
    IN IN_TRMT_BIZ_CODE 		VARCHAR(4),			/*입력값 : 사업자 분류코드로서 WSTE_TRMT_BIZ에 등록된 종류별 코드임*/
    IN IN_BIZ_REG_CODE 			VARCHAR(12),		/*입력값 : 사업자번호*/
    IN IN_BIZ_REG_IMG_PATH		VARCHAR(255),		/*입력값 : 사업자 분류코드로서 WSTE_TRMT_BIZ에 등록된 종류별 코드임*/
	IN IN_SOCIAL_NO				VARCHAR(20),		/*입력값 : 주민등록번호*/
	IN IN_AGREE_TERMS			TINYINT				/*입력값 : 약관동의여부(동의시 1)*/
    )
BEGIN

/*
Procedure Name 	: sp_create_company
Input param 	: 13개
Job 			: 사업자 생성을 한 후 기본 사이트 1개를 추가해주는 로직으로 변경(사업자 기반에서 사업자가 개설한 사이트 기반으로 중심 변경)
Update 			: 2022.02.11
Version			: 0.0.7
AUTHOR 			: Leo Nam
Change			: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.6)
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
	
    /*사이트가 소재하는 주소지에 대한 위도 경도값은 NULL처리 한다.*/
    
    CALL sp_create_company_without_handler(
		IN_USER_REG_ID,
		IN_PWD,
		IN_USER_NAME,
		IN_PHONE,
		IN_COMP_NAME,
		IN_REP_NAME,
		IN_KIKCD_B_CODE,
		IN_ADDR,
		IN_LNG,
		IN_LAT,
		IN_CONTACT,
		IN_TRMT_BIZ_CODE,
		IN_BIZ_REG_CODE,
		IN_BIZ_REG_IMG_PATH,
		IN_SOCIAL_NO,
		IN_AGREE_TERMS,
		@rtn_val,
		@msg_txt,
		@OUT_SITE_ID,
		@OUT_USER_ID
    );
    
    IF @rtn_val = 0 THEN
	/*사업자 개설에 성공한 경우*/
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'SITE_ID'			, @OUT_SITE_ID,
                'USER_REG_ID'		, @OUT_USER_ID
			)
		) 
        INTO @json_data;
    ELSE
	/*사업자 개설에 실패한 경우*/
		SET @json_data 		= NULL;
		SIGNAL SQLSTATE '23000';
    END IF;
	COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END