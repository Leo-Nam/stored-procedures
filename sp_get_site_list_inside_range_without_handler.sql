CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_site_list_inside_range_without_handler`(
	IN IN_USER_TYPE			INT,
	IN IN_RANGE				INT,
	IN IN_LAT				DECIMAL(12,9),
	IN IN_LNG				DECIMAL(12,9),
    OUT rtn_val				INT,
    OUT msg_txt				VARCHAR(200),
    OUT SITE_LIST			JSON
)
BEGIN

    DECLARE vRowCount 							INT DEFAULT 0;
    DECLARE endOfRow 							TINYINT DEFAULT FALSE;    
    DECLARE CUR_SITE_ID 						BIGINT;
    DECLARE CUR_LAT					 			DECIMAL(12,9);
    DECLARE CUR_LNG								DECIMAL(12,9);	
    DECLARE CUR_SITE_NAME						VARCHAR(255);	
    DECLARE CUR_DIST							FLOAT;	
    DECLARE SITE_LIST_CURSOR 					CURSOR FOR 
	SELECT 
		A.ID, 
        A.LAT, 
        A.LNG,
        A.SITE_NAME,
        6378.137 * ACOS(COS(IN_LAT * PI() / 180)*COS(A.LAT * PI() / 180)*COS((A.LNG * PI() / 180) - (IN_LNG * PI() / 180)) + SIN(IN_LAT * PI() / 180) * SIN(A.LAT * PI() / 180))
    FROM COMP_SITE A
    LEFT JOIN WSTE_TRMT_BIZ B ON A.TRMT_BIZ_CODE = B.CODE
    WHERE 
		6378.137 * ACOS(COS(IN_LAT * PI() / 180)*COS(A.LAT * PI() / 180)*COS((A.LNG * PI() / 180) - (IN_LNG * PI() / 180)) + SIN(IN_LAT * PI() / 180) * SIN(A.LAT * PI() / 180)) < IN_RANGE AND
        B.USER_TYPE = IN_USER_TYPE;  
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
        
	CREATE TEMPORARY TABLE IF NOT EXISTS SITE_LIST_INSIDE_RANGE_TEMP (
		ID							BIGINT,
		LAT							DECIMAL(12,9),
        LNG							DECIMAL(12,9),
        SITE_NAME					VARCHAR(255),
        DIST						FLOAT
	);
    
	OPEN SITE_LIST_CURSOR;	
	cloop: LOOP
		FETCH SITE_LIST_CURSOR 
        INTO  
			CUR_SITE_ID,
			CUR_LAT,
			CUR_LNG,
			CUR_SITE_NAME,
			CUR_DIST;
        
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
        
		INSERT INTO 
        SITE_LIST_INSIDE_RANGE_TEMP(
			ID, 
            LAT, 
            LNG, 
            SITE_NAME, 
            DIST
		)
        VALUES( 
			CUR_SITE_ID,
			CUR_LAT,
			CUR_LNG,
			CUR_SITE_NAME,
			CUR_DIST
		);
	END LOOP;   
	CLOSE SITE_LIST_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'			, ID, 
            'LAT'			, LAT, 
            'LNG'			, LNG, 
            'SITE_NAME'		, SITE_NAME, 
            'DIST'			, DIST
		)
	) 
    INTO SITE_LIST 
    FROM SITE_LIST_INSIDE_RANGE_TEMP;
    
	SET rtn_val = 0;
	SET msg_txt = 'Success11';
    DROP TABLE IF EXISTS SITE_LIST_INSIDE_RANGE_TEMP;
END