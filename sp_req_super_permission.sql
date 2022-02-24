CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_super_permission`(
	IN IN_USER_REG_ID		VARCHAR(50),	/*사업자의 super user(member.admin:201)인지 체크가 필요한 사용자 아이디*/
    IN IN_SITE_ID			BIGINT,			/*사업자의 고유 등록번호*/
    OUT OUT_PERMISSION		int
)
BEGIN

/*
Procedure Name 	: sp_req_super_permission
Input param 	: 2개
Output param 	: 1개(1:sys.admin / 2:모회사관리자 / 3:사업자관리자)
Job 			: 사용자가 사업자 단위를 대상으로 관리자로서의 권한(member.admin:201)을 가지고 있는지 여부를 반환함. 관리자 권한 아래의 3가지임
				: 1. sys.admin(101/102/199)인 경우
				: 2. 모회사의 관리자인 경우
				: 3. 사업자의 관리자인 경우
				: 권한분기 오류 일부 수정
Update 			: 2022.01.14
Version			: 0.0.4
AUTHOR 			: Leo Nam
*/

	DECLARE CHK_COUNT 			INT;
    DECLARE CREATOR_BELONG_TO 	BIGINT;
    
    SET OUT_PERMISSION = 0;
    
    SET CHK_COUNT = 0;
	SELECT COUNT(ID) INTO CHK_COUNT FROM USERS WHERE USER_ID = IN_USER_REG_ID AND ACTIVE = TRUE AND CLASS = 101;
    /*IN_USER_REG_ID가 변경하려는 사업자의 활성화된 관리자(manager.admin:201)이거나 sys.admin인 경우에는 CHK_COUNT=1, 그렇지 않으면 CHK_COUNT=0이 됨*/
    IF CHK_COUNT > 0 THEN
		SET OUT_PERMISSION = 1;
	ELSE
		SELECT COUNT(ID) INTO CHK_COUNT FROM USERS WHERE USER_ID = IN_USER_REG_ID AND ACTIVE = TRUE AND CLASS = 102;
		/*IN_USER_REG_ID가 변경하려는 사업자의 활성화된 관리자(manager.admin:201)이거나 sys.admin인 경우에는 CHK_COUNT=1, 그렇지 않으면 CHK_COUNT=0이 됨*/
		IF CHK_COUNT > 0 THEN
			SET OUT_PERMISSION = 2;
		ELSE
			SELECT BELONG_TO INTO CREATOR_BELONG_TO FROM USERS WHERE USER_ID = IN_USER_REG_ID AND CLASS = 201;
			IF CREATOR_BELONG_TO = IN_SITE_ID THEN
				SET OUT_PERMISSION = 3;
			ELSE
				SELECT BELONG_TO INTO CREATOR_BELONG_TO FROM USERS WHERE USER_ID = IN_USER_REG_ID AND CLASS = 202;
				/*IN_USER_REG_ID가 변경하려는 사업자의 모회사 관리자(manager.admin:201)인 경우 @IS_SUBSIDIARY=1, 그렇지 않으면 @IS_SUBSIDIARY=0이 됨*/
				IF CREATOR_BELONG_TO = IN_SITE_ID THEN
					SET OUT_PERMISSION = 4;
				ELSE
					SELECT BELONG_TO INTO CREATOR_BELONG_TO FROM USERS WHERE USER_ID = IN_USER_REG_ID AND CLASS = 201;
					SELECT IN_SITE_ID IN (SELECT CHILD.ID FROM COMPANY CHILD LEFT JOIN COMPANY PARENT ON CHILD.P_COMP_ID = PARENT.ID WHERE PARENT.ID = CREATOR_BELONG_TO) INTO @IS_SUBSIDIARY;
					/*IN_USER_REG_ID가 변경하려는 사업자의 활성화된 관리자(manager.admin:201)이거나 sys.admin인 경우에는 CHK_COUNT=1, 그렇지 않으면 CHK_COUNT=0이 됨*/
					IF @IS_SUBSIDIARY = 1 THEN
						SET OUT_PERMISSION = 5;
					ELSE
						SELECT COUNT(ID) INTO CHK_COUNT FROM USERS WHERE USER_ID = IN_USER_REG_ID AND BELONG_TO = IN_SITE_ID AND ACTIVE = TRUE AND CLASS = 202;
						/*IN_USER_REG_ID가 변경하려는 사업자의 활성화된 관리자(manager.admin:201)이거나 sys.admin인 경우에는 CHK_COUNT=1, 그렇지 않으면 CHK_COUNT=0이 됨*/
						IF CHK_COUNT > 0 THEN
							SET OUT_PERMISSION = 6;
						ELSE
							SET OUT_PERMISSION = 0;
						END IF;
					END IF;
                END IF;
			END IF;
        END IF;
	END IF;
END