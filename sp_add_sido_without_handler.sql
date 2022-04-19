CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_add_sido_without_handler`(
	IN IN_SITE_ID			BIGINT,
    IN IN_SIDO_CODE			VARCHAR(10),
    IN IN_IS_DEFAULT		TINYINT,
    OUT rtn_val				INT,
    OUT msg_txt				VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_add_sido_without_handler
Input param 	: 3개
Job 			: 시도의 시군구를 벌크로 편입한다.
Update 			: 2022.01.27
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/	

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_B_CODE							VARCHAR(10); 
    DECLARE TEMP_CURSOR		 					CURSOR FOR 
	SELECT 
		B_CODE
    FROM KIKCD_B
	WHERE 
		LEFT(IN_SIDO_CODE, 2) = LEFT(B_CODE, 2) AND
		CANCELED_DATE IS NULL AND
        MID(B_CODE, 3, 3) <> '000' AND
        RIGHT(B_CODE, 5) = '00000' AND
		LEFT(B_CODE, 5) NOT IN (
			SELECT LEFT(KIKCD_B_CODE, 5) FROM BUSINESS_AREA
			WHERE 
				SITE_ID = IN_SITE_ID AND
				ACTIVE = TRUE
		);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		
		FETCH TEMP_CURSOR 
		INTO 
			CUR_B_CODE;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		CALL sp_req_current_time(@REG_DT);
		INSERT INTO 
		BUSINESS_AREA(
			SITE_ID, 
			KIKCD_B_CODE, 
			IS_DEFAULT,
			CREATED_AT
		)
		VALUES(
			IN_SITE_ID,
			CUR_B_CODE,
			IN_IS_DEFAULT,
			@REG_DT
		);
	END LOOP;   
	CLOSE TEMP_CURSOR;
    
    IF vRowCount = 0 THEN
		SET rtn_val = 38201;
		SET msg_txt = 'No data added';
    ELSE
		SET rtn_val = 0;
		SET msg_txt = 'Success';
    END IF;
END