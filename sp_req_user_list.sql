CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_list`(
	IN IN_USER_ID							BIGINT,			/*입력값 : 사용자 고유등록번호*/
    IN IN_PERIOD							INT,			/*입력값 : 검색 기간(DAY)*/
    IN IN_OFFSET							INT,			/*입력값 : 스킵할 아이템의 갯수*/
    IN IN_ITEMS								INT				/*입력값 : 폐이지당 반환할 리스트의 개수*/
)
BEGIN

/*
Procedure Name 	: sp_cancel_bidding
Input param 	: 1개
Job 			: 등록회원리스트를 반환한다.
Update 			: 2022.02.12
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/		

    DECLARE vRowCount 					INT DEFAULT 0;
    DECLARE endOfRow 					TINYINT DEFAULT FALSE;  
    
    DECLARE CUR_USER_REG_ID		 		BIGINT;
    DECLARE CUR_USER_NAME			 	VARCHAR(20);
    DECLARE CUR_PHONE				 	VARCHAR(20);
    DECLARE CUR_SITE_ID				 	BIGINT;
    DECLARE CUR_SITE_NM				 	VARCHAR(255);
    DECLARE CUR_TRMT_BIZ_CODE		 	INT;
    DECLARE CUR_TRMT_BIZ_NM			 	VARCHAR(255);
    DECLARE CUR_USER_CLASS			 	INT;
    DECLARE CUR_USER_CLASS_NM		 	VARCHAR(50);
    DECLARE CUR_ACTIVE				 	TINYINT;
    DECLARE CUR_CREATED_AT				DATETIME;	
    DECLARE CUR_UPDATED_AT				DATETIME;	
    
    DECLARE TEMP_CURSOR 				CURSOR FOR 
    
	SELECT 
		ID, 
        USER_NAME, 
        PHONE, 
        AFFILIATED_SITE, 
        SITE_NAME, 
        TRMT_BIZ_CODE, 
        TRMT_BIZ_NM, 
        CLASS, 
        CLASS_NM, 
        ACTIVE, 
        CREATED_AT, 
        UPDATED_AT
    FROM V_USERS
    WHERE 
		CURRENT_TIMESTAMP <= ADDTIME(CREATED_AT, CONCAT(IN_PERIOD, ' 00:00:00'))
	ORDER BY CREATED_AT DESC
    LIMIT IN_OFFSET, IN_ITEMS;   
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE;     		
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;				
    /*트랜잭션 시작*/  
    
    CALL sp_req_user_exists_by_id(
		IN_USER_ID,
        TRUE,
        @trn_val,
        @msg_txt
    );
    IF @trn_val = 0 THEN
		CALL sp_req_user_class_by_user_reg_id(
			IN_USER_ID,
			@USER_CLASS
		);
		IF @USER_CLASS = 101 OR @USER_CLASS = 102 THEN
			CREATE TEMPORARY TABLE IF NOT EXISTS USER_LIST_TABLE (
				USER_REG_ID				BIGINT,
				USER_NAME				VARCHAR(20),
				PHONE					VARCHAR(20),
				SITE_ID					BIGINT,
				SITE_NAME				VARCHAR(255),
				TRMT_BIZ_CODE			INT,
				TRMT_BIZ_NM				VARCHAR(255),
				USER_CLASS				INT,
				USER_CLASS_NM			VARCHAR(50),
				ACTIVE					TINYINT,
				CREATED_AT				DATETIME,
				UPDATED_AT				DATETIME
			);
			
			OPEN TEMP_CURSOR;	
			cloop: LOOP
				FETCH TEMP_CURSOR 
				INTO 
					CUR_USER_REG_ID,
					CUR_USER_NAME,
					CUR_PHONE,
					CUR_SITE_ID,
					CUR_SITE_NM,
					CUR_TRMT_BIZ_CODE,
					CUR_TRMT_BIZ_NM,
					CUR_USER_CLASS,
					CUR_USER_CLASS_NM,
					CUR_ACTIVE,
					CUR_CREATED_AT,
					CUR_UPDATED_AT;   
				
				SET vRowCount = vRowCount + 1;
				IF endOfRow THEN
					LEAVE cloop;
				END IF;
				
				INSERT INTO 
				USER_LIST_TABLE(
					USER_REG_ID, 
					USER_NAME, 
					PHONE, 
					SITE_ID, 
					SITE_NAME, 
					TRMT_BIZ_CODE, 
					TRMT_BIZ_NM, 
					USER_CLASS, 
					USER_CLASS_NM, 
					ACTIVE, 
					CREATED_AT, 
					UPDATED_AT
				)
				VALUES(
					CUR_USER_REG_ID, 
					CUR_USER_NAME,
					CUR_PHONE,
					CUR_SITE_ID,
					CUR_SITE_NM,
					CUR_TRMT_BIZ_CODE,
					CUR_TRMT_BIZ_NM,
					CUR_USER_CLASS,
					CUR_USER_CLASS_NM,
					CUR_ACTIVE,
					CUR_CREATED_AT,
					CUR_UPDATED_AT
				);
				
			END LOOP;   
			CLOSE TEMP_CURSOR;
			
			SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'USER_REG_ID'		, USER_REG_ID, 
					'USER_NAME'			, USER_NAME, 
					'PHONE'				, PHONE, 
					'SITE_ID'			, SITE_ID, 
					'SITE_NAME'			, SITE_NAME, 
					'TRMT_BIZ_CODE'		, TRMT_BIZ_CODE, 
					'TRMT_BIZ_NM'		, TRMT_BIZ_NM, 
					'USER_CLASS'		, USER_CLASS, 
					'USER_CLASS_NM'		, USER_CLASS_NM, 
					'ACTIVE'			, ACTIVE, 
					'CREATED_AT'		, CREATED_AT, 
					'UPDATED_AT'		, UPDATED_AT
				)
			) 
			INTO @json_data 
			FROM USER_LIST_TABLE;
			SET @rtn_val = 0;
			SET @msg_txt = 'Success';
        ELSE
			SET @json_data = NULL;
			SET @rtn_val 		= 30102;
			SET @msg_txt 		= 'User not authorized';
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
		SET @json_data = NULL;
		SET @rtn_val 		= 30101;
		SET @msg_txt 		= 'User not found';
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
    DROP TABLE IF EXISTS USER_LIST_TABLE;
END