CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_site_wste_photo_information`(
	IN IN_DISPOSER_ORDER_ID				BIGINT,
	IN IN_TRANSACTION_ID				BIGINT,
	IN IN_REG_DT						DATETIME,
	IN IN_CLASS_CODE					ENUM('입찰','처리'),
	IN IN_JSON_DATA						JSON,
	OUT rtn_val							INT,
	OUT msg_txt 						VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_create_site_wste_discharged
Input param 	: 3개
Output param 	: 2개
Job 			: 폐기물 배출 및 처리시 업로드 되는 사진에 대한 정보를 저장한다.
Update 			: 2022.01.22
Version			: 0.0.2
AUTHOR 			: Leo Nam
IN_JSON_DATA	: JSON 데이타에서 사용하는 KEY와 VALUE 타입
Change			: SITE_WSTE_REG_ID를 IN_DISPOSER_ORDER_ID로 변경(0.0.2)
				: WSTE_REGISTRATION_PHOTO의 SITE_WSTE_REG_ID 컬럼 이름도 DISPOSAL_ORDER_ID로 변경(0.0.2)
*/
    
    DECLARE vRowCount INT DEFAULT 0;
    DECLARE endOfRow TINYINT DEFAULT FALSE;
    
    DECLARE CUR_FILE_NAME 		VARCHAR(100);
    DECLARE CUR_IMG_PATH 		VARCHAR(255);
    DECLARE CUR_FILE_SIZE 		FLOAT;
    
    DECLARE PHOTO_CURSOR CURSOR FOR 
	SELECT FILE_NAME, IMG_PATH, FILE_SIZE 
    FROM JSON_TABLE(IN_JSON_DATA, "$[*]" COLUMNS(
    /*JSON 데이타에서 사용하는 KEY와 VALUE 타입*/
		FILE_NAME 				VARCHAR(100) 		PATH "$.FILE_NAME",
		IMG_PATH 				VARCHAR(255)		PATH "$.IMG_PATH",
		FILE_SIZE				FLOAT				PATH "$.FILE_SIZE"
	)) AS PHOTO_LIST;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
	OPEN PHOTO_CURSOR;	
	cloop: LOOP
		FETCH PHOTO_CURSOR 
        INTO 
			CUR_FILE_NAME,
			CUR_IMG_PATH,
			CUR_FILE_SIZE;   
        
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			SET rtn_val = 0;
			SET msg_txt = 'Success';
			LEAVE cloop;
		END IF;
        
		INSERT INTO 
        WSTE_REGISTRATION_PHOTO(
			DISPOSAL_ORDER_ID, 
            FILE_NAME, 
            IMG_PATH, 
            FILE_SIZE, 
            ACTIVE,
            CLASS_CODE,
            CREATED_AT,
            UPDATED_AT,
            TRANSACTION_ID
		)
        VALUES(
			IN_DISPOSER_ORDER_ID, 
            CUR_FILE_NAME, 
            CUR_IMG_PATH, 
            CUR_FILE_SIZE, 
            TRUE, 
            IN_CLASS_CODE, 
            IN_REG_DT, 
            IN_REG_DT,
            IN_TRANSACTION_ID
		);
        
        IF ROW_COUNT() = 0 THEN
			SET rtn_val = 22801;
			SET msg_txt = 'Failed to insert uploaded images information';
			LEAVE cloop;
		ELSE
			SET rtn_val = 0;
			SET msg_txt = 'Success';
        END IF;
	END LOOP;   
	CLOSE PHOTO_CURSOR;
END