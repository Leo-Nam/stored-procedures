CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_add_business_area`(
	IN IN_SIGUNGU_CODE		VARCHAR(10),		/*입력값 : 추가하고자 하는 시군구코드(KIKCD_B.B_CODE)*/
	IN IN_IS_DEFAULT		TINYINT,				/*입력값 : 무료는 TRUE로 값을 전달하고 유료는 FALSE로 값을 전달한다.*/
    IN IN_SITE_ID			BIGINT,
    OUT rtn_val				INT,
    OUT msg_txt				VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_add_business_area
Input param 	: 3개
Job 			: 수집운반업자 등의 허가를 갖춘 사이트가 사업지역을 추가한다.(시군구 단위)
Update 			: 2022.01.27
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.2)
*/		

	IF IN_SIGUNGU_CODE IS NOT NULL THEN
		SELECT COUNT(B_CODE) INTO @B_CODE_COUNT
		FROM KIKCD_B
		WHERE 
			B_CODE = IN_SIGUNGU_CODE AND
			CANCELED_DATE IS NULL;
		IF @B_CODE_COUNT > 0 THEN
			CALL sp_req_current_time(@REG_DT);
			IF RIGHT(IN_SIGUNGU_CODE, 8) = '00000000' THEN
			/*시도단위로 선택하는 경우*/
				SET @SIDO_CODE = IN_SIGUNGU_CODE;
				CALL sp_add_sido(
					@SIDO_CODE,
					IN_IS_DEFAULT,
					IN_SITE_ID,
					rtn_val,
					msg_txt
				);
			ELSE
			/*시군구단위로 선택하는 경우*/
				CALL sp_req_sigungu_is_already_added(
				/*검사하고자 하는 시군구가 이미 사이트에 등록되어 있는지 검사한다*/
					IN_SITE_ID,
					IN_SIGUNGU_CODE,
					rtn_val,
					msg_txt
				);
				IF @rtn_val = 0 THEN
				/*시군구가 사이트에 등록되어 있지 않은 경우*/
					CALL sp_add_sigungu_without_handler_1(
						IN_SIGUNGU_CODE,
                        IN_IS_DEFAULT,
                        IN_SITE_ID,
                        rtn_val,
                        msg_txt
                    );
				END IF;
			END IF;
        ELSE
		/*B_CODE가 존재하지 않는 경우에는 예외처리한다.*/
			SET rtn_val 		= 37902;
			SET msg_txt 		= 'B_CODE does not exist';
        END IF;        
    ELSE
	/*B_CODE가 존재하지 않는 경우에는 예외처리한다.*/
		SET rtn_val 		= 37901;
		SET msg_txt 		= 'B_CODE should not be null';
    END IF;
END