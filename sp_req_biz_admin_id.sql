CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_biz_admin_id`(
	IN IN_BIZ_REG_CODE			VARCHAR(12),		/*입력값 : 사업자등록번호*/
	IN IN_USER_NAME				VARCHAR(20),		/*입력값 : 관리자 이름*/
	IN IN_USER_PHONE			VARCHAR(20),		/*입력값 : 관리자 등록 전화번호*/
    OUT OUT_USER_REG_ID			VARCHAR(50),		/*출력값 : 관리자가 존재하는 경우 관리자의 아이디*/
    OUT rtn_val					INT,				/*출력값 : 관리자 아이디가 존재하는 경우 0, 그렇지 않은경우 예외처리코드가 반환됨*/
    OUT msg_txt					VARCHAR(200)		/*출력값 : 처리결과*/
)
BEGIN

/*
Procedure Name 	: sp_req_biz_admin_id
Input param 	: 3개
Output param 	: 3개
Job 			: 입력받은 관리자의 이름 또는 전화번호를 가진 사용자가 입력받은 사업자등록번호를 가진 사업자의 관리자인 경우에 사용자의 아이디를 반환한다.
				: 조건에 맞는 정보가 없는 경우에는 Null을 반환함
Update 			: 2022.01.29
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/
    
	CALL sp_req_use_same_company_reg_id(
		IN_BIZ_REG_CODE, 
		@rtn_val, 
		@msg_txt
	);
    /*입력받은 사업자등록번호(IN_BIZ_REG_CODE)가 존재하면 @BIZ_REG_CODE_EXIST을 통하여 TRUE를 반환받게 되고 그렇지 않으면 0을 반환받음*/
    
    IF @rtn_val = 0 THEN
		SET rtn_val = 21101;
		SET msg_txt = 'Business registration number does not exist';
		SIGNAL SQLSTATE '23000';
    ELSE
		IF IN_USER_NAME IS NOT NULL OR IN_USER_PHONE IS NOT NULL THEN
			IF IN_USER_NAME IS NOT NULL THEN
				SELECT A.USER_ID 
                INTO OUT_USER_REG_ID 
                FROM USERS A LEFT JOIN COMPANY B ON A.BELONG_TO = B.ID 
                WHERE 
					B.ID IS NOT NULL AND 
                    A.USER_NAME = IN_USER_NAME;
            ELSE
				SELECT A.USER_ID 
                INTO OUT_USER_REG_ID 
                FROM USERS A LEFT JOIN COMPANY B ON A.BELONG_TO = B.ID 
                WHERE 
					B.ID IS NOT NULL AND 
                    A.PHONE = IN_USER_PHONE;
            END IF;
            IF OUT_USER_REG_ID IS NOT NULL THEN
				SET rtn_val = 0;
				SET msg_txt = 'Found admin information';
            ELSE
				SET rtn_val = 21102;
				SET msg_txt = 'Admin information not exists';
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
			SET rtn_val = 21103;
			SET msg_txt = 'Admin information not entered';
			SIGNAL SQLSTATE '23000';
        END IF;
    END IF;
END