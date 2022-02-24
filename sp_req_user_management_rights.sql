CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_management_rights`(
	IN IN_USER_REG_ID			VARCHAR(100),									/*관리자 권한을 요구하는 사용자 아이디*/
    IN IN_TARGET_USER_REG_ID	VARCHAR(100),									/*관리자가 변경 또는 삭제 등의 정보 처리작업을 해야 하는 대상이 되는 사용자 아이디*/
    IN IN_JOB					ENUM('CREATE', 'READ', 'UPDATE', 'DELETE'),		/*관리자가 수행하고자 하는 작업*/
    OUT OUT_RIGHTS				TINYINT											/*권한이 있는 경우 TRUE, 그렇지 않은 경우 FALSE 반환*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_management_rights
Input param 	: 3개
Output param 	: 1개
Job 			: admin의 자격을 요구하는 사용자에게 실행하고자 하는 작업에 대한 권한이 있는지를 체크한 후 boolean으로 값을 반환함
				: 1. TRUE : 자격 있음
				: 2. FALSE : 자격 없음
Update 			: 2022.01.07
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	CALL sp_req_user_affiliation(IN_USER_REG_ID, @ADMIN_BELONG_TO);
    /*IN_USER_REG_ID가 어디에 소속되어 있는지를 확인하고 그 값을 반환한다.*/
    /*0 : 개인회원 또는 sys.admin, 1이상인 경우 : 사업자에 소속된 회원*/

	CALL sp_req_user_affiliation(IN_TARGET_USER_REG_ID, @USER_BELONG_TO);
    /*IN_TARGET_USER_REG_ID가 어디에 소속되어 있는지를 확인하고 그 값을 반환한다.*/
    /*0 : 개인회원 또는 sys.admin, 1이상인 경우 : 사업자에 소속된 회원*/
    
	CALL sp_req_user_class(IN_USER_REG_ID, @ADMIN_CLASS);
	/*정보를 처리를 요청하는 사용자의 CLASS를 구하여 @ADMIN_CLASS에 저장한다.*/
    
	CALL sp_req_user_class(IN_TARGET_USER_REG_ID, @USER_CLASS);
	/*정보를 처리할 대상 사용자의 CLASS를 구하여 @USER_CLASS에 저장한다.*/
    
    IF @ADMIN_BELONG_TO = 0 THEN
    /*ADMIN이 개인회원이거나 sys.admin인 경우*/
    /*ADMIN이 개인회원인 경우에는 자신의 정보에 대하여 UPDATE, DELETE의 모든 권한을 가지게 됨*/
    /*ADMIN이 sys.admin인 경우에는 ADMIN의 CLASS에 따라서 아래의 몇가지 경우로 분기가 되어야 한다.
    /*ADMIN.CLASS = 101인 경우 : 자신을 제외한 모든 사용자에 대하여 모든 권한을 가지게 된다. 본인에 대해서는 UPDATE만 가능하다.*/
    /*ADMIN.CLASS = 102인 경우 : ADMIN.CLASS=101의 사용자를 제외한 모든 사용자에 대하여 모든 권한을 가지게 된다. 자신에 대해서는 삭제를 제외한 모든 권한을 가지게 되고 다른 사용자에 대해서는 모든 권한을 가지게 된다.*/
    /*ADMIN.CLASS = 199인 경우 : ADMIN.CLASS=101, 102의 사용자를 제외한 모든 사용자에 대하여 모든 권한을 가지게 된다. 자신에 대해서는 삭제를 제외한 모든 권한을 가지게 되고 다른 사용자에 대해서는 모든 권한을 가지게 된다.*/
        IF @ADMIN_CLASS < 200 THEN
        /*ADMIN이 sys.admin인 경우*/
			IF @ADMIN_CLASS = 101 THEN
				IF IN_USER_REG_ID = IN_TARGET_USER_REG_ID THEN
                /*ADMIN이 sys.admin:101인 경우에 처리할 정보가 본인인 경우*/
					IF IN_JOB = 'DELETE' THEN
						/*정보를 삭제하는 경우에는 권한이 부여되지 않는다.*/
						SET OUT_RIGHTS = FALSE;
					ELSE
						/*정보를 삭제하는 경우를 제외한 경우에는 모든 권한이 부여된다.*/
						SET OUT_RIGHTS = TRUE;
                    END IF;
				ELSE
                /*ADMIN이 처리할 정보가 본인이 아닌 경우에는 모든 권한이 부여된다.*/
					SET OUT_RIGHTS = TRUE;
                END IF;
            ELSE
				IF @USER_CLASS < @ADMIN_CLASS THEN
				/*정보변경 대상자의 @USER_CLASS가 정보처리를 요청하는 사용자보다 상위 레벨(@USER_CLASS < @ADMIN_CLASS)인 경우에는 권한이 부여되지 않도록 한다.*/
					SET OUT_RIGHTS = FALSE;
				ELSE
					IF @USER_CLASS = @ADMIN_CLASS THEN
					/*정보변경 대상자의 @USER_CLASS가 정보처리를 요청하는 사용자와 동일한 레벨인 경우에는 본인의 정보 이외에는 권한이 부여되지 않도록 한다.*/
						IF IN_USER_REG_ID <> IN_TARGET_USER_REG_ID THEN
						/*정보처리요청자(ADMIN)과 정보처리대상자(USER)가 동일인이 아닌 경우에는 권한이 부여되지 않도록 한다.*/
							SET OUT_RIGHTS = FALSE;
						ELSE
						/*정보처리요청자(ADMIN)과 정보처리대상자(USER)가 동일인인 경우에는 권한이 DELETE권한을 제외한 모든 권한이 부여되지 않도록 한다.*/
							IF IN_JOB = 'DELETE' THEN
								/*정보를 삭제하는 경우에는 권한이 부여되지 않는다.*/
								SET OUT_RIGHTS = FALSE;
							ELSE
								/*정보를 삭제하는 경우를 제외한 경우에는 모든 권한이 부여된다.*/
								SET OUT_RIGHTS = TRUE;
							END IF;
						END IF;
					ELSE
					/*정보변경 대상자의 @USER_CLASS가 정보처리를 요청하는 사용자와 하위 레벨인 경우에는 모든 권한이 부여되도록 한다.*/
						SET OUT_RIGHTS = TRUE;
					END IF;
				END IF;
            END IF;
        ELSE
        /*ADMIN이 개인회원인 경우*/
			IF IN_USER_REG_ID = IN_TARGET_USER_REG_ID THEN
            /*ADMIN과 USER가 동일한 사용자인 경우*/
				SET OUT_RIGHTS = TRUE;
            ELSE
            /*ADMIN과 USER가 동일한 사용자가 아닌 경우*/
				SET OUT_RIGHTS = FALSE;
            END IF;
        END IF;
    ELSE
    /*ADMIN이 사업자 회원인 경우*/
		IF @ADMIN_BELONG_TO = @USER_BELONG_TO THEN
        /*정보변경 대상자가 정보처리를 요청하는 사용자의 소속 사업자가 동일한 경우 */
			IF @USER_CLASS < @ADMIN_CLASS THEN
			/*정보변경 대상자의 @USER_CLASS가 정보처리를 요청하는 사용자보다 상위 레벨(@USER_CLASS < @ADMIN_CLASS)인 경우에는 권한이 부여되지 않도록 한다.*/
				SET OUT_RIGHTS = FALSE;
			ELSE
				IF @USER_CLASS = @ADMIN_CLASS THEN
				/*정보변경 대상자의 @USER_CLASS가 정보처리를 요청하는 사용자와 동일한 레벨인 경우에는 본인의 정보 이외에는 권한이 부여되지 않도록 한다.*/
					IF IN_USER_REG_ID <> IN_TARGET_USER_REG_ID THEN
					/*정보처리요청자(ADMIN)과 정보처리대상자(USER)가 동일인이 아닌 경우에는 권한이 부여되지 않도록 한다.*/
						SET OUT_RIGHTS = FALSE;
					ELSE
					/*정보처리요청자(ADMIN)과 정보처리대상자(USER)가 동일인인 경우에는 권한이 DELETE권한을 제외한 모든 권한이 부여되지 않도록 한다.*/
						IF IN_JOB = 'DELETE' THEN
							/*정보를 삭제하는 경우에는 권한이 부여되지 않는다.*/
							SET OUT_RIGHTS = FALSE;
						ELSE
							/*정보를 삭제하는 경우를 제외한 경우에는 모든 권한이 부여된다.*/
							SET OUT_RIGHTS = TRUE;
						END IF;
					END IF;
				ELSE
				/*정보변경 대상자의 @USER_CLASS가 정보처리를 요청하는 사용자와 하위 레벨인 경우에는 모든 권한이 부여되도록 한다.*/
					SET OUT_RIGHTS = TRUE;
				END IF;
			END IF;
        ELSE
        /*정보변경 대상자가 정보처리를 요청하는 사용자의 소속 사업자가 다른 경우 */
			IF @ADMIN_CLASS = 201 THEN
            /*정보수정을 요청하는 사용자의 CLASS가 201(사업자 회원에 속한 최고 관리자)인 경우에는 자회사 사용자에 대한 모든 권한이 부여된다.*/
				SELECT @USER_BELONG_TO IN (SELECT CHILD.ID FROM COMPANY CHILD LEFT JOIN COMPANY PARENT ON CHILD.P_COMP_ID = PARENT.ID WHERE PARENT.ID = @ADMIN_BELONG_TO) INTO @IS_SUBSIDIARY;
				/*ADMIN이 변경하려는 사용자가 소속한 사업자의 모회사 관리자인 경우 @IS_SUBSIDIARY=1, 그렇지 않으면 @IS_SUBSIDIARY=0이 됨*/
				IF @IS_SUBSIDIARY = 1 THEN
					SET OUT_RIGHTS = TRUE;
				ELSE
					SET OUT_RIGHTS = FALSE;
				END IF;
            ELSE
            /*정보수정을 요청하는 사용자의 CLASS가 201(사업자 회원에 속한 최고 관리자)이 아닌 경우에는 자회사에 대한 권한이 없다.*/
				SET OUT_RIGHTS = FALSE;
            END IF;
        END IF;
    END IF;
END