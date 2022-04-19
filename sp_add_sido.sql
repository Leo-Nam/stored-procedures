CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_add_sido`(
	IN IN_SIDO_CODE			VARCHAR(10),		/*입력값 : 추가하고자 하는 시군구코드(KIKCD_B.B_CODE)*/
	IN IN_IS_DEFAULT		TINYINT,				/*입력값 : 무료는 TRUE로 값을 전달하고 유료는 FALSE로 값을 전달한다.*/
    IN IN_SITE_ID			BIGINT,
    OUT rtn_val				INT,
    OUT msg_txt				VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_add_sido
Input param 	: 3개
Job 			: 시도의 시군구를 벌크로 편입한다.
Update 			: 2022.01.27
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/	
	CALL sp_req_current_time(@REG_DT);
	IF IN_IS_DEFAULT = TRUE THEN
	/*무료 추가인 경우*/
		SELECT COUNT(ID) INTO @AREA_COUNT
		FROM BUSINESS_AREA
		WHERE 
			SITE_ID = IN_SITE_ID AND
			IS_DEFAULT <> 0 AND
			ACTIVE = TRUE;
		/*무료로 가입시킨 지역의 개수를 구하여 @AREA_COUNT에 반환한다.*/
		CALL sp_req_policy_direction(
			'number_of_free_areas_of_interest',
			@number_of_free_areas_of_interest
		);
        SET @EXTRA_FREE = @number_of_free_areas_of_interest - @AREA_COUNT;
        /*무료로 추가할 수 있는 여유 수량을 구하여 @EXTRA_FREE에 저장한다.*/
        
        IF IN_SIDO_CODE = '3600000000' THEN
            SET @SIGUNGU_CODE = '3611000000';
			SELECT COUNT(ID) INTO @ID_COUNT
            FROM BUSINESS_AREA
            WHERE SITE_ID = IN_SITE_ID AND KIKCD_B_CODE = @SIGUNGU_CODE;
            IF @ID_COUNT = 0 THEN
            /*이전에 추가한 적이 없는 경우 정상처리한다.*/
				SET @COUNT_TO_BE_ADDED = 1;
				IF @EXTRA_FREE >= @COUNT_TO_BE_ADDED THEN
				/*추가할 여력이 있는 경우 정상처리한다.*/
					INSERT INTO BUSINESS_AREA (
						SITE_ID, 
						KIKCD_B_CODE, 
						IS_DEFAULT, 
						CREATED_AT
					) 
					VALUES (
						IN_SITE_ID, 
						@SIGUNGU_CODE, 
						IN_IS_DEFAULT, 
						@REG_DT
					);
					
					IF ROW_COUNT() = 1 THEN
					/*레코드가 정상적으로 생성되었다면*/
						SET rtn_val 		= 0;
						SET msg_txt 		= 'success111112222233333';
					ELSE
					/*레코드가 정상적으로 생성되지 않았다면*/
						SET rtn_val 		= 38106;
						SET msg_txt 		= 'Failed to add area of ​​interest';
					END IF;
				ELSE
				/*추가할 여력이 없는 경우 예외처리한다.*/
					SET rtn_val 		= 38105;
					SET msg_txt 		= 'can not add business area any more';
				END IF;
            ELSE
            /*이전에 추가한 적이 있는 경우 예외처리한다.*/
				SET rtn_val 		= 38104;
				SET msg_txt 		= 'area already added';
            END IF;
        ELSE
			SELECT COUNT(B_CODE) INTO @SIGUNGU_COUNT
			FROM KIKCD_B
			WHERE 
				LEFT(IN_SIDO_CODE, 2) = LEFT(B_CODE, 2) AND
				CANCELED_DATE IS NULL AND
				MID(B_CODE, 3, 3) <> '000' AND
                RIGHT(B_CODE, 5) = '00000';
			
            /*아래에서 이미 편입한 관심지역의 수를 계산하여 @AREA_ALREADY_ADDED 반환한다.*/
            SELECT COUNT(KIKCD_B_CODE) INTO @AREA_ALREADY_ADDED
            FROM BUSINESS_AREA
            WHERE LEFT(KIKCD_B_CODE, 5) IN (
            SELECT B_CODE FROM KIKCD_B
			WHERE 
				LEFT(IN_SIDO_CODE, 2) = LEFT(B_CODE, 2) AND
				CANCELED_DATE IS NULL AND
				MID(B_CODE, 3, 3) <> '000');
			
            SET @COUNT_TO_BE_ADDED = @SIGUNGU_COUNT - @AREA_ALREADY_ADDED;
            IF @COUNT_TO_BE_ADDED > 0 THEN
				IF @EXTRA_FREE >= @COUNT_TO_BE_ADDED THEN
				/*추가할 여력이 있는 경우 정상처리한다.*/
					CALL sp_add_sido_without_handler(
						IN_SITE_ID,
						IN_SIDO_CODE,
						IN_IS_DEFAULT,
						rtn_val,
						msg_txt
					);
				ELSE
				/*추가할 여력이 없는 경우 예외처리한다.*/
					SET rtn_val 		= 38103;
					SET msg_txt 		= CONCAT('can not add business area any more/', @SIGUNGU_COUNT, '/', @AREA_ALREADY_ADDED, '/', @COUNT_TO_BE_ADDED, '/', @EXTRA_FREE);
				END IF;
            ELSE
            /*해당 시도에서는 추가할 시군구가 존재하지 않는 경우 예외처리한다.*/
				SET rtn_val 		= 38102;
				SET msg_txt 		= 'can not add business area in this province any more';
            END IF;
        END IF;
	ELSE
	/*유료 추가인 경우 정상처리한다.*/
		CALL sp_add_sido_without_handler(
			IN_SITE_ID,
			IN_SIDO_CODE,
			IN_IS_DEFAULT,
			rtn_val,
			msg_txt
        );
	END IF;
END