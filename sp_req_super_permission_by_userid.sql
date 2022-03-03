CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_super_permission_by_userid`(
	IN IN_USER_ID				BIGINT,				/*사업자의 super user(member.admin:201)인지 체크가 필요한 사용자 고유등록번호*/
    IN IN_COMP_ID				BIGINT,				/*사업자의 고유 등록번호*/
    OUT OUT_PERMISSION			INT,				/*사용자의 권한*/
    OUT OUT_HEAD_OFFICE			TINYINT,			/*사용자가 속한 사이트가 HEAD OFFICE이면 TRUE, 그렇지 않으면 FALSE 반환*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_super_permission_by_userid
Input param 	: 2개
Output param 	: 2개(1:sys.admin / 2:모회사관리자 / 3:사업자관리자)
Job 			: 사용자가 사업자 단위를 대상으로 관리자로서의 권한(member.admin:201)을 가지고 있는지 여부를 반환함. 관리자 권한 아래의 3가지임
				: 1. sys.admin(101/102/199)인 경우
				: 2. 모회사의 관리자인 경우
				: 3. 사업자의 관리자인 경우
				: 사용자가 속한 사이트가 HEAD OFFICE인지 여부도 함께 반환함
				: 권한분기 오류 일부 수정
Update 			: 2022.01.14
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/
    
    SET OUT_PERMISSION = 0;
    
    CALL sp_req_site_id_of_user_reg_id(
		IN_USER_ID,
        @USER_SITE_ID,
        @rtn_val,
        @msg_txt
    );
    
    CALL sp_req_is_site_head_office(
		@USER_SITE_ID,
        @IS_USER_SITE_HEAD_OFFICE
    );
    
    SET OUT_HEAD_OFFICE = @IS_USER_SITE_HEAD_OFFICE;
    
    CALL sp_req_comp_id_of_user_by_id(
		IN_USER_ID,
        @USER_COMP_ID
    );
    
    /*SELECT B.HEAD_OFFICE INTO OUT_HEAD_OFFICE FROM USERS A LEFT JOIN COMP_SITE B ON A.AFFILIATED_SITE = B.ID WHERE A.ID = IN_USER_ID; */
    /*사용자가 속한 사이트가 HEAD OFFICE인 경우 TRUE, 그렇지 않은 경우 FALSE를 OUT_HEAD_OFFICE를 통하여 반환함*/
    
    SET @CHK_COUNT = 0;
	SELECT COUNT(ID) INTO @CHK_COUNT FROM USERS WHERE ID = IN_USER_ID AND ACTIVE = TRUE AND CLASS = 101;
    /*IN_USER_ID가 변경하려는 사업자의 활성화된 관리자(manager.admin:201)이거나 sys.admin인 경우에는 @CHK_COUNT=1, 그렇지 않으면 @CHK_COUNT=0이 됨*/
    IF @CHK_COUNT > 0 THEN
		SET OUT_PERMISSION = 1;
	ELSE
		SELECT COUNT(ID) INTO @CHK_COUNT FROM USERS WHERE ID = IN_USER_ID AND ACTIVE = TRUE AND CLASS = 102;
		/*IN_USER_ID가 변경하려는 사업자의 활성화된 관리자(manager.admin:201)이거나 sys.admin인 경우에는 @CHK_COUNT=1, 그렇지 않으면 @CHK_COUNT=0이 됨*/
		IF @CHK_COUNT > 0 THEN
			SET OUT_PERMISSION = 2;
		ELSE
			SELECT BELONG_TO INTO @CREATOR_BELONG_TO FROM USERS WHERE ID = IN_USER_ID AND CLASS = 201;
			/*IN_USER_ID가 변경하려는 사업자의 모회사 관리자(manager.admin:201)인 경우 @IS_SUBSIDIARY=1, 그렇지 않으면 @IS_SUBSIDIARY=0이 됨*/
			IF @CREATOR_BELONG_TO = IN_COMP_ID THEN
				SET OUT_PERMISSION = 3;
			ELSE
				SELECT BELONG_TO INTO @CREATOR_BELONG_TO FROM USERS WHERE ID = IN_USER_ID AND CLASS = 202;
				/*IN_USER_ID가 변경하려는 사업자의 모회사 관리자(manager.admin:201)인 경우 @IS_SUBSIDIARY=1, 그렇지 않으면 @IS_SUBSIDIARY=0이 됨*/
				IF @CREATOR_BELONG_TO = IN_COMP_ID THEN
					SET OUT_PERMISSION = 4;
				ELSE
					SELECT BELONG_TO INTO @CREATOR_BELONG_TO FROM USERS WHERE USER_ID = IN_USER_ID AND CLASS = 201;
					SELECT IN_COMP_ID IN (SELECT CHILD.ID FROM COMPANY CHILD LEFT JOIN COMPANY PARENT ON CHILD.P_COMP_ID = PARENT.ID WHERE PARENT.ID = @CREATOR_BELONG_TO) INTO @IS_SUBSIDIARY;
					/*IN_USER_ID가 변경하려는 사업자의 활성화된 관리자(manager.admin:201)이거나 sys.admin인 경우에는 @CHK_COUNT=1, 그렇지 않으면 @CHK_COUNT=0이 됨*/
					IF @IS_SUBSIDIARY = 1 THEN
						SET OUT_PERMISSION = 5;
					ELSE
						SELECT COUNT(ID) INTO @CHK_COUNT FROM USERS WHERE ID = IN_USER_ID AND BELONG_TO = IN_COMP_ID AND ACTIVE = TRUE AND CLASS = 202;
						/*IN_USER_ID가 변경하려는 사업자의 활성화된 관리자(manager.admin:201)이거나 sys.admin인 경우에는 @CHK_COUNT=1, 그렇지 않으면 @CHK_COUNT=0이 됨*/
						IF @CHK_COUNT > 0 THEN
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