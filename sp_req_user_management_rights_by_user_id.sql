CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_user_management_rights_by_user_id`(
	IN IN_USER_ID				BIGINT,											/*관리자 권한을 요구하는 사용자 아이디*/
    IN IN_TARGET_USER_ID		BIGINT,											/*관리자가 변경 또는 삭제 등의 정보 처리작업을 해야 하는 대상이 되는 사용자 아이디*/
    OUT rtn_val 				INT,											/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)									/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_user_management_rights_by_user_id
Input param 	: 3개
Output param 	: 1개
Job 			: admin의 자격을 요구하는 사용자에게 실행하고자 하는 작업에 대한 권한이 있는지를 체크한 후 boolean으로 값을 반환함
				: 1. TRUE : 자격 있음
				: 2. FALSE : 자격 없음
Update 			: 2022.01.17
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	CALL sp_req_user_affiliation_by_user_id(IN_USER_ID, @ADMIN_BELONG_TO);
    /*IN_USER_ID가 어디에 소속되어 있는지를 확인하고 그 값을 반환한다.*/
    /*0 : 개인회원 또는 sys.admin, 1이상인 경우 : 사업자에 소속된 회원*/

	CALL sp_req_user_affiliation_by_user_id(IN_TARGET_USER_ID, @USER_BELONG_TO);
    /*IN_TARGET_USER_ID가 어디에 소속되어 있는지를 확인하고 그 값을 반환한다.*/
    /*0 : 개인회원 또는 sys.admin, 1이상인 경우 : 사업자에 소속된 회원*/
    
	CALL sp_req_user_class_by_user_reg_id(IN_USER_ID, @ADMIN_CLASS);
	/*정보를 처리를 요청하는 사용자의 CLASS를 구하여 @ADMIN_CLASS에 저장한다.*/
    
	CALL sp_req_user_class_by_user_reg_id(IN_TARGET_USER_ID, @USER_CLASS);
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
            /*ADMIN이 sys.admin:101인 경우*/
				IF IN_USER_ID = IN_TARGET_USER_ID THEN
                /*ADMIN이 sys.admin:101인 경우에 처리할 정보가 본인인 경우*/
					SET @rtn_val = 33101;
					SET @msg_txt = 'The highest authority in Chium cannot delete his or her account';
				ELSE
                /*ADMIN이 처리할 정보가 본인이 아닌 경우에는 모든 권한이 부여된다.*/
					SET @rtn_val = 0;
					SET @msg_txt = 'success';
                END IF;
            ELSE
            /*ADMIN이 sys.admin:101이 아닌 경우*/
				IF @USER_CLASS <= @ADMIN_CLASS THEN
				/*정보변경 대상자의 @USER_CLASS가 정보처리를 요청하는 사용자보다 상위 레벨(@USER_CLASS <= @ADMIN_CLASS)인 경우에는 권한이 부여되지 않도록 한다.*/
					SET @rtn_val = 33102;
					SET @msg_txt = 'Chium administrators cannot delete same or upper-level authorities';
				ELSE
				/*정보변경 대상자의 @USER_CLASS가 정보처리를 요청하는 사용자보다 하위 레벨(@USER_CLASS > @ADMIN_CLASS)인 경우에는 권한이 정상처리한다.*/
					IF @ADMIN_CLASS = 102 THEN
					/*삭제권자가 치움의 관리자인 경우*/
						IF @USER_CLASS >= 200 THEN
                        /*삭제대상자가 개인이거나 사업자의 관리자인 경우에는 정상처리한다.*/
							SET @rtn_val = 0;
							SET @msg_txt = 'success';
                        ELSE
                        /*삭제대상자가 치움관리자인 경우에는 예외처리한다.*/
							SET @rtn_val = 33103;
							SET @msg_txt = 'Chium administrators cannot delete Chium internal users';
                        END IF;
					ELSE
					/*삭제권자가 치움의 일반 사용자인 경우*/
						IF IN_USER_ID = IN_TARGET_USER_ID THEN
                        /*삭제권자가 자신의 계정을 삭제시도하는 경우 정상처리한다.*/
							SET @rtn_val = 0;
							SET @msg_txt = 'success';
                        ELSE
                        /*삭제권자가 타인의 계정을 삭제시도하는 경우 예외처리한다.*/
							SET @rtn_val = 33104;
							SET @msg_txt = 'The highest authority in Chium cannot delete his or her account';
                        END IF;
					END IF;
				END IF;
            END IF;
        ELSE
        /*ADMIN이 개인회원인 경우*/
			IF IN_USER_ID = IN_TARGET_USER_ID THEN
            /*ADMIN과 USER가 동일한 사용자인 경우*/
				SET @rtn_val = 0;
				SET @msg_txt = 'success';
            ELSE
            /*ADMIN과 USER가 동일한 사용자가 아닌 경우*/
				SET @rtn_val = 33105;
				SET @msg_txt = 'Individual users can only delete their own account';
            END IF;
        END IF;
    ELSE
    /*ADMIN이 사업자 회원인 경우*/
		IF @ADMIN_BELONG_TO = @USER_BELONG_TO THEN
        /*정보변경 대상자가 정보처리를 요청하는 사용자의 소속 사업자가 동일한 경우 */
			SELECT AFFILIATED_SITE INTO @ADMIN_SITE FROM USERS WHERE ID = IN_USER_ID;
			SELECT AFFILIATED_SITE INTO @TARGET_SITE FROM USERS WHERE ID = IN_TARGET_USER_ID;
            IF @ADMIN_SITE = @TARGET_SITE THEN
            /*삭제권자와 삭제대상자의 소속이 같은 사이트인 경우*/
				IF @ADMIN_CLASS = 201 THEN
                /*삭제권자가 사이트의 최고권한자인 경우*/
					SET @rtn_val = 0;
					SET @msg_txt = 'success';
                ELSE
                /*삭제권자가 사이트의 최고권한자가 아닌 경우*/
					SET @rtn_val = 33106;
					SET @msg_txt = 'Normal users of the site do not have the right to delete users';
                END IF;
            ELSE
            /*삭제권자와 삭제대상자의 소속이 다른 사이트인 경우*/
				SELECT B.HEAD_OFFICE INTO @ADMIN_HEAD_OFFICE FROM USERS A LEFT JOIN COMP_SITE B ON A.AFFILIATED_SITE = B.ID WHERE A.ID = IN_USER_ID;
                IF @ADMIN_HEAD_OFFICE = 1 THEN
                /*삭제권자가 소속한 사이트가 HEAD OFFICE인 경우*/
					SET @rtn_val = 0;
					SET @msg_txt = 'success';
                ELSE
                /*삭제권자가 소속한 사이트가 HEAD OFFICE가 아닌 경우*/
					SET @rtn_val = 33107;
					SET @msg_txt = 'Administrators of sites other than the Head Office cannot delete users belonging to other sites';
                END IF;
            END IF;
        ELSE
        /*정보변경 대상자가 정보처리를 요청하는 사용자의 소속 사업자가 다른 경우 */
			SELECT BELONG_TO INTO @ADMIN_COMP FROM USERS WHERE ID = IN_USER_ID;
			SELECT B.P_COMP_ID INTO @TARGET_PARENT_COMP FROM USERS A LEFT JOIN COMPANY B ON A.BELONG_TO = B.ID WHERE A.ID = IN_TARGET_USER_ID;
            IF @ADMIN_COMP = @TARGET_PARENT_COMP THEN
            /*삭제권자가 소속하고 있는 삭제대상자가 소속한 사이트의 모회사인 경우*/
				IF @ADMIN_CLASS = 201 THEN
                /*삭제권자의 권한이 201인 경우*/
					SELECT B.HEAD_OFFICE INTO @ADMIN_HEAD_OFFICE FROM USERS A LEFT JOIN COMP_SITE B ON A.AFFILIATED_SITE = B.ID WHERE A.ID = IN_USER_ID;
					IF @ADMIN_HEAD_OFFICE = 1 THEN
					/*삭제권자가 소속한 사이트가 HEAD OFFICE인 경우*/
						SET @rtn_val = 0;
						SET @msg_txt = 'success';
					ELSE
					/*삭제권자가 소속한 사이트가 HEAD OFFICE가 아닌 경우*/
						SET @rtn_val = 33108;
						SET @msg_txt = 'Administrators of sites other than the Head Office cannot delete users belonging to other sites';
					END IF;
                ELSE
                /*삭제권자의 권한이 201이 아닌 경우*/
					SET @rtn_val = 33109;
					SET @msg_txt = 'In case the deletion requester belonging to the parent company does not have the right to delete the user';
                END IF;
            ELSE
            /*삭제권자가 소속하고 있는 삭제대상자가 소속한 사이트의 모회사가 아닌 경우*/
				SET @rtn_val = 33110;
				SET @msg_txt = 'When a parent company administrator deletes a user in a subsidiary company, the parent company administrator must belong to the Head Office';
            END IF;
        END IF;
    END IF;
END