CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_status`(
)
BEGIN

    DECLARE vRowCount 						INT DEFAULT 0;
    DECLARE endOfRow 						TINYINT DEFAULT FALSE;   
    
    DECLARE CUR_DISP_ID						INT;
    DECLARE CUR_USER_TYPE					INT;
    DECLARE CUR_USER_TYPE_NM_KO				VARCHAR(20);
    DECLARE CUR_ACTIVE						TINYINT;
    DECLARE CUR_DISP_NM_KO					VARCHAR(20);
    DECLARE TEMP_CURSOR		 				CURSOR FOR 
	SELECT 
		DISP_ID, 
        USER_TYPE,      
        USER_TYPE_NM_KO,
        ACTIVE,
        DISP_NM_KO
    FROM V_STATUS_GROUP
	WHERE 
		ACTIVE = TRUE;
            
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;
    
	CREATE TEMPORARY TABLE IF NOT EXISTS CURRENT_STATE (
		DISP_ID						INT,
		USER_TYPE					INT,
		USER_TYPE_NM_KO				VARCHAR(20),
		ACTIVE						TINYINT,
		DISP_NM_KO					VARCHAR(20),
		SUB_STATUS					JSON
	);        
	
	OPEN TEMP_CURSOR;	
	cloop: LOOP
		FETCH TEMP_CURSOR 
		INTO 
			CUR_DISP_ID,
			CUR_USER_TYPE, 
			CUR_USER_TYPE_NM_KO,
			CUR_ACTIVE,
			CUR_DISP_NM_KO;   
		
		SET vRowCount = vRowCount + 1;
		IF endOfRow THEN
			LEAVE cloop;
		END IF;
		
		INSERT INTO 
		CURRENT_STATE(
			DISP_ID, 
			USER_TYPE, 
			USER_TYPE_NM_KO,
			ACTIVE,
			DISP_NM_KO
		)
		VALUES(
			CUR_DISP_ID, 
			CUR_USER_TYPE, 
			CUR_USER_TYPE_NM_KO,
			CUR_ACTIVE,
			CUR_DISP_NM_KO
		);
        
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'ID'						, ID, 
				'USER_TYPE'					, USER_TYPE, 
                'USER_TYPE_NM_KO'			, USER_TYPE_NM_KO, 
                'STATUS_NM_KO'				, STATUS_NM_KO, 
                'PID'						, PID, 
                'ACTIVE'					, ACTIVE,
				'DISP_ID'					, DISP_ID, 
                'DISP_NM_KO'				, DISP_NM_KO
			)
		) 
        INTO @SUB_STATUS 
        FROM V_STATUS
        WHERE PID = CUR_DISP_ID OR ID = CUR_DISP_ID AND ACTIVE = TRUE;
		
		UPDATE CURRENT_STATE 
        SET 
			SUB_STATUS 				= @SUB_STATUS
		WHERE DISP_ID			 	= CUR_DISP_ID;
		
	END LOOP;   
	CLOSE TEMP_CURSOR;
	
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'						, DISP_ID, 
            'USER_TYPE'					, USER_TYPE, 
            'USER_TYPE_NM_KO'			, USER_TYPE_NM_KO, 
            'ACTIVE'					, ACTIVE, 
            'STATUS_NM_KO'				, DISP_NM_KO, 
            'SUB_STATUS'				, SUB_STATUS
		)
	) 
    INTO @json_data 
    FROM CURRENT_STATE;
    
	SET @rtn_val 				= 0;
	SET @msg_txt 				= 'Success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	DROP TABLE IF EXISTS CURRENT_STATE;
END