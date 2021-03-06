CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_retrieve_stat_region_sigungu_without_handler`(
	IN IN_SIDO_CODE 		VARCHAR(10),
    OUT STAT_LIST			JSON
)
BEGIN

    DECLARE vRowCount 								INT 				DEFAULT 0;
    DECLARE endOfRow 								TINYINT 			DEFAULT FALSE;   
    DECLARE CUR_REGION								VARCHAR(50);
    DECLARE CUR_REGION_CODE							VARCHAR(10);
    DECLARE CUR_USER_TYPE							VARCHAR(4);	
    DECLARE CUR_QTY									INT;
    DECLARE TEMP_CURSOR		 						CURSOR FOR 
	SELECT 
		SI_GUN_GU, 
		B_CODE
	FROM V_SIGUNGU
    WHERE LEFT(B_CODE, 5) = LEFT(IN_SIDO_CODE, 5)
    ORDER BY SI_GUN_GU ASC;
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;        
    
	CREATE TEMPORARY TABLE IF NOT EXISTS ADMIN_RETRIEVE_STAT_REGION_SIGUNGU_TEMP (
		REGION								VARCHAR(50), 
		REGION_CODE							VARCHAR(10), 
		COL									INT,	
		EMI									INT
	);         
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_REGION,
			CUR_REGION_CODE;
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		ADMIN_RETRIEVE_STAT_REGION_SIGUNGU_TEMP(
			REGION,
			REGION_CODE
		)
		VALUES(
			CUR_REGION,
			CUR_REGION_CODE
		);
        
        CALL sp_admin_count_sigungu_stats(
			CUR_REGION_CODE,
            @COL,
            @EMI
        );
        
        UPDATE ADMIN_RETRIEVE_STAT_REGION_SIGUNGU_TEMP
        SET 
			COL = @COL,
			EMI = @EMI
        WHERE REGION_CODE = CUR_REGION_CODE;
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'REGION'						, REGION, 
			'REGION_CODE'					, REGION_CODE, 
			'COL'							, COL, 
			'EMI'							, EMI
		)
	) 
	INTO STAT_LIST
	FROM ADMIN_RETRIEVE_STAT_REGION_SIGUNGU_TEMP;
	
	SET @rtn_val = 0;
	SET @msg_txt = 'Success1';
    DROP TABLE IF EXISTS ADMIN_RETRIEVE_STAT_REGION_SIGUNGU_TEMP;
END