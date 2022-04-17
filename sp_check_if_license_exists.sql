CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_if_license_exists`(
	IN IN_USER_ID			BIGINT
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    CALL sp_req_user_exists_by_id(
		IN_USER_ID,			/*사이트를 개설하려는 자의 고유등록번호*/
        TRUE,					/*ACTIVE가 TRUE인 상태(활성화 상태)인 사용자에 한정*/
		@rtn_val,
		@msg_txt
    );
    IF @rtn_val = 0 THEN
		SELECT AFFILIATED_SITE 
        INTO @AFFILIATED_SITE 
        FROM USERS WHERE ID = IN_USER_ID;
        IF @AFFILIATED_SITE > 0 THEN
			SELECT B.PERMIT_REG_IMG_PATH, B.LICENSE_CONFIRMED
            INTO @PERMIT_REG_IMG_PATH, @LICENSE_CONFIRMED
            FROM USERS A 
            LEFT JOIN COMP_SITE B ON A.AFFILIATED_SITE = B.ID
            WHERE A.ID = IN_USER_ID;
            
            IF @PERMIT_REG_IMG_PATH IS NOT NULL THEN
            /*등록증 이미지가 업로드 된 경우*/
				SELECT JSON_ARRAYAGG(
					JSON_OBJECT(
						'LICENSE_REGISTERED'		, TRUE, 
						'LICENSE_CONFIRMED'			, @LICENSE_CONFIRMED
					)
				) 
				INTO @json_data; 
            ELSE
            /*등록증 이미지가 업로드 되지 않은 경우*/
				SELECT JSON_ARRAYAGG(
					JSON_OBJECT(
						'LICENSE_REGISTERED'		, FALSE, 
						'LICENSE_CONFIRMED'			, @LICENSE_CONFIRMED
					)
				) 
				INTO @json_data; 
            END IF;
        ELSE
			SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'LICENSE_REGISTERED'		, NULL, 
					'LICENSE_CONFIRMED'			, NULL
				)
			) 
			INTO @json_data; 
        END IF;
    ELSE
		SELECT JSON_ARRAYAGG(
			JSON_OBJECT(
				'LICENSE_REGISTERED'		, NULL, 
				'LICENSE_CONFIRMED'			, NULL
			)
		) 
		INTO @json_data; 
    END IF;
    COMMIT;   
    SET @rtn_val = 0;   
    SET @msg_txt = 'success';
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END