use chiumdev_2;

/*
DELETE FROM COMPANY WHERE ID=11;
DELETE FROM USERS WHERE ID=11;
*/
/*
SET @JWT = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
SET @FCM = 'cr6ibashGkXco6pDwW16tN:APA91bHvev-K8zpdWMFGoPk5TfyynTO9dDBYudGBInxCvkm4BMYKhvJpvL1NRjE6Dx-62_JQzWjxzZuRX7uAUb3qlnoqS6WPVV5L-e0Zl5PbRaxh0NkQRRwEeJ13DpNLKwERNnR688jP';
call sp_create_company('LEO543', 'PWD543', 'leo name 543', 'leo phone 543', @JWT, @FCM, 'leo 543 company', 'company 543 leo', '4300000000', 'company 543 detail address', 'company 543 contact', '1', '543-54-35435', @rtn_value);
*/
/*
SET @UPDATER_ID = 'LEO777';
SET @USER_ID = 'LEO777';
SET @PWD = 'PWD777112';
SET @USER_NAME = 'leo name 777';
SET @PHONE = 'leo phone 777';
SET @BELONG_TO = 5;
SET @ACTIVE = 1;
SET @CLASS = 201;
call sp_update_user(@UPDATER_ID, @USER_ID, @PWD, @USER_NAME, @PHONE, @BELONG_TO, @ACTIVE, @CLASS, @rtn_value);
*/
/*select @rtn_value;*/

/*delete FROM USERS WHERE ID=4;*/
/*delete FROM COMPANY WHERE ID=5;*/

/*call sp_req_current_time(@current_time);*/
/*select @current_time;*/

/*alter table COMPANY ADD PERMIT_IMG_PATH VARCHAR(200) AFTER P_COMP_ID;*/
/*alter table COMPANY ADD BIZ_REG_IMG_PATH VARCHAR(200) AFTER P_COMP_ID;*/

/*UPDATE COMPANY SET P_COMP_ID=0;*/
/*
CALL sp_member_admin_account_exists('LEO777', @COMP_ID);
SELECT @COMP_ID;
*/
/*
SELECT 6 IN (SELECT CHILD.ID AS PID FROM COMPANY CHILD LEFT JOIN COMPANY PARENT ON CHILD.P_COMP_ID = PARENT.ID WHERE PARENT.ID = 5) INTO @rtn;
select @rtn;
*/
/*
call chiumdev_2.sp_create_user('LEO1509', 'LEO1509-1', 'pwd1509-1', 'leo nam 1509-1', '150-9150-9150', 201, NULL, @rtn_value);
select @rtn_value;
*/

/*
UPDATE USERS SET PHONE = '010-9169-2392' WHERE ID = 0;
*/

/* sp_req_current_time() 테스트 - 시작 *//*
call sp_req_current_time(@current_time);
select @current_time;
*//* sp_req_current_time() 테스트 - 끝 */

/* sp_get_user() 테스트 - 시작 *//*
call sp_get_user('sys.admin', @reg_id, @pwd, @user_name, @phone, @belong_to, @active, @class, @class_nm);
select @reg_id, @pwd, @user_name, @phone, @belong_to, @active, @class, @class_nm;
*//* sp_get_user() 테스트 - 끝 */

/* sp_member_admin_account_exists() 테스트 - 시작 *//*
call sp_member_admin_account_exists('LEO3', @comp_id);
select @comp_id;
*//* sp_member_admin_account_exists() 테스트 - 끝 */

/* sp_req_comp_max_id() 테스트 - 시작 *//*
call sp_req_comp_max_id(@max_id);
select @max_id;
*//* sp_req_comp_max_id() 테스트 - 끝 */

/* sp_req_manager_exists_in_company() 테스트 - 시작 *//*
call sp_req_manager_exists_in_company(4, @manager_exists);
select @manager_exists;
*//* sp_req_manager_exists_in_company() 테스트 - 끝 */

/* sp_req_policy_direction() 테스트 - 시작 *//*
call sp_req_policy_direction('transaction_log', @policy_direction);
select @policy_direction;
*//* sp_req_policy_direction() 테스트 - 끝 */

/* sp_req_policy_exists() 테스트 - 시작 *//*
call sp_req_policy_exists('transaction_log', @policy_exists);
select @policy_exists;
*//* sp_req_policy_exists() 테스트 - 끝 */

/* sp_req_super_permission() 테스트 - 시작 */
/* 사용자가 모회사의 관리자인 경우 테스트 *//*
call sp_req_super_permission('LEO777', 6, @permission);
select @permission;
*//* 사용자가 본인이 소속한 사업자의 관리자인 경우 테스트 *//*
call sp_req_super_permission('LEO777', 5, @permission);
select @permission;
*//* 사용자가 치움 본사의 수퍼 관리자인 경우 테스트 *//*
call sp_req_super_permission('sys.admin', null, @permission);
select @permission;
*//* 사용자와 무관한 사업자의 경우 테스트 *//*
call sp_req_super_permission('LEO777', 2, @permission);
select @permission;
*//* sp_req_super_permission() 테스트 - 끝 */

/* sp_req_use_same_company_reg_id() 테스트 - 시작 *//*
call sp_req_use_same_company_reg_id('165-25-23655', @biz_reg_code_exists);
select @biz_reg_code_exists;
*//* sp_req_use_same_company_reg_id() 테스트 - 끝 */

/* sp_req_use_same_phone() 테스트 - 시작 *//*
call sp_req_use_same_phone('010-9169-2392', 1, 1, @phone_already_registered);
select @phone_already_registered;
*//* sp_req_use_same_phone() 테스트 - 끝 */

/* sp_req_user_class() 테스트 - 시작 *//*
call sp_req_user_class('sys.admin', @class);
select @class;
*//* sp_req_user_class() 테스트 - 끝 */

/* `sp_req_user_exists`() 테스트 - 시작 *//*
call `sp_req_user_exists`('sys.admin', 1, @user_exists);
select @user_exists;
*//* `sp_req_user_exists`() 테스트 - 끝 */

/* `sp_req_user_max_id`() 테스트 - 시작 *//*
call `sp_req_user_max_id`(@user_max_id);
select @user_max_id;
*//* `sp_req_user_max_id`() 테스트 - 끝 */


/* `sp_req_usr_validation`() 테스트 - 시작 *//*
call `sp_req_usr_validation`('sys.admin1', @state_code, @msg_txt);
select @state_code, @msg_txt;
*//* `sp_req_usr_validation`() 테스트 - 끝 */

/* sp_create_company 테스트 시작*/
/* 성공케이스 1 : 신규사업자가 신규 사업자 계정을 생성하는 경우 */
/*call sp_create_company('samsung.admin', 'ss.pwd', '이삼성', '010-1254-5698', 'samsung', '이재용', '1100000000', '회현로 1가 100', '02-1254-8965', '1', '123-32-12321', @rtn_value);*/
/* 성공케이스 2 : 모회사 관리자가 신규 사업자(자회사) 계정 생성을 시도하는 경우 */
/*call sp_create_company('삼성전자관리자', '삼성전자관리자암호2', '삼성전자관리자이름2', '010-456-5422', '삼성전기', '삼성전기회장', '4300000000', '남대문로 1가 101', '02-9876-9876', '1', '458-74-58745', @rtn_value);*/
/* 실패케이스 1 : 치움관리자가 신규 사업자 계정 생성을 시도하는 경우 - error:20009 */
/*call sp_create_company('sys.admin', '1234', 'chium_admin', '010-9169-2392', 'samsung', '이재용', '1100000000', '회현로 1가 100', '02-1254-8965', '1', '123-32-12322', @rtn_value);*/


/* `sp_create_user`() 테스트 - 시작 */
/*
call `sp_create_user`('삼성전자관리자', '삼성전자관리자3', '삼성전자관리자암호3', '삼성전자관리자이름3', '010-456-5433', 202, 9, @result);
select @result;
*/
/* `sp_create_user`() 테스트 - 끝 */


/* `sp_update_user`() 테스트 - 시작 */
/*success : 본사관리자가 자회사 관리자를 비활성 상태로 변경하는 경우 - 시작*//*
call `sp_update_user`('samsung.admin', '삼성전자관리자', '삼성전자관리자암호', '삼성전자관리자이름', '010-456-5456', 9, 0, 201, @result);
select @result;
*//*success : 본사관리자가 자회사 관리자를 비활성 상태로 변경하는 경우 - 끝*/

/*success : sys.admin이 회원사의 자회사 관리자를 비활성 상태로 변경하는 경우 - 시작*/
/*
call `sp_update_user`('sys.admin', '삼성전자관리자', '삼성전자관리자암호', '삼성전자관리자이름1', '010-456-5463', 9, 1, 201, @result);
select @result;
*/
/*success : 본사관리자가 자회사 관리자를 비활성 상태로 변경하는 경우 - 끝*/
/* `sp_update_user`() 테스트 - 끝 */

/*
call sp_req_usr_validation('sys.admin', @state_code, @msg_txt);
select @state_code, @msg_txt;
*/
/*
CALL sp_req_user_management_rights('삼성전자관리자', '삼성전자관리자', 'UPDATE', @IS_UPDATOR_ABLE_TO_UPDATE);
SELECT @IS_UPDATOR_ABLE_TO_UPDATE;
*/
/*UPDATE USERS SET ACTIVE = TRUE, UPDATED_AT = CURRENT_TIMESTAMP WHERE USER_ID = 'LEO999';*/
/*
call sp_delete_user('samsung.admin', 'LEO100', @rtn_val);
select @rtn_val;
*/
/*
ALTER TABLE COMPANY ADD PERMIT_REG_CODE VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER BIZ_REG_CODE;
ALTER TABLE COMPANY ADD PERMIT_REG_IMG_PATH VARCHAR(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER BIZ_REG_IMG_PATH;
*/
/*
ALTER TABLE COMPANY ADD CHECKER_ID BIGINT DEFAULT NULL AFTER PERMIT_REG_IMG_PATH;
ALTER TABLE COMPANY ADD CONFIRMED TINYINT DEFAULT FALSE AFTER CHECKER_ID;
ALTER TABLE COMPANY ADD CONFIRMED_AT DATETIME DEFAULT NULL AFTER CONFIRMED;
*/
/*
ALTER TABLE USERS RENAME JWT_TOKEN TO JWT;
*/
/*
ALTER TABLE USERS RENAME COLUMN FCM_TOKEN TO FCM;
*/
/*
ALTER TABLE USERS MODIFY COLUMN FCM VARCHAR(200);
*/
/*
SET @USER_ID = 'LEO888';
SET @COMP_ID = 17;
SET @COMP_NAME = 'LEO9_NEWNAME13';
SET @REP_NAME = 'LEO9 NEW REPNAME';
SET @KIKCD_B_CODE = '4300000000';
SET @ADDR = 'NEW ADDR LEO999';
SET @CONTACT = '02-000-0000';
SET @TRMT_BIZ_CODE = '2';
SET @BIZ_REG_CODE = '258-96-32147';
CALL sp_update_company(@USER_ID, @COMP_ID, @COMP_NAME, @REP_NAME, @KIKCD_B_CODE, @ADDR, @CONTACT, @TRMT_BIZ_CODE, @BIZ_REG_CODE, @rtn_val, @msg_txt);
SELECT @rtn_val, @msg_txt;
*/
/*
CALL sp_update_company('LEO888', 7, 'LEO9_NEWNAME1', 'LEO9 NEW REPNAME', '4300000000', '새로운 주소 LEO999', '02-000-0000', '2', '258-96-32147', @rtn_val);
SELECT @rtn_val;
*/
/*
alter database chiumdev_2 character set utf8mb4 collate utf8mb4_unicode_ci;
*/
/*
alter table sys_log character set utf8mb4 collate utf8mb4_unicode_ci;
*/

/*
ALTER TABLE COMPANY DROP COLUMN PERMIT_IMG_PATH;
*/
/*
CALL sp_update_wste_cls(1, 1, '111, 222, 333, 444', CURRENT_TIMESTAMP, @rtn_val, @msg_txt);
SELECT @rtn_val, @msg_txt;
*/
/*
DELETE FROM COMP_WSTE_CLS_MATCH;
*/
/*
CALL sp_count_items_in_list('1, 2, 3', @rtn_val);
select @rtn_val;
*/

/*
call sp_req_current_time(@curr_time);
INSERT INTO sys_policy(classification, owner_id, policy, direction, active, created_at, updated_at) values('system', 0, 'max_count_of_business_area', '3', 1, @curr_time, @curr_time);
*/
/*
ALTER TABLE sys_policy ADD authority_level int AFTER owner_id;
update sys_policy set authority_level = 101
*/
/*
ALTER TABLE sys_policy ADD classfication enum('system','company','person') DEFAULT NULL AFTER id;
*/

/*
ALTER TABLE sys_policy RENAME COLUMN classfication TO classification;
*/
/*
update sys_policy set classification='system', owner_id=0
*/
/*
update sys_policy set policy = 'the_way_selecting_bidder' where id=3
*/
/*
SELECT A.USER_ID, A.BELONG_TO, B.ID FROM USERS A LEFT JOIN COMPANY B ON A.BELONG_TO = B.ID WHERE B.ID IS NOT NULL;
*/

/*
CALL sp_test(1,2,@sum);
select @sum;
*/
/*
call sp_req_current_time(@reg_dt);
insert into sys_policy(classification, owner_id, authority_level, policy, direction, active, created_at, updated_at) values('system', 0, 101, 'allow_phone_multiple_registration','0',1,@reg_dt, @reg_dt)
*/

/*
SET @OUT_PARAM = 0;
SELECT COUNT(A.ID) INTO @OUT_PARAM FROM COMPANY A LEFT JOIN COMP_SITE B ON A.ID = B.COMP_ID WHERE A.ID = 1 AND A.ACTIVE = 1;
SELECT @OUT_PARAM;
*/
/*
CALL sp_search_some_text_in_all_procedures('sp_req_biz_admin_id');
*/

/*
DELETE FROM USERS WHERE ID=11;
DELETE FROM COMPANY WHERE ID=11;
DELETE FROM COMP_SITE WHERE ID=1;
*/
/*
SET @IN_USER_ID = 'collector01';
SET @IN_PWD = '1234';
SET @IN_USER_NAME = 'user-tester03';
SET @IN_PHONE = '011-0000-1000';
SET @IN_COMP_NAME = '1';
SET @IN_REP_NAME = '1';
SET @IN_KIKCD_B_CODE = '4181000000';
SET @IN_ADDR = '마을면 계록리 100';
SET @IN_CONTACT = '1';
SET @IN_TRMT_BIZ_CODE = '1';
SET @IN_BIZ_REG_CODE = '122112211221';
SET @IN_LAT = 1.1;
SET @IN_LNG = 1.1;
CALL sp_create_company(
	@IN_USER_ID,
    @IN_PWD,
    @IN_USER_NAME,
    @IN_PHONE,
    @IN_COMP_NAME,
    @IN_REP_NAME,
    @IN_KIKCD_B_CODE,
    @IN_ADDR,
    @IN_LAT,
    @IN_LNG,
    @IN_CONTACT,
    @IN_TRMT_BIZ_CODE,
    @IN_BIZ_REG_CODE
);
*/

/*
SET @IN_CREATOR_ID = 6;
SET @IN_COMP_ID = 8;
SET @IN_KIKCD_B_CODE = '4182000008';
SET @IN_ADDR = 'samsung.admin8_ADDR1';
SET @IN_SITE_NAME = 'samsung.admin8_NAME1';
SET @IN_CONTACT = 'samsung.admin8_CONTACT1';
CALL sp_create_site(
	@IN_CREATOR_ID,
    @IN_COMP_ID,
    @IN_KIKCD_B_CODE,
    @IN_ADDR,
    @IN_SITE_NAME,
    @IN_CONTACT,
    @RESULT,
    @OUT_rtn_val,
    @OUT_msg_txt
);
SELECT @RESULT,
    @OUT_rtn_val,
    @OUT_msg_txt
*/
/*
DELETE FROM COMP_SITE WHERE ID=2;
*/
/*
ALTER TABLE USERS ADD AFFILIATED_SITE BIGINT COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER BELONG_TO;
*/
/*
CALL sp_req_super_permission_by_userid(
				11,
                11,
                @PERMISSION,
                @IS_SITE_HEAD_OFFICE
            );
select @PERMISSION, @IS_SITE_HEAD_OFFICE
*/
/*
SELECT B.HEAD_OFFICE INTO OUT_HEAD_OFFICE FROM USERS A LEFT JOIN COMP_SITE B ON A.AFFILIATED_SITE = B.ID WHERE A.ID = IN_USER_REG_ID; 
*/
/*
SELECT CHILD.ID FROM COMPANY CHILD LEFT JOIN COMPANY PARENT ON CHILD.P_COMP_ID = PARENT.ID WHERE PARENT.ID = 11;
*/
/*
SELECT 9 IN (SELECT CHILD.ID FROM COMPANY CHILD LEFT JOIN COMPANY PARENT ON CHILD.P_COMP_ID = PARENT.ID WHERE PARENT.ID = 8) INTO @IS_SUBSIDIARY;
SELECT @IS_SUBSIDIARY;
*/
/*
CALL sp_req_super_permission(
				'samsung.admin',
                9,
                @PERMISSION
            );
select @PERMISSION
*/
/*
call sp_req_whether_site_is_open(
	11,
    @param
);

select @param;
*/

/*
SET @CREATOR_ID = 0;
SET @USER_ID = 'system_user1';
SET @PWD = 'ystem_user1_PWD';
SET @USER_NAME = 'ystem_user1_NAME';
SET @PHONE = 'ystem_user1_PHONE';
SET @CLASS = 102;
SET @JWT = 'ystem_user1_JWT';
SET @FCM = 'ystem_user1_FCM';
SET @SITE_ID = 0;
SET @DEPARTMENT = NULL;

CALL sp_create_user(
	@CREATOR_ID, 
    @USER_ID, 
    @PWD, 
    @USER_NAME, 
    @PHONE, 
    @CLASS, 
    @JWT, 
    @FCM, 
    @SITE_ID, 
    @DEPARTMENT, 
    @USER_REG_ID, 
    @rtn_val, 
    @msg_txt
);
SELECT @USER_REG_ID, @rtn_val, @msg_txt
*/



/*
SET @CREATOR_ID = 'sys.admin';
SET @USER_ID = 'bit_seo';
SET @PWD = 'bit_seo_PWD';
SET @USER_NAME = '서빛';
SET @PHONE = 'bit_seo_PHONE';
SET @CLASS = 102;
SET @JWT = 'bit_seo_JWT';
SET @FCM = 'bit_seo_FCM';
SET @SITE_ID = 0;
SET @DEPARTMENT = 'CS';


CALL sp_create_user(
	@CREATOR_ID, 
    @USER_ID, 
    @PWD, 
    @USER_NAME, 
    @PHONE, 
    @CLASS, 
    @JWT, 
    @FCM, 
    @SITE_ID, 
    @DEPARTMENT, 
    @USER_REG_ID, 
    @rtn_val, 
    @msg_txt
);
SELECT @USER_REG_ID, @rtn_val, @msg_txt
*/

/*
DELETE FROM USERS WHERE ID=13
*/
/*
CALL sp_req_super_permission_by_userid(
				11,
                11,
                @PERMISSION,
                @IS_SITE_HEAD_OFFICE
            );
select @PERMISSION, @IS_SITE_HEAD_OFFICE
*/
    
/*    
SET @IN_USER_ID 			= 11;
SET @IN_COMP_ID 			= 11;
SET @IN_KIKCD_B_CODE 		= '4100000000';
SET @IN_ADDR 				= 'admin002_NEW_SITE_ADDR';
SET @IN_SITE_NAME 			= 'admin002_NEW_SITE';
SET @IN_CONTACT 			= 'admin002_NEW_SITE_CONTACT';

CALL sp_create_site(
	@IN_USER_ID,
	@IN_COMP_ID,
	@IN_KIKCD_B_CODE,
	@IN_ADDR,
	@IN_SITE_NAME,
	@IN_CONTACT,
    @rtn_val,
    @msg_txt
);
SELECT  @rtn_val,
    @msg_txt
*/


/*
ALTER TABLE COMP_SITE ADD PERMIT_REG_IMG_PATH VARCHAR(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER HEAD_OFFICE;
ALTER TABLE COMP_SITE ADD PERMIT_REG_CODE VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER HEAD_OFFICE;
*/

/*
SET @USER_ID = 'sys.admin';
SET @COMP_ID = 14;
CALL sp_delete_company(
	@USER_ID,
    @COMP_ID,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val, @msg_txt;
*/

/*
ALTER TABLE COMPANY ADD RECOVERY_TAG DATETIME DEFAULT NULL AFTER UPDATED_AT;
ALTER TABLE USERS ADD RECOVERY_TAG DATETIME DEFAULT NULL AFTER UPDATED_AT;
ALTER TABLE COMP_SITE ADD RECOVERY_TAG DATETIME DEFAULT NULL AFTER UPDATED_AT;
*/

/*
SET @USER_ID 	= 'admin005_site_id-1';
SET @USER_NAME 	= 'admin005_site_user_n';
SET @PHONE 		= 'admin005_site_PHONE-';
CALL sp_req_find_user(
	@USER_ID,
    @USER_NAME,
    @PHONE,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val, @msg_txt
*/

/*
SET @USER_ID 	= 'bit_seo';
SET @PWD 	= 'bit_seo_PWD';
CALL sp_req_user_login(
	@USER_ID,
    @PWD,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val, @msg_txt
*/


/*
SET @USER_NAME 	= 'admin005_site_user_n';
SET @PHONE 		= 'admin005_site_PHONE-';
SET @ACTIVE		= TRUE;
CALL sp_req_user_exists_with_user_name_and_phone(
    @USER_NAME,
    @PHONE,
    @ACTIVE,
    @rtn_val
);
SELECT @rtn_val
*/


/*
SET @USER_NAME 	= '남성현';
SET @PHONE 		= 'sh_nam_PHONE';
CALL sp_req_find_user_id(
    @USER_NAME,
    @PHONE,
    @USER_ID,
    @rtn_val,
    @msg_txt
);
SELECT @USER_ID,
    @rtn_val,
    @msg_txt
*/

/*
SET @PHONE 		= 'sh_nam_PHONE';
SET @PWD 	= '남성현변경암호3';
CALL sp_req_change_user_pwd(
    @PHONE,
    @PWD,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val,
    @msg_txt
*/

/*
SELECT COUNT(ID) INTO @USER_REG_ID FROM USERS WHERE ACTIVE = TRUE AND PHONE = 'sh_nam_PHONE';
SELECT @USER_REG_ID;
*/

/*
UPDATE WSTE_CODE SET WSTE_CLASS = 1 WHERE CODE_1 = '1';
UPDATE WSTE_CODE SET WSTE_CLASS = 3 WHERE CODE_1 = '2';
UPDATE WSTE_CODE SET WSTE_CLASS = 2 WHERE CODE_2 = '40';
UPDATE WSTE_CODE SET WSTE_CLASS = 4 WHERE CODE_1 = '3';
*/
/*
ALTER TABLE WSTE_CODE ADD WSTE_CLASS INT DEFAULT NULL AFTER WSTE_REPT_CLS_CODE;
*/
/*
CALL sp_req_wste_class();
*/


/*
INSERT INTO WSTE_APPEARANCE(ID, KOREAN, ENGLISH, ACTIVE) VALUES(1, '고상', 'solid', TRUE);
INSERT INTO WSTE_APPEARANCE(ID, KOREAN, ENGLISH, ACTIVE) VALUES(2, '액상', 'liquid', TRUE);
*/

/*
SET @USER_ID = 25;
SET @SITE_ID = 5;
SET @TRMT_BIZ_CODE = '3';
SET @PERMIT_REG_CODE = '253_PERMIT_REG_CODE';
SET @PERMIT_IMG_PATH = '253_PERMIT_IMG_PATH';
SET @WSTE_CODE = '91-01-11,91-03-11,91-10-11';
CALL sp_create_collector(
	@USER_ID,
    @SITE_ID,
    @TRMT_BIZ_CODE,
    @PERMIT_REG_CODE,
    @PERMIT_IMG_PATH,
    @WSTE_CODE,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val,
    @msg_txt
*/

/*
CALL sp_req_current_time(
	@REG_DT
);
);

SET @USER_ID = 25;
SET @SITE_ID = 5;
SET @WSTE_CODE = '51-01-01,51-03-01,51-10-01';
CALL sp_update_site_wste_lists_without_handler(
	@USER_ID,
    @WSTE_CODE,
    @SITE_ID,
    @REG_DT,
    @rtn_val,
    @msg_txt
);   
SELECT @rtn_val,
    @msg_txt
*/    
    
/*    
SET @WSTE_CODE = '51-01-01,51-03-01,51-10-01';
CALL sp_update_site_wste_lists(
	@WSTE_CODE,
    @rtn_val,
    @msg_txt
);

SELECT @rtn_val,
    @msg_txt;
*/
/*
alter table WSTE_REGISTRATION_PHOTO ADD FILE_SIZE FLOAT AFTER IMG_PATH;
alter table WSTE_REGISTRATION_PHOTO ADD FILE_NAME VARCHAR(100) AFTER SITE_WSTE_REG_ID;
*/
/*
ALTER TABLE SITE_WSTE_DISPOSAL_ORDER DROP COLUMN CREATOR_ID;
*/
/*
alter table SITE_WORK_ORDER ADD ACTIVE TINYINT AFTER SITE_ID;
*/

/*
call sp_req_current_time(@curr_time);
INSERT INTO sys_policy(classification, owner_id, policy, direction, active, created_at, updated_at) values('system', 0, 'Minimum visit required', '12', 1, @curr_time, @curr_time);
*/

/*
UPDATE sys_policy SET policy = 'minimum_visit_required' WHERE ID = 11;
*/

/*
CALL sp_req_policy_direction('minimun_visit_required', @minimum_required_time);

SET @TIME_REQUIRED = @minimum_required_time + ':00';
SET @OUT_TIME = ADDTIME(CURRENT_TIMESTAMP, @TIME_REQUIRED);
SELECT @OUT_TIME;
*/

/*
call sp_req_current_time(@VISIT_AT);
SET @ASKER_ID = 11;
SET @DISPOSAL_ORDER_ID = 6;
CALL sp_ask_visit_on_disposal_site(
	@ASKER_ID,
    @DISPOSAL_ORDER_ID,
    @VISIT_AT,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val,
    @msg_txt;
*/
/*
CALL sp_req_cancel_visit(
	11,
    6,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val,
    @msg_txt;
*/
/*
SET @OUT_TIME = ADDTIME(CURRENT_TIMESTAMP, '96:00');
update SITE_WSTE_DISPOSAL_ORDER SET VISIT_END_AT = @OUT_TIME WHERE ID = 6;
*/

/*
alter table SITE_WSTE_DISPOSAL_ORDER ADD ORDER_CODE VARCHAR(16) AFTER ACTIVE;
*/
/*
UPDATE COMP_SITE SET KIKCD_B_CODE = '4182000000' WHERE ID = 1;
*/
/*
call sp_req_available_site_addresses_by_user_id(13);
*/

/*
CALL sp_search_some_text_in_all_procedures('SITE_WSTE_REGISTRATION');
*/

/*
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_create_collector', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_create_site_wste_discharged', 'WSTE_DISCHARGED_FROM_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_create_site_wste_photo_information', 'WSTE_REGISTRATION_PHOTO');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_create_site_without_handler', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_cs_confirm_account', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_cs_confirm_account', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_cs_confirm_account', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_delete_company_without_handler', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_delete_company_without_handler', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_delete_company_without_handler', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_delete_user', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_get_company', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_get_site', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_get_site', 'KIKCD_B');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_get_site', 'WSTE_TRMT_BIZ');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_get_user', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_get_user', 'USERS_CLASS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_get_user', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_get_user_by_user_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_get_user_by_user_id', 'USERS_CLASS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_get_user_by_user_id', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_insert_company', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_insert_log', 'sys_log');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_insert_site_wste_discharge_order_without_handler', 'SITE_WSTE_DISPOSAL_ORDER');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_insert_user', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_member_admin_account_exists', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_member_admin_account_exists', 'USERS_CLASS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_member_admin_account_exists', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_member_admin_account_exists_by_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_member_admin_account_exists_by_id', 'USERS_CLASS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_member_admin_account_exists_by_id', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_ask_visit', 'ASK_VISIT_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_biz_admin_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_biz_admin_id', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_cancel_visit', 'ASK_VISIT_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_change_generic_user_pwd', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_change_user_pwd', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_collector_can_ask_visit', 'SITE_WSTE_DISPOSAL_ORDER');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_id_by_reg_code', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_id_of_site', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_id_of_user', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_id_of_user_by_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_max_id', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_name_by_comp_id', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_name_by_site_id', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_name_by_site_id', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_site_addresses', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_site_addresses', 'KIKCD_B');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_site_exists', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_site_exists', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_comp_site_max_id', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_company_exists', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_company_validation', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_count_of_sites', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_count_of_users', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_cs_manager_id_of_company', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_cs_manager_id_of_company', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_cs_manager_in_charge', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_disposal_order_exists', 'SITE_WSTE_DISPOSAL_ORDER');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_find_pwd', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_find_user_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_is_biz_reg_code_duplicate', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_is_site_head_office', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_is_user_collector', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_is_user_collector', 'USERS_CLASS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_is_user_collector', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_is_userid_duplicate', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_manager_exists_in_company', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_manager_exists_in_site', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_parent_comp_id', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_policy_direction', 'sys_policy');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_policy_exists', 'sys_policy');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_same_company_permit_code_exists', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_service_instruction_id_of_site', 'SITE_WORK_ORDER');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_site_addresses_by_site_id', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_site_addresses_by_site_id', 'KIKCD_B');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_site_exists', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_site_id_of_user', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_site_id_of_user_reg_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_super_permission', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_super_permission_by_userid', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_use_same_company_permit_code', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_use_same_company_reg_id', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_use_same_phone', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_affiliation', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_affiliation_by_user_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_class', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_class_by_user_reg_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_exists', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_exists_by_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_exists_with_user_name_and_phone', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_login', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_max_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_regid_by_user_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_user_validation_by_user_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_userid_by_user_reg_id', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_usr_validation', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_wste_class', 'WSTE_CLS_1');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_req_wste_record', 'WSTE_CODE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_update_comp_wste_cls', 'COMP_WSTE_CLS_MATCH');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_update_company', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_update_company_permit_info', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_update_company_permit_info_without_handler', 'COMPANY');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_update_site_permit_info_without_handler', 'COMP_SITE');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_update_site_wste_cls', 'SITE_WSTE_CLS_MATCH');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_update_site_wste_lists_without_handler', 'WSTE_SITE_MATCH');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_update_user', 'USERS');
INSERT INTO sys_table_info_related_to_stored_proc(SP_NAME, TABLE_NAME) VALUES('sp_update_wste_cls', 'SITE_WSTE_CLS_MATCH');
*/

/*
/*
SET @DISPOSAL_ID = 1;
CALL sp_get_duty_to_apply_for_visit(
	@DISPOSAL_ID,
    @DUTY_TO_APPLY_FOR_VISIT
);
SELECT @DUTY_TO_APPLY_FOR_VISIT;
*/
/*
CALL sp_req_visit_date_expired(
	@DISPOSAL_ID,
    @IS_VISIT_DATE_EXPIRED
);
SELECT @IS_VISIT_DATE_EXPIRED;
*/
/*
	SELECT A.AFFILIATED_SITE INTO @OUT_SITE_ID 
    FROM USERS A 
    LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.ID = B.DISPOSER_ID 
    WHERE B.ID = @DISPOSAL_ID;
    SELECT @OUT_SITE_ID ;
*/

/*
alter table SITE_WSTE_DISPOSAL_ORDER ADD SITE_ID BIGINT AFTER DISPOSER_TYPE;
*/
/*
UPDATE SITE_WSTE_DISPOSAL_ORDER SET SITE_ID = 1
*/
/*
alter table BIDDING_DETAILS ADD UPDATED_AT DATETIME AFTER GREENHOUSE_GAS;
alter table BIDDING_DETAILS ADD CREATED_AT DATETIME AFTER GREENHOUSE_GAS;
*/
/*
SET @DISPOSAL_ID = 4;

CALL sp_req_visit_date_expired(
	@DISPOSAL_ID,
	@IS_VISIT_DATE_EXPIRED
);
SELECT @IS_VISIT_DATE_EXPIRED;
*/

/*
SET @DISPOSAL_ID = 6;
CALL sp_req_current_time(@CURRENT_DT);

SELECT VISIT_END_AT
INTO @OUT_IS_VISIT_DATE_EXPIRED
FROM SITE_WSTE_DISPOSAL_ORDER 
WHERE 
	ID = @DISPOSAL_ID AND 
	ACTIVE = TRUE;

SELECT @OUT_IS_VISIT_DATE_EXPIRED < @CURRENT_DT;
*/
/*
call sp_req_current_time(@VISIT_AT);
SET @ASKER_ID = 11;
SET @DISPOSAL_ORDER_ID = 1;
CALL sp_ask_visit_on_disposal_site(
	@ASKER_ID,
    @DISPOSAL_ORDER_ID,
    @VISIT_AT,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val,
    @msg_txt;
 */  

/*
SET @USER_ID = 11;
SET @SITE_ID = 1;
SET @DISPOSAL_ID = 1;
SET @BIDDING_DETAILS = '[{"WSTE_CODE":"51", "UNIT":"Kg", "UNIT_PRICE": 7, "VOLUME": "1", "TRMT_CODE": "1"}, {"WSTE_CODE":"51-01", "UNIT":"Kg", "UNIT_PRICE": 45, "VOLUME": "1", "TRMT_CODE": "2"}]';
call sp_apply_bidding(
    @USER_ID,
    @SITE_ID,
    @DISPOSAL_ID,
    @BIDDING_DETAILS,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val, @msg_txt;
*/


/*
SET @SITE_ID = 1;
SET @DISPOSAL_ID = 1;
SET @BIDDING_DETAILS = '[{"WSTE_CODE":"51", "UNIT":"Kg", "UNIT_PRICE": 7, "VOLUME": "1", "TRMT_CODE": "1"}, {"WSTE_CODE":"51-01", "UNIT":"Kg", "UNIT_PRICE": 45, "VOLUME": "1", "TRMT_CODE": "2"}]';
										CALL sp_insert_bidding_information(
											@SITE_ID,
											@DISPOSAL_ID,
											@BIDDING_DETAILS,
											@rtn_val,
											@msg_txt
										);
SELECT 
											@rtn_val,
											@msg_txt
*/

/*
SET @USER_ID = 11;
SET @SITE_ID = 1;
SET @DISPOSAL_ID = 1;
SET @BIDDING_DETAILS = '[{"WSTE_CODE":"51", "UNIT":"Kg", "UNIT_PRICE": 7, "VOLUME": "1", "TRMT_CODE": "1"}, {"WSTE_CODE":"51-01", "UNIT":"Kg", "UNIT_PRICE": 45, "VOLUME": "1", "TRMT_CODE": "2"}]';

    CALL sp_req_current_time(@REG_DT);
		CALL sp_req_collect_bidding_max_id(
			@COLLECTOR_BIDDING_ID
        );
		INSERT INTO COLLECTOR_BIDDING (
			ID,
			COLLECTOR_ID,
            DISPOSAL_ORDER_ID,
            ACTIVE,
            CREATED_AT,
            UPDATED_AT
        ) VALUES (
			@COLLECTOR_BIDDING_ID,
			@SITE_ID,
            @DISPOSAL_ID,
            TRUE,
            @REG_DT,
            @REG_DT
        );
*/
/*
SET @SITE_ID = 2;
SELECT IF(TRMT_BIZ_CODE < 9, TRUE, FALSE) INTO @OUT_IS_SITE_COLLECTOR FROM COMP_SITE WHERE ID = @IN_SITE_ID;
SELECT @OUT_IS_SITE_COLLECTOR;
*/

/*
SELECT COUNT(ID) 
    INTO @DID_APPLY_FOR_VISIT 
    FROM ASK_VISIT_SITE 
    WHERE 
		ASKER_ID = 11 AND 
        DISPOSAL_ORDER_ID = 1 AND
        ACTIVE = TRUE;
SELECT @DID_APPLY_FOR_VISIT;
*/
/*
UPDATE SITE_WSTE_DISPOSAL_ORDER SET VISIT_END_AT = NULL WHERE ID = 1;
*/

/*
SET @OUT_TIME = ADDTIME(CURRENT_TIMESTAMP, '96:00');
update SITE_WSTE_DISPOSAL_ORDER SET BIDDING_END_AT = @OUT_TIME WHERE ID = 1;
*/

/*
SET @OUT_TIME = ADDTIME(CURRENT_TIMESTAMP, '96:00');
UPDATE SITE_WSTE_DISPOSAL_ORDER SET BIDDING_END_AT = @OUT_TIME WHERE ID = 4;
*/
/*
alter table BIDDING_DETAILS ADD ACTIVE TINYINT AFTER TRMT_CODE;
*/
/*
    SELECT ID INTO @WINNER_ID 
    FROM COLLECTOR_BIDDING 
    WHERE 
		BID_AMOUNT IS NOT NULL AND 
        DISPOSAL_ORDER_ID = 4 AND
        BID_AMOUNT 
        IN (
			SELECT MIN(BID_AMOUNT) 
			FROM COLLECTOR_BIDDING 
			WHERE 
				DISPOSAL_ORDER_ID = 4 AND 
				ACTIVE = TRUE AND 
				BID_AMOUNT IS NOT NULL
		);
	
    SELECT @WINNER_ID;
*/
/*
UPDATE BIDDING_DETAILS SET VOLUME = 1;
*/
/*
DELETE FROM BIDDING_DETAILS;
DELETE FROM COLLECTOR_BIDDING;
DELETE FROM STATUS_HISTORY;
*/


/*
SET @USER_ID = 11;
SET @COLLECT_BIDDING_ID = 4;
call sp_cancel_bidding(
	@USER_ID,
    @COLLECT_BIDDING_ID
);
*/
/*
		CALL sp_req_disposal_id_of_collector_bidding_id(
			@COLLECT_BIDDING_ID,
			@DISPOSAL_ORDER_ID
		);
		CALL sp_req_bidding_end_date_expired(
			@DISPOSAL_ORDER_ID,
			@rtn_val,
			@msg_txt
		);
			CALL sp_req_site_id_of_user_reg_id(
				@USER_ID,
                @USER_SITE_ID,
				@rtn_val,
				@msg_txt
            );
				CALL sp_req_site_already_bid(
					@USER_SITE_ID,
					@DISPOSAL_ORDER_ID,
					@rtn_val,
					@msg_txt
				);
select @DISPOSAL_ORDER_ID, @USER_ID, @USER_SITE_ID, @rtn_val, @msg_txt;
*/


/*
		CALL sp_req_disposal_id_of_collector_bidding_id(
			@COLLECT_BIDDING_ID,
			@DISPOSAL_ORDER_ID
		);
select @DISPOSAL_ORDER_ID;
		
		CALL sp_req_bidding_end_date_expired(
			@DISPOSAL_ORDER_ID,
			@rtn_val,
			@msg_txt
		);
			CALL sp_req_site_id_of_user_reg_id(
				@USER_ID,
                @USER_SITE_ID,
				@rtn_val,
				@msg_txt
            );
				CALL sp_req_site_already_bid(
					@USER_SITE_ID,
					@DISPOSAL_ORDER_ID,
					@rtn_val,
					@msg_txt
				);
					UPDATE COLLECTOR_BIDDING SET CANCEL_BIDDING = TRUE WHERE ID = @COLLECT_BIDDING_ID;
SELECT @USER_ID, @COLLECT_BIDDING_ID, @DISPOSAL_ORDER_ID, @USER_SITE_ID, @rtn_val, @msg_txt;
*/
/*
CALL sp_req_current_time(@CURRENT_DT);

SET @str_month= CONCAT('0', MONTH(@CURRENT_DT));
SELECT @str_month;
*/

/*
CALL sp_search_some_text_in_all_procedures('temporary');
*/


/*
SET @COLLECTOR_SITE_ID = 1;
CREATE TEMPORARY TABLE CURRENT_STATE (
	ORDER_CODE			VARCHAR(10),
	CREATED_AT			DATETIME,
	STATUS_NM_KO		VARCHAR(20),
	VIEW_COUNT			INT
);

INSERT INTO CURRENT_STATE (
	ORDER_CODE,
	CREATED_AT,
	STATUS_NM_KO
) SELECT 
	DISPOSAL_ORDER_CODE,
	CREATED_AT,
	STATUS_NM_KO
FROM V_STATUS_HISTORY
WHERE 
	COLLECTOR_SITE_ID =  @COLLECTOR_SITE_ID;
	
SELECT COUNT(ID) 
INTO @STATUS_COUNT 
FROM V_STATUS_HISTORY 
WHERE 
	COLLECTOR_SITE_ID =  @COLLECTOR_SITE_ID;
	
UPDATE CURRENT_STATE SET VIEW_COUNT = @STATUS_COUNT;

SELECT * FROM CURRENT_STATE;
DROP TEMPORARY TABLE CURRENT_STATE;
*/
/*
SET @USER_ID = 16;
CALL sp_retrieve_current_state(
	@USER_ID,
    @rtn_val,
    @msg_txt
);
*/

/*
SET @SIDO_CODE = '4100000000';

CALL sp_req_sigungu(@SIDO_CODE);
*/
/*
SELECT * FROM KIKCD_B WHERE LOCATE(' ', SI_GUN_GU) > 0 AND CANCELED_DATE IS NULL AND EUP_MYEON_DONG IS NULL ORDER BY B_CODE;
*/
/*
SELECT * FROM KIKCD_B 
WHERE CANCELED_DATE IS NULL AND
	(SI_GUN_GU = '수원시' OR
	SI_GUN_GU = '성남시' OR
	SI_GUN_GU = '안양시' OR
	SI_GUN_GU = '안산시' OR
	SI_GUN_GU = '고양시' OR
	SI_GUN_GU = '용인시' OR
	SI_GUN_GU = '청주시' OR
	SI_GUN_GU = '천안시' OR
	SI_GUN_GU = '전주시' OR
	SI_GUN_GU = '포항시' OR
	SI_GUN_GU = '창원시')
*/
/*
UPDATE KIKCD_B SET JACHIGU = 1 WHERE
 CANCELED_DATE IS NULL AND (
	SI_GUN_GU = '수원시' OR
	SI_GUN_GU = '성남시' OR
	SI_GUN_GU = '안양시' OR
	SI_GUN_GU = '안산시' OR
	SI_GUN_GU = '고양시' OR
	SI_GUN_GU = '용인시' OR
	SI_GUN_GU = '청주시' OR
	SI_GUN_GU = '천안시' OR
	SI_GUN_GU = '전주시' OR
	SI_GUN_GU = '포항시' OR
	SI_GUN_GU = '창원시')
*/

/*
SELECT JSON_ARRAYAGG(JSON_OBJECT('A', COMP_ID, 'B', KIKCD_B_CODE)) INTO @AAA from COMP_SITE;
SELECT @AAA;
*/

/*
SET @USER_ID = 11;
SELECT DISPOSER_ORDER_ID, DISPOSER_ORDER_CODE, IF(DISPOSER_VISIT_END_AT IS NULL, DISPOSER_VISIT_END_AT, DISPOSER_BIDDING_END_AT)
    FROM V_SITE_WSTE_DISPOSAL_ORDER
    WHERE LEFT(DISPOSER_SITE_KIKCD_B_CODE, 5) IN (SELECT LEFT(A.KIKCD_B_CODE, 5) FROM BUSINESS_AREA A LEFT JOIN USERS B ON A.SITE_ID = B.AFFILIATED_SITE WHERE B.ID = @USER_ID);  
*/
/*
SET @USER_ID = 11;
CALL sp_retrieve_current_state(
	@USER_ID,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val, @msg_txt;
*/
/*
CALL sp_retrieve_new_coming(@USER_ID, @rtn_val);
select @rtn_val;
*/
/*
SELECT COUNT(WSTE_REG_ID) INTO @COUNT_OF_WSTE_CLASS FROM V_WSTE_DISCHARGED_FROM_SITE WHERE DISPOSAL_ORDER_ID = 10;
SELECT @COUNT_OF_WSTE_CLASS;
*/

/*
SELECT * FROM USERS WHERE ID = (IF 1 = 1, 1, 2);
*/

/*
SET @IN_TRANSACTION_ID = 1;
SET @IN_STATE = '과거';

CALL sp_req_processing_status(
	@IN_TRANSACTION_ID,
	@IN_STATE,
	@rtn_val,
	@msg_txt
);

SELECT @rtn_val, @msg_txt;
*/
/*
SELECT 
		TRANSACTION_ID, 
        COLLECTOR_SITE_ID,
        COLLECTOR_SITE_NAME,
        DISPOSER_ORDER_ID,
        DISPOSER_ORDER_CODE,
        TRANSACTION_STATE,
        DISPOSER_OPEN_AT
        
    FROM V_WSTE_CLCT_TRMT_TRANSACTION
	WHERE TRANSACTION_ID = @IN_TRANSACTION_ID AND ISNULL(CONFIRMED_AT) = IF(@IN_STATE = '과거', FALSE, TRUE);
*/
/*
SET @STATE = '유찰';
SET @USER_ID = 1;
SET @SQL_STMT = CONCAT(`SELECT COLLECTOR_BIDDING_ID, DISPOSER_ORDER_ID, DISPOSER_ORDER_CODE, 
		IF (STATE = '방문거절', DISPOSER_RESPONSE_VISIT_AT, 
			IF (STATE = '방문대기중', DISPOSER_VISIT_END_AT, 
				IF (STATE = '방문조기마감', DISPOSER_VISIT_EARLY_CLOSED_AT, 
					IF (STATE = '방문포기', COLLECTOR_RECORD_UPDATED_AT, 
						IF (STATE = '입찰중', DISPOSER_BIDDING_END_AT, 
							IF (STATE = '입찰대기중', DISPOSER_BIDDING_END_AT, 
								IF (STATE = '입찰포기', COLLECTOR_RECORD_UPDATED_AT, 
									IF (STATE = '선정중', DISPOSER_BIDDING_END_AT, 
										IF (STATE = '선정대기중', DISPOSER_BIDDING_END_AT, 
											IF (STATE = '낙찰포기', COLLECTOR_REJECTED_AT, 
												IF (STATE = '낙찰', COLLECTOR_RECORD_UPDATED_AT, 
													IF (STATE = '유찰', DISPOSER_BIDDING_END_AT, 
														DISPOSER_BIDDING_END_AT
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		), STATE
    FROM V_COLLECTOR_BIDDING
	WHERE COLLECTOR_SITE_ID IN (SELECT AFFILIATED_SITE FROM USERS WHERE ID = 11 AND ACTIVE = TRUE);`);
PREPARE dquery1 FROM @SQL_STMT;
EXECUTE dquery1;
*/



/*
SET @USER_ID = 11;
SET @SITE_ID = 100;
SET @KEY_STR = 'PUSH';
SET @VAL = 0;
CALL sp_update_site_configuration(
	@USER_ID,
	@SITE_ID,
	@KEY_STR,
	@VAL,
	@rtn_val,
	@msg_txt
);

SELECT @rtn_val,
	@msg_txt;
*/

/*
SET @USER_ID = 11;
SET @DISPOSAL_ID = 1;
SET @BIDDING_DETAILS = '[{"WSTE_CODE":"51", "UNIT":"Kg", "UNIT_PRICE": 7, "VOLUME": "1", "TRMT_CODE": "1"}, {"WSTE_CODE":"51-01", "UNIT":"Kg", "UNIT_PRICE": 45, "VOLUME": "1", "TRMT_CODE": "2"}]';

CALL sp_apply_bidding(
	@USER_ID,
	@DISPOSAL_ID,
	@BIDDING_DETAILS
);
*/

/*
SET @SITE_ID = 2;
CALL sp_create_site_configuration(
	@SITE_ID
);
*/


/*
SET @CREATOR_ID = 16;
SET @USER_ID = 'hello2';
SET @PWD = 'password';
SET @USER_NAME = 'user name';
SET @PHONE = '000-0000-9997';
SET @CLASS = 202;
SET @SITE_ID = 5;
SET @DEPARTMENT = NULL;
CALL sp_create_user(
	@CREATOR_ID,
	@USER_ID,
	@PWD,
	@USER_NAME,
	@PHONE,
	@CLASS,
	@SITE_ID,
	@DEPARTMENT
);
*/
/*
SET @USER_REG_ID = 13;
SET @COMP_ID = 11;
*/
/*
CALL sp_delete_company(
	@USER_REG_ID,
    @COMP_ID
);
*/
/*
CALL sp_req_user_exists_by_id(
	@USER_REG_ID, 
	TRUE, 
	@USER_EXISTS
);

SELECT @USER_EXISTS;
*/

/*    
CALL sp_req_super_permission_by_userid(
	@USER_REG_ID, 
	@COMP_ID, 
	@PERMISSION, 
	@IS_USER_SITE_HEAD_OFFICE
);
SELECT 
	@PERMISSION, 
	@IS_USER_SITE_HEAD_OFFICE;
*/
/*
SET @USER_ID = 23;
SET @COLLECTOR_BIDDING_ID = 1;
SET @RES = 1;
*/
/*
CALL sp_req_site_id_of_user_reg_id(
	@USER_ID,
	@USER_SITE_ID
);
SELECT @USER_SITE_ID;
*/

/*
CALL sp_req_dispoer_site_id_of_collector_bidding_id(
	@COLLECTOR_BIDDING_ID,
	@DISPOSER_SITE_ID
);
SELECT @DISPOSER_SITE_ID;
*/
/*
SELECT DISPOSER_SITE_ID INTO @SITE_ID FROM V_COLLECTOR_BIDDING WHERE COLLECTOR_BIDDING_ID = @COLLECTOR_BIDDING_ID;
SELECT @SITE_ID;
*/
/*
CALL sp_req_user_class_by_user_reg_id(
	@USER_ID,
	@USER_CLASS
);
SELECT @USER_CLASS;
*/
/*
SET @USER_ID = 11;
SET @COLLECTOR_BIDDING_ID = 2;
SET @RES = 1;
CALL sp_disposer_response_visit(
	@USER_ID,
    @COLLECTOR_BIDDING_ID,
    @RES
);
*/

/*
CALL sp_req_current_time(@REG_DT);
UPDATE COLLECTOR_BIDDING SET RESPONSE_VISIT = TRUE, RESPONSE_VISIT_AT = @REG_DT WHERE ID = @COLLECTOR_BIDDING_ID;
SELECT ROW_COUNT();
*/

/*
SET @DISPOSER_ID = 2;
SET @COLLECTOR_ID = 2;
SET @KIKCD_B_CODE = '4181000000';
SET @ADDR = '마을면 계록리 100';
SET @VISIT_END_AT = ADDTIME(CURRENT_TIMESTAMP, '96:00');
SET @BIDDING_END_AT = ADDTIME(CURRENT_TIMESTAMP, '96:00');
SET @OPEN_AT = ADDTIME(CURRENT_TIMESTAMP, '24:00');
SET @CLOSE_AT = ADDTIME(CURRENT_TIMESTAMP, '192:00');
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPERANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPERANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new";
CALL sp_create_site_wste_discharge_order(
	@DISPOSER_ID,
	@COLLECTOR_ID,
	@KIKCD_B_CODE,
	@ADDR,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE
);
*/

/*
SET @USER_ID =1;
SET @SIGUNGU_CODE = '4182000000';
SET @IS_DEFAULT = 1;
CALL sp_add_sigungu(
	@USER_ID,
	@SIGUNGU_CODE,
	@IS_DEFAULT
);
*/

/*
SET @AAA=0;
SELECT IF(@AAA=0, 1, 2);
*/

/*
SET @A = 10;
SET @B = 20;
SET @SQL_TEMP = CONCAT('CALL sp_test(', @A, ',', @B,')');
PREPARE Q FROM @SQL_TEMP;
EXECUTE Q;
*/

/*

SET @USER_ID 	= 'abcde';
CALL sp_req_user_login(
	@USER_ID,
    @PWD,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val, @msg_txt
*/

/*
CALL sp_retrieve_past_transactions(
11
);
*/

/*
CALL sp_req_current_time(@REG_DT);
select @REG_DT;

*/
/*
set @user_id = 6;
set @DISPOSAL_ORDER_ID = 31;
CALL sp_req_close_visit_early(
	@user_id,
    @DISPOSAL_ORDER_ID
);
*/
/*
	CALL sp_req_user_exists_by_id(
		@user_id,
        TRUE,
		@rtn_val,
		@msg_txt
    );
*/
/*
		CALL sp_req_site_id_of_disposal_order_id(
			@DISPOSAL_ORDER_ID,
            @DISPOSER_SITE_ID
        );
*/
/*
        CALL sp_req_site_id_of_user_reg_id(
			@user_id,
            @USER_SITE_ID,
			@rtn_val,
			@msg_txt
        );
SELECT @USER_SITE_ID,
			@rtn_val,
			@msg_txt;
*/
/*
				CALL sp_req_user_class_by_user_reg_id(
				@user_id,
				@USER_CLASS
                );
                select @USER_CLASS;
*/
/*                
UPDATE SITE_WSTE_DISPOSAL_ORDER SET VISIT_EARLY_CLOSING = TRUE, VISIT_EARLY_CLOSED_AT = @REG_DT WHERE ID = @DISPOSAL_ORDER_ID;
*/

/*
UPDATE SITE_WSTE_DISPOSAL_ORDER SET VISIT_EARLY_CLOSING = null, VISIT_EARLY_CLOSED_AT = null
*/
/*
call sp_retrieve_new_coming(6)
*/
/*
CALL sp_req_collector_bidding_details(4);
*/
/*
SELECT COLLECTOR_BIDDING_ID, DISPOSER_ORDER_ID, DISPOSER_ORDER_CODE, 
		IF (STATE = '방문거절', DISPOSER_RESPONSE_VISIT_AT, 
			IF (STATE = '방문대기중', DISPOSER_VISIT_END_AT, 
				IF (STATE = '방문조기마감', DISPOSER_VISIT_EARLY_CLOSED_AT, 
					IF (STATE = '방문포기', COLLECTOR_RECORD_UPDATED_AT, 
						IF (STATE = '입찰중', DISPOSER_BIDDING_END_AT, 
							IF (STATE = '입찰대기중', DISPOSER_BIDDING_END_AT, 
								IF (STATE = '입찰포기', COLLECTOR_RECORD_UPDATED_AT, 
									IF (STATE = '선정중', DISPOSER_BIDDING_END_AT, 
										IF (STATE = '선정대기중', DISPOSER_BIDDING_END_AT, 
											IF (STATE = '낙찰포기', COLLECTOR_REJECTED_AT, 
												IF (STATE = '낙찰', COLLECTOR_RECORD_UPDATED_AT, 
													IF (STATE = '유찰', DISPOSER_BIDDING_END_AT, 
														DISPOSER_BIDDING_END_AT
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		), STATE
    FROM V_COLLECTOR_BIDDING
	WHERE COLLECTOR_BIDDING_ID = 4;
 
	DROP TABLE IF EXISTS CURRENT_STATE;
    */
/*    
    SET @PERIOD = 1;
    	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'USER_NAME'					, USER_NAME, 
			'PHONE'						, PHONE,
			'AFFILIATED_SITE'			, AFFILIATED_SITE,
			'TRMT_BIZ_CODE'				, TRMT_BIZ_CODE,
			'TRMT_BIZ_NM'				, TRMT_BIZ_NM,
			'SITE_NAME'					, SITE_NAME,
			'USER_CLASS'				, CLASS,
			'USER_CLASS_NM'				, CLASS_NM,
			'ACTIVE'					, ACTIVE,
			'CREATED_AT'				, CREATED_AT,
			'UPDATED_AT'				, UPDATED_AT
		)
	) 
	INTO @json_data 
	FROM V_USERS 
	WHERE 
        CURRENT_TIMESTAMP <= ADDTIME(CREATED_AT, CONCAT(@PERIOD*24, ':00:00'));
	
    SELECT @json_data;
*/  
/* 
    SET @PERIOD = 100;
    	SELECT USER_NAME
			, PHONE
			, AFFILIATED_SITE
			, TRMT_BIZ_CODE
			, TRMT_BIZ_NM
			, SITE_NAME
			, CLASS
			, CLASS_NM
			, ACTIVE
			, CREATED_AT
			, UPDATED_AT
	FROM V_USERS 
	WHERE 
        CURRENT_TIMESTAMP <= ADDTIME(CREATED_AT, CONCAT(@PERIOD, ' 00:00:00'));
	
*/
/*
    SET @PERIOD = 100;
    SET @NUMBER_OF_LIST_IN_A_PAGE = 3;
    SET @PAGE_NO = 2;
    
    SET @STMT = CONCAT("SELECT USER_NAME
			, PHONE
			, AFFILIATED_SITE
			, TRMT_BIZ_CODE
			, TRMT_BIZ_NM
			, SITE_NAME
			, CLASS
			, CLASS_NM
			, ACTIVE
			, CREATED_AT
			, UPDATED_AT
	FROM V_USERS 
	WHERE 
        CURRENT_TIMESTAMP <= ADDTIME(CREATED_AT, CONCAT('", @PERIOD, " 00:00:00')) ORDER BY CREATED_AT DESC LIMIT ?, ?");
	PREPARE STMT FROM @STMT;
    SET @PARAM1 =  @NUMBER_OF_LIST_IN_A_PAGE;
    SET @PARAM2 =  @NUMBER_OF_LIST_IN_A_PAGE * @PAGE_NO;
    EXECUTE STMT USING @PARAM1, @PARAM2;
    */
    
    /*
    SET @PERIOD = 100;
    SET @NUMBER_OF_LIST_IN_A_PAGE = 3;
    SET @PAGE_NO = 2;
	SET @STMT = CONCAT("SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'USER_NAME'					, USER_NAME, 
			'PHONE'						, PHONE,
			'AFFILIATED_SITE'			, AFFILIATED_SITE,
			'TRMT_BIZ_CODE'				, TRMT_BIZ_CODE,
			'TRMT_BIZ_NM'				, TRMT_BIZ_NM,
			'SITE_NAME'					, SITE_NAME,
			'USER_CLASS'				, CLASS,
			'USER_CLASS_NM'				, CLASS_NM,
			'ACTIVE'					, ACTIVE,
			'CREATED_AT'				, CREATED_AT,
			'UPDATED_AT'				, UPDATED_AT
		)
	) 
	INTO ", @json_data, " FROM V_USERS WHERE CURRENT_TIMESTAMP <= ADDTIME(CREATED_AT, '10000:00:00') ORDER BY CREATED_AT DESC LIMIT ?, ?");
    
    
	PREPARE STMT FROM @STMT;
    SET @PARAM1 = @PAGE_NO;
    SET @PARAM2 = @PAGE_NO * @NUMBER_OF_LIST_IN_A_PAGE;
    EXECUTE STMT USING @PARAM1, @PARAM2;   
    SELECT @json_data
    */
    /*
    SET @USER_ID = 100;
    SET @PERIOD = 100;
    SET @NUMBER_OF_LIST_IN_A_PAGE = 3;
    SET @PAGE_NO = 2;
    CALL sp_req_user_list(
		@USER_ID,
		@PERIOD,
		@PAGE_NO,
		@NUMBER_OF_LIST_IN_A_PAGE
    );
    */
/*
SET @USERID = 0; 
SET @PERIOD = 100;
SET @IN_OFFSET = 2;
SET @ITEMS = 3;
CALL sp_req_user_list(
	@USERID,
	@PERIOD,
	@IN_OFFSET,
	@ITEMS
)
*/



/*
SET @IN_USER_ID 			= 40;
SET @IN_SITE_ID 			= 14;
SET @IN_WSTE_LIST	 		= '[{"WSTE_CODE": "51", "WSTE_APPEARANCE": 1}]';
SET @IN_TRMT_BIZ_CODE 		= '1';
SET @IN_PERMIT_REG_CODE 	= '123456789';
SET @IN_PERMIT_IMG_PATH 	= '123456789/MG_PATH';

CALL sp_update_site_permit_info(
	@IN_USER_ID,
	@IN_SITE_ID,
    @IN_WSTE_LIST,
    @IN_TRMT_BIZ_CODE,
    @IN_PERMIT_REG_CODE,
    @IN_PERMIT_IMG_PATH
);
*/

/*
CALL sp_req_disposal_order_details(10);
*/

/*
CALL sp_retrieve_my_disposal_lists(34);
*/
 
 
/*
SET @USER_ID = 11;
SET @SITE_ID = 1;
SET @DISPOSAL_ID = 46;
SET @BIDDING_DETAILS = '[{"WSTE_CODE":"51", "UNIT":"Kg", "UNIT_PRICE": 7, "VOLUME": "1", "TRMT_CODE": "1"}, {"WSTE_CODE":"51-01", "UNIT":"Kg", "UNIT_PRICE": 45, "VOLUME": "1", "TRMT_CODE": "2"}]';
call sp_apply_bidding(
    @USER_ID,
    @DISPOSAL_ID,
    @BIDDING_DETAILS
);
SELECT @rtn_val, @msg_txt;
*/
/*
delete from COLLECTOR_BIDDING WHERE ID=8
*/
/*
SET @IN_USER_ID = 11;
SET @USER_SITE_ID = 1;
SET @IN_DISPOSAL_ORDER_ID = 39;
CALL sp_req_current_time(@REG_DT);
SET @IN_VISIT_AT = '2022-02-18 16:45:41';
CALL sp_ask_visit_on_disposal_site(
	@IN_USER_ID,
    @IN_DISPOSAL_ORDER_ID,
    @IN_VISIT_AT
);
*/
/*
CALL sp_req_site_id_of_user_reg_id(
	@IN_USER_ID,
	@USER_SITE_ID,
	@rtn_val,
	@msg_txt
);
SELECT @USER_SITE_ID, @rtn_val, @msg_txt;
CALL sp_create_collector_bidding(
	@USER_SITE_ID, 
	@IN_DISPOSAL_ORDER_ID, 
	TRUE, 
	@IN_VISIT_AT, 
	@REG_DT,
	@rtn_val,
	@msg_txt
);
SELECT @rtn_val, @msg_txt;
*/
/*
DELETE FROM COLLECTOR_BIDDING WHERE ID = 8;

*/



/*
CALL sp_req_visit_date_expired(
	@IN_DISPOSAL_ORDER_ID,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val,
    @msg_txt
*/
/*
CALL sp_req_current_time(@CURRENT_DT);
SELECT @CURRENT_DT;
*/
/*
	SELECT VISIT_END_AT
    INTO @VISIT_DATE
    FROM SITE_WSTE_DISPOSAL_ORDER 
    WHERE 
		ID = @IN_DISPOSAL_ORDER_ID AND 
        ACTIVE = TRUE;
        
SELECT @VISIT_DATE, @IN_VISIT_AT
*/
/*
set @IN_USER_ID = 18;
set @IN_COLLECTOR_SITE_ID = 1;
call sp_req_prev_transaction_details(
	@IN_USER_ID,
    @IN_COLLECTOR_SITE_ID
);
*/

/*
call sp_req_prev_transaction_site_lists(
13,'3','41220'

);
*/
/*
SET @CREATOR_ID = NULL;
SET @USER_ID = '111';
SET @PWD = '111';
SET @USER_NAME = '111_NAME';
SET @PHONE = '111_PHONE';
SET @CLASS = 201;
SET @SITE_ID = 0;
SET @DEPARTMENT = NULL;

CALL sp_create_user(
	@CREATOR_ID,
	@USER_ID,
	@PWD,
	@USER_NAME,
	@PHONE,
	@CLASS,
	@SITE_ID,
	@DEPARTMENT
);
*/



/*
SET @IN_USER_ID = 11;
SET @USER_SITE_ID = 1;
SET @IN_DISPOSAL_ORDER_ID = 39;
CALL sp_req_current_time(@REG_DT);
SET @IN_VISIT_AT = '2022-02-18 16:45:41';
CALL sp_ask_visit_on_disposal_site(
	@IN_USER_ID,
    @IN_DISPOSAL_ORDER_ID,
    @IN_VISIT_AT
);
*/
/*
CALL sp_req_user_login('sys.admin', '1234');
*/

/*
SET @USER_ID = 1;
SET @SUBJECTS = 'TEST_SUBJECT';
SET @CONTENTS = 'TEST_CONTENTS';
SET @SITE_ID = 1;
SET @CATEGORY = 1;
CALL sp_write_post(
	@USER_ID,
	@SUBJECTS,
	@CONTENTS,
	@SITE_ID,
	@CATEGORY
);
*/
/*
SET @USER_ID = 39;
SET @SITE_ID = 11;
SET @CATEGORY = 1;
SET @IN_OFFSET = 0;
SET @IN_ITEMS = 10;
*/
/*
SELECT POST_ID, POST_SITE_ID, POST_SITE_NAME, POST_CREATOR_ID, POST_CREATOR_NAME, POST_SUBJECTS, POST_CONTENTS, POST_CATEGORY_ID, POST_CATEGORY_NAME, POST_VISITORS, POST_CREATED_AT, POST_UPDATED_AT FROM V_POSTS WHERE POST_SITE_ID = @SITE_ID AND POST_CATEGORY_ID = @CATEGORY ORDER BY POST_UPDATED_AT DESC LIMIT 0, 10;  
*/
/*
CALL sp_req_get_posts(
	@USER_ID,
	@SITE_ID,
	@CATEGORY,
	@IN_OFFSET,
	@IN_ITEMS
);
*/
/*
CALL sp_retrieve_my_disposal_lists(74);
*/



/*
SET @DISPOSER_ID = 72;
SET @COLLECTOR_ID = 0;
SET @KIKCD_B_CODE = '4181000000';
SET @ADDR = '마을면 계록리 100';
SET @VISIT_START_AT = NULL;
SET @VISIT_END_AT = '2022-03-16';
SET @BIDDING_END_AT = NULL;
SET @OPEN_AT = NULL;
SET @CLOSE_AT = NULL;
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPERANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPERANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new";

CALL sp_create_site_wste_discharge_order(
	@DISPOSER_ID,
	@COLLECTOR_ID,
	@KIKCD_B_CODE,
	@ADDR,
	@VISIT_START_AT,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE
);
*/
/*
		CALL sp_req_user_affiliation_by_user_id(
			@DISPOSER_ID,
            @BELONG_TO
        );
            CALL sp_req_site_exists(
				@BELONG_TO,
                TRUE,
				@rtn_val,
				@msg_txt
            );
            
            SELECT @DISPOSER_ID, @BELONG_TO, @rtn_val, @msg_txt
*/

/*
CALL sp_req_trmt_biz_info();
*/


/*
SET @IN_USER_ID 			= 18;
SET @IN_SITE_ID 			= 7;
SET @IN_WSTE_LIST	 		= '[{"WSTE_CODE": "51", "WSTE_APPEARANCE": 1}]';
SET @IN_TRMT_BIZ_CODE 		= '1';
SET @IN_PERMIT_REG_CODE 	= '123456789';
SET @IN_PERMIT_IMG_PATH 	= '123456789/MG_PATH';

CALL sp_update_site_permit_info(
	@IN_USER_ID,
	@IN_SITE_ID,
    @IN_WSTE_LIST,
    @IN_TRMT_BIZ_CODE,
    @IN_PERMIT_REG_CODE,
    @IN_PERMIT_IMG_PATH
);
*/


/*

SET @DISPOSER_ID = 56;
SET @COLLECTOR_ID = 0;
SET @KIKCD_B_CODE = '4181000000';
SET @ADDR = '마을면 계록리 100';
SET @VISIT_START_AT = '2022-03-04';
SET @VISIT_END_AT = '2022-03-10';
SET @BIDDING_END_AT = '2022-03-05';
SET @OPEN_AT = '2022-02-28';
SET @CLOSE_AT = '2022-03-11';
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPERANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPERANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new";

CALL sp_create_site_wste_discharge_order(
	@DISPOSER_ID,
	@COLLECTOR_ID,
	@KIKCD_B_CODE,
	@ADDR,
	@VISIT_START_AT,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE
);
*/
/*
call sp_retrieve_my_disposal_lists(91)
*/

/*
SET @USER_ID = 92;
SET @COLLECTOR_BIDDING_ID = 16;
call sp_cancel_visiting(
	@USER_ID, 
    @COLLECTOR_BIDDING_ID
);
*/
/*
CALL sp_req_user_login('per_emit001', '1234');
*/
/*
CALL sp_req_b_wste_code()
*/

/*
CALL sp_req_policy_direction(
	'max_duration_to_disposal_open_at',
	@max_duration_to_disposal_open_at
);
SET @MAX_OPEN_AT = ADDTIME(NOW(), CONCAT(@max_duration_to_disposal_open_at * 24, ':00:00'));
SELECT @MAX_OPEN_AT
*/

/*
SET @USER_ID=96;
SET @USER_TYPE='Person';
SET @CATEGORY='방문대기중';
CALL sp_retrieve_my_disposal_lists_by_option(@USER_ID, @CATEGORY);
*/

/*
SET @USER_ID=96;
SET @USER_TYPE='Person';
SET @CATEGORY='방문대기중';
SELECT 
		DISPOSER_ORDER_ID, 
        DISPOSER_ORDER_CODE, 
        DISPOSER_SITE_ID,
        
        DISPOSER_VISIT_START_AT,
        DISPOSER_VISIT_END_AT,
        DISPOSER_BIDDING_END_AT,
        DISPOSER_OPEN_AT,
        DISPOSER_CLOSE_AT,
        DISPOSER_SERVICE_INSTRUCTION_ID,
        DISPOSER_VISIT_EARLY_CLOSING,
        DISPOSER_VISIT_EARLY_CLOSED_AT,
        DISPOSER_BIDDING_EARLY_CLOSING,
        DISPOSER_BIDDING_EARLY_CLOSED_AT,
        DISPOSER_CREATED_AT,
        DISPOSER_UPDATED_AT,
        
		IF (STATE = '기존거래', DISPOSER_UPDATED_AT,
			IF (STATE = '방문대기중', DISPOSER_VISIT_START_AT, 
				IF (STATE = '방문중', DISPOSER_VISIT_END_AT, 
					IF (STATE = '입찰중', DISPOSER_BIDDING_END_AT, 
						DISPOSER_CREATED_AT
					)
				)
			)
		), STATE
    FROM V_SITE_WSTE_DISPOSAL_ORDER
	WHERE 
		STATE = @CATEGORY AND 
        IF (@USER_TYPE = 'Person',
			(DISPOSER_ID = @USER_ID),            
			(DISPOSER_SITE_ID IS NOT NULL AND DISPOSER_SITE_ID IN (SELECT AFFILIATED_SITE FROM USERS WHERE ID = @USER_ID AND ACTIVE = TRUE)));
*/

/*
SET @USER_ID = 91;
SET @DISPOSER_ORDER_ID = 114;
CALL sp_req_close_visit_early(
	@USER_ID,
    @DISPOSER_ORDER_ID
)
*/
/*
SET @USER_ID=96;
SET @DISPOSAL_ORDER_ID = 120;
		CALL sp_req_site_id_of_disposal_order_id(
			@DISPOSAL_ORDER_ID,
            @DISPOSER_SITE_ID
        );
        SELECT @DISPOSER_SITE_ID;
*/
/*
CALL sp_req_close_bidding_early(
	@USER_ID,
    @DISPOSAL_ORDER_ID
);
*/
/*
SET @USER_ID = 13;
SET @DISPOSAL_ORDER_ID = 4;
*/
/*
CALL sp_req_site_id_of_disposal_order_id(
	@DISPOSAL_ORDER_ID,
	@DISPOSER_SITE_ID
);
select @DISPOSER_SITE_ID;
*/
/*
CALL sp_req_delete_disposal_order(
	@USER_ID,
	@DISPOSAL_ORDER_ID
);
*/


/*
SET @DISPOSER_ID = 34;
SET @COLLECTOR_ID = 0;
SET @KIKCD_B_CODE = '4181000000';
SET @ADDR = '마을면 계록리 100';
SET @VISIT_START_AT = '2022-02-24 00:00:00';
SET @VISIT_END_AT = '2022-02-28 00:00:00';
SET @BIDDING_END_AT = '2022-03-03 00:00:00';
SET @OPEN_AT = '2022-02-28 00:00:00';
SET @CLOSE_AT = '2022-04-11 00:00:00';
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPERANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPERANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new";

CALL sp_create_site_wste_discharge_order(
	@DISPOSER_ID,
	@COLLECTOR_ID,
	@KIKCD_B_CODE,
	@ADDR,
	@VISIT_START_AT,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE
);
*/
/*
SET @OPEN_AT = '2022-02-28 00:00:00';
				CALL sp_req_policy_direction(
					'max_duration_to_disposal_close_at',
					@max_duration_to_disposal_close_at
				);
				SET @MAX_CLOSE_AT = ADDTIME(@OPEN_AT, CONCAT(CAST(@max_duration_to_disposal_close_at AS UNSIGNED)*24, ':00:00'));
                SELECT @OPEN_AT, @max_duration_to_disposal_close_at, @MAX_CLOSE_AT, CAST(@max_duration_to_disposal_close_at AS UNSIGNED)*24, CONCAT(CAST(@max_duration_to_disposal_close_at AS UNSIGNED)*24, ':00:00'), DATE_ADD(@MAX_CLOSE_AT, INTERVAL CAST(@max_duration_to_disposal_close_at AS UNSIGNED) DAY);
*/                
/*
					CALL sp_req_policy_direction(
						'max_duration_to_disposal_open_at',
						@max_duration_to_disposal_open_at
					);
SET @MAX_OPEN_AT = ADDTIME(@BIDDING_END_AT, CONCAT(@max_duration_to_disposal_open_at * 24, ':00:00'));
select @BIDDING_END_AT, @max_duration_to_disposal_open_at, @MAX_OPEN_AT;
*/


/*
CALL sp_req_collector_bidding_details(4);
*/



/*
SET @USER_ID=96;
SET @USER_TYPE='Person';
SET @CATEGORY='방문대기중';

CALL sp_retrieve_my_disposal_lists(@USER_ID);
*/


/*
SET @USER_ID=96;
SET @USER_TYPE='Person';
SET @CATEGORY='방문대기중';
CALL sp_retrieve_my_disposal_lists_by_option(@USER_ID, @CATEGORY);
*/
/*

SELECT 
		DISPOSER_ORDER_ID, 
        DISPOSER_ORDER_CODE, 
        DISPOSER_SITE_ID,
        
        DISPOSER_VISIT_START_AT,
        DISPOSER_VISIT_END_AT,
        DISPOSER_BIDDING_END_AT,
        DISPOSER_OPEN_AT,
        DISPOSER_CLOSE_AT,
        DISPOSER_SERVICE_INSTRUCTION_ID,
        DISPOSER_VISIT_EARLY_CLOSING,
        DISPOSER_VISIT_EARLY_CLOSED_AT,
        DISPOSER_BIDDING_EARLY_CLOSING,
        DISPOSER_BIDDING_EARLY_CLOSED_AT,
        DISPOSER_CREATED_AT,
        DISPOSER_UPDATED_AT,
        
		IF (STATE = '삭제', DISPOSER_ORDER_DELETED_AT,
			IF (STATE = '기존거래', DISPOSER_UPDATED_AT,
				IF (STATE = '방문대기중', IF (DISPOSER_VISIT_START_AT IS NOT NULL, DISPOSER_VISIT_START_AT, DISPOSER_VISIT_END_AT), 
					IF (STATE = '방문중', DISPOSER_VISIT_END_AT, 
						IF (STATE = '입찰중', DISPOSER_BIDDING_END_AT, 
							DISPOSER_CREATED_AT
						)
					)
				)
			)
		), STATE
    FROM V_SITE_WSTE_DISPOSAL_ORDER
	WHERE 
		STATE = @CATEGORY AND 
        IS_DELETED = FALSE AND
			DISPOSER_ID = @USER_ID;
*/

/*
SET @USER_ID=96;
SET @USER_TYPE='Person';
SET @CATEGORY='입찰중';

CALL sp_retrieve_my_disposal_lists_by_option(@USER_ID, @CATEGORY);
*/

/*
SET @USER_ID = 28;
SET @COLLECTOR_BIDDING_ID = 4;
SET @DISPOSAL_ORDER_ID = 10;
call sp_req_select_collector(
	@USER_ID,
	@COLLECTOR_BIDDING_ID,
	@DISPOSAL_ORDER_ID
);
*/

/*
DROP TABLE IF EXISTS TEMP_POST_LIST_2;
SET @USER_ID = 39;
SET @SITE_ID = 11;
SET @CATEGORY = 1;
SET @IN_OFFSET = 0;
SET @IN_ITEMS = 10;


CALL sp_req_get_posts(
	@USER_ID,
	@SITE_ID,
	@CATEGORY,
	@IN_OFFSET,
	@IN_ITEMS
);
*/

/*
SET @USER_ID=96;
SET @USER_TYPE='Person';
SET @CATEGORY='방문대기중';
CALL sp_retrieve_my_disposal_lists_by_option(@USER_ID, @CATEGORY);
*/


/*
SET @SITE_ID = 1;
SET @CATEGORY = 1;
SET @OFFSETS = 10;
SET @ITEMS = 10;
SELECT POST_ID, POST_SITE_ID, POST_SITE_NAME, POST_CREATOR_ID, POST_CREATOR_NAME, POST_SUBJECTS, POST_CONTENTS, POST_CATEGORY_ID, POST_CATEGORY_NAME, POST_VISITORS, POST_CREATED_AT, POST_UPDATED_AT FROM V_POSTS WHERE POST_SITE_ID = @SITE_ID AND POST_CATEGORY_ID = @CATEGORY ORDER BY POST_UPDATED_AT DESC LIMIT 0, 10;   
*/

/*
CALL sp_req_status();
*/

/*
SELECT 
		DISP_ID, 
		USER_TYPE, 
		USER_TYPE_NM_EN, 
		USER_TYPE_NM_KO, 
		ACTIVE, 
		DISP_ID, 
		DISP_NM_KO, 
		DISP_NM_EN
FROM V_STATUS 
WHERE 
	USER_TYPE = 2
GROUP BY DISP_ID;
*/
/*
SET @SITE_ID = 11;
SET @CATEGORY = 1;
SET @OFFSETS = 0;
SET @ITEMS = 10;
SELECT 
		POST_ID, 
        POST_SITE_ID, 
        POST_SITE_NAME, 
        POST_CREATOR_ID, 
        POST_CREATOR_NAME, 
        POST_SUBJECTS, 
        POST_CONTENTS, 
        POST_CATEGORY_ID, 
        POST_CATEGORY_NAME, 
        POST_VISITORS, 
        POST_CREATED_AT, 
        POST_UPDATED_AT 
	FROM V_POSTS 
    WHERE 
		POST_PID 			= 0 AND 
        POST_SITE_ID 		= @SITE_ID AND 
        POST_CATEGORY_ID 	= @CATEGORY 
	ORDER BY POST_UPDATED_AT DESC LIMIT 0, 10;   
*/

/*
SET @SITE_ID = 11;
SET @CATEGORY = 4;
SET @PAGE_NO = 1;
SET @OFFSETS = 0;
SET @ITEMS = 10;
CALL sp_req_get_posts(
	@SITE_ID,
	@CATEGORY,
	@PAGE_NO,
	@OFFSETS,
	@ITEMS
);
*/
/*
CALL sp_req_site_details(11);
*/
/*
SELECT @review_list = REPLACE('0C', CHAR(67 using utf8mb4), '');
*/
/*
SELECT CHAR(92 using utf8mb4); 
*/

/*
SET @SITE_ID = 11;
SET @CATEGORY = 4;
SET @PAGES = 1;
SET @ITEMS = 10;
    CALL sp_req_get_posts_without_handler(
		@SITE_ID,
		@CATEGORY,
		(@PAGES - 1) * @ITEMS,
		@ITEMS,
		@rtn_val,
		@msg_txt,
		@json_data
    );
SELECT @rtn_val,
		@msg_txt,
		@json_data;
*/
/*
SELECT * FROM V_SITE_WSTE_DISPOSAL_ORDER_WITH_STATE WHERE DISPOSER_ORDER_ID <= 10
*/


/*
CALL sp_retrieve_current_state(58)
*/


/*
SET @USER_REG_ID = 'com_emit009';
SET @USER_PWD = '1234';
CALL sp_req_user_login(@USER_REG_ID, @USER_PWD);
CALL sp_req_user_regid_by_user_id(@USER_REG_ID, @USER_ID);
CALL sp_req_switch_user_current_type(@USER_ID);


SET @USER_ID = @USER_ID;
SET @COLLECTOR_SITE_ID = 69;
SET @KIKCD_B_CODE = '4181000000';
SET @ADDR = '마을면 계록리 100';
SET @VISIT_START_AT = '2022-02-25 00:00:00';
SET @VISIT_END_AT = '2022-02-28 00:00:00';
SET @BIDDING_END_AT = '2022-03-03 00:00:00';
SET @OPEN_AT = '2022-02-28 00:00:00';
SET @CLOSE_AT = '2022-04-11 00:00:00';
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPERANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPERANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new";

CALL sp_create_site_wste_discharge_order(
	@DISPOSER_ID,
	@COLLECTOR_ID,
	@KIKCD_B_CODE,
	@ADDR,
	@VISIT_START_AT,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE
)
*/
/*
SET @IN_USER_ID = 'USER_0002_REG_ID';
SET @IN_PWD = 'USER_0002_PWD';
SET @IN_USER_NAME = 'USER_0002_NAME';
SET @IN_PHONE = 'USER_0002_PHONE';
SET @IN_COMP_NAME = 'USER_0002_COMP_NAME';
SET @IN_REP_NAME = 'USER_0002_REP_NAME';
SET @IN_KIKCD_B_CODE = '4182000000';
SET @IN_ADDR = 'USER_0002_ADDR';
SET @IN_LNG = 12;
SET @IN_LAT = 12;
SET @IN_CONTACT = 'USER_0002_CONTACT';
SET @IN_TRMT_BIZ_CODE = 9;
SET @IN_BIZ_REG_CODE = '223321123321';
SET @IN_SOCIAL_NO = '2234567654321';
SET @IN_AGREE_TERMS = 1;
call sp_create_company(
	@IN_USER_ID,
	@IN_PWD,
	@IN_USER_NAME,
	@IN_PHONE,
	@IN_COMP_NAME,
	@IN_REP_NAME,
	@IN_KIKCD_B_CODE,
	@IN_ADDR,
	@IN_LNG,
	@IN_LAT,
	@IN_CONTACT,
	@IN_TRMT_BIZ_CODE,
	@IN_BIZ_REG_CODE,
	@IN_SOCIAL_NO,
	@IN_AGREE_TERMS
);
*/
/*
SET @USER_ID = 94;
SET @DISPOAER_ORDER_ID = 119;
SET @VISIT_AT = '2022-02-25';
SET @POLICY = 'minimum_visit_required';


CALL sp_ask_visit_on_disposal_site(
	@USER_ID,
    @DISPOAER_ORDER_ID,
    @VISIT_AT
);
*/
/*
SELECT direction INTO @RESULT FROM sys_policy WHERE policy = 'minimum_visit_required';
CALL sp_req_policy_direction(@POLICY, @direction);
	SET @aaa = CONCAT(@direction, ':00:00');
	SET @bbb = ADDTIME(@CURRENT_DT, @aaa);
    
CALL sp_req_collector_can_ask_visit(
	@DISPOAER_ORDER_ID,
    @VISIT_AT
);
SELECT @POLICY, @RESULT, @var_active, @direction, @aaa, @bbb, @VISIT_AT, @CURRENT_DT;
*/
/*
SELECT direction FROM sys_policy WHERE policy = 'max_img_size';
*/
/*
CALL sp_req_policy_direction_by_id(14, @direction);
SELECT @POLICY_EXISTS, @direction;
*/
/*
SELECT COUNT(id) INTO @OUT_RESULT FROM sys_policy WHERE id = 14;
select @OUT_RESULT;
*/
/*
SET @IN_USER_ID = 106;
SET @IN_SITE_ID = 74;
SET @IN_WSTE_LIST = '[{"WAST_CLASS": 1}]';
SET @IN_TRMT_BIZ_CODE = '1';
SET @IN_PERMIT_REG_CODE = '12345';
SET @In_PERMIT_REG_IMG_PATH = '12345';

CALL sp_update_site_permit_info(
	@IN_USER_ID,
	@IN_SITE_ID,
	@IN_WSTE_LIST,
	@IN_TRMT_BIZ_CODE,
	@IN_PERMIT_REG_CODE,
	@In_PERMIT_REG_IMG_PATH
);
*/
/*
SET @USER_ID = 91;
SET @COLLECTOR_SITE_ID = 69;
SET @KIKCD_B_CODE = '4181000000';
SET @ADDR = '마을면 계록리 100';
SET @VISIT_START_AT = '2022-02-25 00:00:00';
SET @VISIT_END_AT = '2022-02-28 00:00:00';
SET @BIDDING_END_AT = '2022-03-03 00:00:00';
SET @OPEN_AT = '2022-02-28 00:00:00';
SET @CLOSE_AT = '2022-04-11 00:00:00';
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPEARANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPEARANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new";

CALL sp_create_site_wste_discharge_order(
	@USER_ID,
	@COLLECTOR_SITE_ID,
	@KIKCD_B_CODE,
	@ADDR,
	@VISIT_START_AT,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE
)
*/

/*
CALL sp_retrieve_my_disposal_lists(91);
*/



/*
SET @USER_ID = 101;
SET @DISPOAER_ORDER_ID = 149;
SET @VISIT_AT = '2022-02-28 00:00:00';

CALL sp_req_current_time(@CURRENT_DT);

CALL sp_req_policy_direction('minimum_visit_required', @minimum_required_time);

SET @time_plue = CONCAT(@minimum_required_time, ':00:00');
SET @time_new = ADDTIME(@CURRENT_DT, @time_plue);

SELECT VISIT_END_AT INTO @VISIT_END_AT FROM SITE_WSTE_DISPOSAL_ORDER WHERE ID = @DISPOAER_ORDER_ID;

SELECT @DISPOAER_ORDER_ID, @CURRENT_DT, @minimum_required_time, @time_plue, @time_new, @VISIT_END_AT;
*/



/*
SET @USER_ID = 101;
SET @DISPOAER_ORDER_ID = 149;
SET @VISIT_AT = '2022-02-22 00:00:00';

CALL sp_req_collector_can_ask_visit(
	@DISPOAER_ORDER_ID,
	@COLLECTOR_CAN_ASK_VISIT
);
SELECT @COLLECTOR_CAN_ASK_VISIT;
*/

/*
CALL sp_ask_visit_on_disposal_site(
	@USER_ID,
    @DISPOAER_ORDER_ID,
    @VISIT_AT
);
*/


/*
SET @USER_ID=106;
SET @CATEGORY=101;
CALL sp_retrieve_my_disposal_lists_by_option(@USER_ID, @CATEGORY);
*/





/*
SET @USER_ID = 108;
SET @COLLECTOR_BIDDING_ID = 16;
call sp_cancel_visiting(
	@USER_ID, 
    @COLLECTOR_BIDDING_ID
);
*/


/*

SET @USER_ID = 106;
SET @COLLECTOR_BIDDING_ID = 26;
SET @RES = 1;
CALL sp_disposer_response_visit(
	@USER_ID,
    @COLLECTOR_BIDDING_ID,
    @RES
);
*/

/*
CALL sp_req_status()
*/

/*
SET @USER_ID = 91;
SET @WSTE_CODE = '1';
SET @KIKCD_B_CODE = '4182000000';
CALL sp_req_prev_transaction_site_lists(
	@USER_ID,
    @WSTE_CODE,
    @KIKCD_B_CODE
);
*/


/*
CALL sp_retrieve_my_disposal_lists(112);
*/



/*
SET @USER_ID = 101;
SET @DISPOAER_ORDER_ID = 163;
SET @VISIT_AT = '2022-03-02 22:22:22';


CALL sp_ask_visit_on_disposal_site(
	@USER_ID,
    @DISPOAER_ORDER_ID,
    @VISIT_AT
);
*/


/*
CALL sp_req_collector_can_ask_visit(
	@DISPOAER_ORDER_ID,
	@COLLECTOR_CAN_ASK_VISIT
);
SELECT @COLLECTOR_CAN_ASK_VISIT;
*/


/*
CALL sp_retrieve_my_disposal_lists_by_option(106, 102)
*/


/*
SET @USER_ID = 110;
SET @COLLECTOR_BIDDING_ID = 32;
SET @RES = 1;
CALL sp_disposer_response_visit(
	@USER_ID,
    @COLLECTOR_BIDDING_ID,
    @RES
);
*/
/*
CALL sp_retrieve_my_disposal_lists(96);
*/
/*
SET @USER_ID = 16;
SELECT 
		COLLECTOR_ID, 
        COLLECTOR_SITE_NAME, 
        DISPOSER_CLOSE_AT
    FROM V_SITE_WSTE_DISPOSAL_ORDER_WITH_STATE
	WHERE 
		DISPOSER_SITE_ID IN (
			SELECT AFFILIATED_SITE 
            FROM USERS 
            WHERE 
				ID = @USER_ID AND 
                ACTIVE = TRUE
		) AND
        DISPOSER_CLOSE_AT <= NOW();    

CALL sp_retrieve_past_transactions(
	@USER_ID
);
*/        
    

/*
SELECT AFFILIATED_SITE INTO @AFFILIATED_SITE
            FROM USERS 
            WHERE 
				ID = @USER_ID AND 
                ACTIVE = TRUE;
SELECT @USER_ID, @AFFILIATED_SITE ;

SELECT 
		COLLECTOR_ID, 
        COLLECTOR_SITE_NAME, 
        DISPOSER_CLOSE_AT
    FROM V_SITE_WSTE_DISPOSAL_ORDER_WITH_STATE
	WHERE 
		DISPOSER_SITE_ID = @AFFILIATED_SITE
		 AND
        DISPOSER_CLOSE_AT <= NOW();
*/

/*
call sp_req_close_bidding_early(106, 149)
*/


/*
CALL sp_retrieve_my_disposal_lists(77)
*/

/*
SET @USER_ID=77;
SET @CATEGORY=101;
CALL sp_retrieve_my_disposal_lists_by_option(@USER_ID, @CATEGORY);
*/

/*
CALL sp_req_current_time(@REG_DT);
CALL sp_req_policy_direction(
	'bidding_end_date_after_the_visit_early_closing',
	@policy_direction
);
SET @PERIOD_UNTIL_BIDDING_END_DATE = CAST(@policy_direction AS UNSIGNED);
select ADDTIME(@REG_DT, CONCAT(@PERIOD_UNTIL_BIDDING_END_DATE, ':00')) into @new_time;

select @REG_DT, @policy_direction, @PERIOD_UNTIL_BIDDING_END_DATE, @new_time
*/
/*
call sp_req_close_visit_early (
	110, 162
);
*/

/*
set @IN_USER_ID = 80;
set @IN_COLLECT_BIDDING_ID = 51;


CALL sp_req_disposal_id_of_collector_bidding_id(
	@IN_COLLECT_BIDDING_ID,
	@DISPOSAL_ORDER_ID
);
CALL sp_req_site_id_of_user_reg_id(
	@IN_USER_ID,
	@USER_SITE_ID,
	@rtn_val,
	@msg_txt
);
CALL sp_req_site_already_bid(
	@USER_SITE_ID,
	@DISPOSAL_ORDER_ID,
	@rtn_val,
	@msg_txt
);

SELECT COUNT(ID) 
    INTO @CHK_COUNT 
    FROM COLLECTOR_BIDDING 
    WHERE 
		COLLECTOR_ID = @USER_SITE_ID AND 
        DISPOSAL_ORDER_ID = @DISPOSAL_ORDER_ID AND 
        DATE_OF_BIDDING IS NOT NULL;

select @IN_USER_ID, @IN_COLLECT_BIDDING_ID, @DISPOSAL_ORDER_ID, @USER_SITE_ID, @rtn_val, @msg_txt, @CHK_COUNT;
*/

/*
call sp_retrieve_my_disposal_lists (112);
*/
/*
call sp_ask_visit_on_disposal_site (115, 179, '2022-03-05');
*/
/*
call sp_retrieve_my_disposal_lists (118);
*/
/*
update COLLECTOR_BIDDING set RESPONSE_VISIT = NULL WHERE RESPONSE_VISIT = 0;
*/
/*
CALL sp_cancel_bidding (116, 52);
*/

/*
SET @USER_ID = 100;
SET @SITE_ID = 152;
SET @DISPOSAL_ID = 46;
SET @BIDDING_DETAILS = '[{"WSTE_CODE":"51", "UNIT":"Kg", "UNIT_PRICE": 7, "VOLUME": "1", "TRMT_CODE": "1"}, {"WSTE_CODE":"51-01", "UNIT":"Kg", "UNIT_PRICE": 45, "VOLUME": "1", "TRMT_CODE": "2"}]';
SET @TRMT_METHOD = '1001';
SET @BID_AMOUNT= 25580;
call sp_apply_bidding(
    @USER_ID,
    @DISPOSAL_ID,
    @BID_AMOUNT,
    @TRMT_METHOD,
    @BIDDING_DETAILS
);*/

/*
SELECT A.BIDDING_END_AT, B.policy
FROM SITE_WSTE_DISPOSAL_ORDER A, sys_policy B
WHERE B.policy = 'max_decision_duration';
*/


/*
SET @USER_ID = 100;
SET @DISPOAER_ORDER_ID = 170;
SET @VISIT_AT = '2022-03-01';
*/
/*
CALL sp_req_collector_can_ask_visit(
	@DISPOAER_ORDER_ID,
	@COLLECTOR_CAN_ASK_VISIT
);
SELECT @COLLECTOR_CAN_ASK_VISIT;
*/
/*
CALL sp_ask_visit_on_disposal_site(
	@USER_ID,
    @DISPOAER_ORDER_ID,
    @VISIT_AT
);
*/




/*
SET @USER_ID = 91;
SET @COLLECTOR_SITE_ID = 69;
SET @KIKCD_B_CODE = '4182000000';
SET @ADDR = '마을면 계록리 1000';
SET @VISIT_START_AT = NULL;
SET @VISIT_END_AT = NULL;
SET @BIDDING_END_AT = NULL;
SET @OPEN_AT = NULL;
SET @CLOSE_AT = NULL;
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPEARANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPEARANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new999";

CALL sp_create_site_wste_discharge_order(
	@USER_ID,
	@COLLECTOR_SITE_ID,
	@KIKCD_B_CODE,
	@ADDR,
	@VISIT_START_AT,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE
)
*/
/*
CALL sp_cancel_bidding (116, 52);
*/
/*
SET @IN_USER_ID = 'USER_3333_REG_ID';
SET @IN_PWD = 'USER_3333_PWD';
SET @IN_USER_NAME = 'USER_3333_NAME';
SET @IN_PHONE = 'USER_3333_PHONE';
SET @IN_COMP_NAME = 'USER_2222_COMP_NAME';
SET @IN_REP_NAME = 'USER_2222_REP_NAME';
SET @IN_KIKCD_B_CODE = '4182000000';
SET @IN_ADDR = 'USER_2222_ADDR';
SET @IN_LNG = 12;
SET @IN_LAT = 12;
SET @IN_CONTACT = 'USER_2222_CONTACT';
SET @IN_TRMT_BIZ_CODE = 1;
SET @IN_BIZ_REG_CODE = '993321123333';
SET @IN_SOCIAL_NO = '2234567653333';
SET @IN_AGREE_TERMS = 1;
*/

/*
CALL sp_member_admin_account_exists(
	@IN_USER_ID, 
	@rtn_val, 
	@msg_txt
);
SELECT @rtn_val, 
	@msg_txt
*/
/*    
CALL sp_req_user_exists(
	@IN_USER_ID, 
	TRUE, 
	@rtn_val, 
	@msg_txt
);
		*/
/*
call sp_create_company(
	@IN_USER_ID,
	@IN_PWD,
	@IN_USER_NAME,
	@IN_PHONE,
	@IN_COMP_NAME,
	@IN_REP_NAME,
	@IN_KIKCD_B_CODE,
	@IN_ADDR,
	@IN_LNG,
	@IN_LAT,
	@IN_CONTACT,
	@IN_TRMT_BIZ_CODE,
	@IN_BIZ_REG_CODE,
	@IN_SOCIAL_NO,
	@IN_AGREE_TERMS
);
*/

/*
SET @IN_USER_ID = 'com_col_31';
SET @IN_PWD = '1234';
SET @IN_USER_NAME = '수집자';
SET @IN_PHONE = '030-0000-3013';
SET @IN_COMP_NAME = '1';
SET @IN_REP_NAME = '1';
SET @IN_KIKCD_B_CODE = '4181000000';
SET @IN_ADDR = '마을면 계록리 100';
SET @IN_LNG = 1.1;
SET @IN_LAT = 1.1;
SET @IN_CONTACT = '1';
SET @IN_TRMT_BIZ_CODE = '1';
SET @IN_BIZ_REG_CODE = '12030107';
SET @IN_SOCIAL_NO = '0';
SET @IN_AGREE_TERMS = 0;
call sp_create_company(
	@IN_USER_ID,
	@IN_PWD,
	@IN_USER_NAME,
	@IN_PHONE,
	@IN_COMP_NAME,
	@IN_REP_NAME,
	@IN_KIKCD_B_CODE,
	@IN_ADDR,
	@IN_LNG,
	@IN_LAT,
	@IN_CONTACT,
	@IN_TRMT_BIZ_CODE,
	@IN_BIZ_REG_CODE,
	@IN_SOCIAL_NO,
	@IN_AGREE_TERMS
);
*/
/*
CALL sp_req_user_max_id(@USER_MAX_ID);
SELECT @USER_MAX_ID;
*/


/*
SET @USER_ID = 108;
SET @SITE_ID = 152;
SET @DISPOSAL_ID = 46;
SET @BIDDING_DETAILS = '[{"WSTE_CODE":"51", "UNIT":"Kg", "UNIT_PRICE": 7, "VOLUME": "1", "TRMT_CODE": "1"}, {"WSTE_CODE":"51-01", "UNIT":"Kg", "UNIT_PRICE": 45, "VOLUME": "1", "TRMT_CODE": "2"}]';
SET @TRMT_METHOD = '1001';
SET @BID_AMOUNT= 25580;
call sp_apply_bidding(
    @USER_ID,
    @DISPOSAL_ID,
    @BID_AMOUNT,
    @TRMT_METHOD,
    @BIDDING_DETAILS
);
*/



/*
SET @IN_USER_ID = 106;
SET @IN_SITE_ID = 74;
SET @IN_WSTE_LIST = '[{"WAST_CLASS": 1}]';
SET @IN_TRMT_BIZ_CODE = '1';
SET @IN_PERMIT_REG_CODE = '12343';
SET @In_PERMIT_REG_IMG_PATH = '12345';

CALL sp_update_site_permit_info(
	@IN_USER_ID,
	@IN_SITE_ID,
	@IN_WSTE_LIST,
	@IN_TRMT_BIZ_CODE,
	@IN_PERMIT_REG_CODE,
	@In_PERMIT_REG_IMG_PATH
);
*/




/*
CALL sp_retrieve_my_disposal_lists(119);
*/
/*
SET @USER_ID=119;
SET @COLLECTOR_BIDDING_ID=73;
SET @DISPOSER_ORDER_ID=194;
CALL sp_req_select_collector (
	@USER_ID,
    @COLLECTOR_BIDDING_ID,
    @DISPOSER_ORDER_ID
);
*/

/*
SET @SITE_ID = 105;
SET @DISPOSER_ORDER_ID = 199;
SELECT * FROM COLLECTOR_BIDDING
WHERE 
	COLLECTOR_ID = @SITE_ID AND 
	DISPOSAL_ORDER_ID = @DISPOSER_ORDER_ID;
*/
/*
SELECT COUNT(ID) 
INTO @APPLY_FOR_VISIT 
FROM COLLECTOR_BIDDING 
WHERE 
	COLLECTOR_ID = @SITE_ID AND 
	DISPOSAL_ORDER_ID = @DISPOSER_ORDER_ID AND
	DATE_OF_VISIT IS NOT NULL AND
	ACTIVE = TRUE;
SELECT @APPLY_FOR_VISIT;
*/


/*
SET @USER_ID = 91;
SET @COLLECTOR_SITE_ID = 69;
SET @KIKCD_B_CODE = '4182000000';
SET @ADDR = '마을면 계록리 1000';
SET @VISIT_START_AT = NULL;
SET @VISIT_END_AT = NULL;
SET @BIDDING_END_AT = '2022-03-05';
SET @OPEN_AT = NULL;
SET @CLOSE_AT = NULL;
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPEARANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPEARANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new999";

CALL sp_create_site_wste_discharge_order(
	@USER_ID,
	@COLLECTOR_SITE_ID,
	@KIKCD_B_CODE,
	@ADDR,
	@VISIT_START_AT,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE
);
*/


/*
SET @USER_ID = 128;
SET @SITE_ID = 152;
SET @DISPOSAL_ID = 196;
SET @BIDDING_DETAILS = '[{"WSTE_CODE":"51", "UNIT":"Kg", "UNIT_PRICE": 7, "VOLUME": "1", "TRMT_CODE": "1"}, {"WSTE_CODE":"51-01", "UNIT":"Kg", "UNIT_PRICE": 45, "VOLUME": "1", "TRMT_CODE": "2"}]';
SET @TRMT_METHOD = '1001';
SET @BID_AMOUNT= 25580;
call sp_apply_bidding(
    @USER_ID,
    @DISPOSAL_ID,
    @BID_AMOUNT,
    @TRMT_METHOD,
    @BIDDING_DETAILS
);
*/



/*
SET @USER_ID = 122;
SET @COLLECTOR_BIDDING_ID = 77;
SET @DISPOSER_ORDER_ID = 198;
SET @VISIT_AT = '2022-03-05';
SET @RES = 0;
*/
/*
CALL sp_disposer_response_visit(
	@USER_ID,
    @COLLECTOR_BIDDING_ID,
    @RES
);
*/
/*
call sp_cancel_visiting(
	@USER_ID,
    @COLLECTOR_BIDDING_ID
);
*/
/*
SELECT COUNT(ID) INTO @ITEM_COUNT FROM COLLECTOR_BIDDING WHERE ID = @COLLECTOR_BIDDING_ID;
SELECT @ITEM_COUNT ;
*/

/*
call sp_ask_visit_on_disposal_site(
	@USER_ID,
    @DISPOSER_ORDER_ID,
    @VISIT_AT
);
*/

/*
call sp_retrieve_my_disposal_lists (119);
*/


/*
SET @USER_ID = 1200;
SET @COMP_ID = 10;
SELECT NULLIF(BELONG_TO, NULL) INTO @CREATOR_BELONG_TO FROM USERS WHERE ID = @USER_ID AND CLASS = 201;
SELECT @CREATOR_BELONG_TO;
*/

/*
call sp_check_if_class_exists(103, @rtn_val, @msg_txt);
SELECT @rtn_val, @msg_txt;
*/

/*
SET @TARGET_CLASS = 201;
SET @TARGET_SITE_ID = 100;
SET @CREATOR_CLASS = 101;
SET @CREATOR_SITE_ID = 0;
CALL sp_check_auth_to_create_user(
	@TARGET_CLASS,
    @TARGET_SITE_ID,
    @CREATOR_CLASS,
    @CREATOR_SITE_ID,
    @rtn_val,
    @msg_txt
);
SELECT @rtn_val, @msg_txt;
*/

/*
SET @CREATOR_ID = 128;
SET @USER_ID = '111212111';
SET @PWD = '111';
SET @USER_NAME = '111_NAME';
SET @PHONE = '2121_PHONE11';
SET @CLASS = 202;
SET @SITE_ID = 105;
SET @DEPARTMENT = NULL;
SET @SOCIAL_NO = '1232123';
SET @AGREE_TERMS = 1;

CALL sp_create_user(
	@CREATOR_ID,
	@USER_ID,
	@PWD,
	@USER_NAME,
	@PHONE,
	@CLASS,
	@SITE_ID,
	@DEPARTMENT,
	@SOCIAL_NO,
	@AGREE_TERMS
);
*/

/*
SET @USER_MAX_ID = 131;
SET @SITE_ID = 105;
SET @CLASS = 202;
SET @USER_TYPE = 'company';
CALL sp_cs_confirm_account(
	@USER_MAX_ID,
	@SITE_ID,
	@CLASS,
	@USER_TYPE,
	@rtn_val,
	@msg_txt
);
SELECT @rtn_val, @msg_txt;
*/


/*
SET @IN_USER_ID = 'com_col_3122';
SET @IN_PWD = '123412';
SET @IN_USER_NAME = '수집자12';
SET @IN_PHONE = '030-0000-3012';
SET @IN_COMP_NAME = '1';
SET @IN_REP_NAME = '1';
SET @IN_KIKCD_B_CODE = '4181000000';
SET @IN_ADDR = '마을면 계록리 100';
SET @IN_LNG = 1.1;
SET @IN_LAT = 1.1;
SET @IN_CONTACT = '1';
SET @IN_TRMT_BIZ_CODE = '1';
SET @IN_BIZ_REG_CODE = '12033456';
SET @IN_SOCIAL_NO = '0';
SET @IN_AGREE_TERMS = 0;
call sp_create_company(
	@IN_USER_ID,
	@IN_PWD,
	@IN_USER_NAME,
	@IN_PHONE,
	@IN_COMP_NAME,
	@IN_REP_NAME,
	@IN_KIKCD_B_CODE,
	@IN_ADDR,
	@IN_LNG,
	@IN_LAT,
	@IN_CONTACT,
	@IN_TRMT_BIZ_CODE,
	@IN_BIZ_REG_CODE,
	@IN_SOCIAL_NO,
	@IN_AGREE_TERMS
);
*/

/*
CALL sp_create_cert_code('010-9169-2399');
*/

/*
SET @ID = 3;
SET @PHONE_NO = '010-9169-2399';
SET @CERT_CODE = 425007;
CALL sp_check_cert_code(
	@ID,
    @PHONE_NO,
    @CERT_CODE
);
*/

/*
CALL sp_req_policy_direction(
	'max_verification_time_out', 
	@max_verification_time_out
);
SELECT CERT_CODE, CREATED_AT 
INTO @CERT_CODE, @CREATED_AT
FROM CELL_PHONE_CERTIFICATION 
WHERE ID = 3;
SELECT @CREATED_AT, ADDTIME(@CREATED_AT, CONCAT('0:', @max_verification_time_out, ':00'));
*/

/*
CALL sp_req_is_biz_reg_code_duplicate('022801');

call sp_req_user_login('tester0308', '1234')
*/
/*
CALL sp_req_user_detail(98)
*/

/*
CALL sp_req_site_detail(78,49);
*/

/*
CALL sp_req_business_area(50);
*/

/*
SET @USER_ID = 39;
SET @SITE_ID = 11;
SET @CATEGORY = 4;
*/
/*
SELECT POST_ID, POST_SITE_ID, POST_SITE_NAME, POST_CREATOR_ID, POST_CREATOR_NAME, POST_SUBJECTS, POST_CONTENTS, POST_CATEGORY_ID, POST_CATEGORY_NAME, POST_VISITORS, POST_CREATED_AT, POST_UPDATED_AT FROM V_POSTS WHERE POST_SITE_ID = @SITE_ID AND POST_CATEGORY_ID = @CATEGORY ORDER BY POST_UPDATED_AT DESC LIMIT @IN_OFFSET, @IN_ITEMS;  
*/
/*
CALL sp_req_get_posts(
	@USER_ID,
	@SITE_ID,
	@CATEGORY
);
*/
/*
CALL sp_req_get_posts_without_handler(
	@USER_ID,
	@SITE_ID,
	@CATEGORY,
	@IN_OFFSET,
	@IN_ITEMS,
    @rtn_val,
    @msg_txt,
    @json_data
);

select @USER_ID,
	@SITE_ID,
	@CATEGORY,
	@IN_OFFSET,
	@IN_ITEMS,
    @rtn_val,
    @msg_txt,
    @json_data
*/

/*
    SELECT 
		POST_ID, 
        POST_SITE_ID, 
        POST_SITE_NAME, 
        POST_CREATOR_ID, 
        POST_CREATOR_NAME, 
        POST_SUBJECTS, 
        POST_CONTENTS, 
        POST_CATEGORY_ID, 
        POST_CATEGORY_NAME, 
        POST_VISITORS, 
        POST_CREATED_AT, 
        POST_UPDATED_AT 
	FROM V_POSTS 
    WHERE 
		POST_PID 			= 0 AND 
        POST_SITE_ID 		= @SITE_ID AND 
        POST_CATEGORY_ID 	= @CATEGORY 
*/       

/*
CALL sp_req_site_details(11); 
*/

/*
SET @USER_ID = 39;
SET @POST_ID = 1;
SET @SUBJECTS = 'UPDATED SUBJECTS';
SET @CONTENTS = 'UPDATED CONTENTS';
CALL sp_update_post(
	@USER_ID,
    @POST_ID,
    @SUBJECTS,
    @CONTENTS
);
*/

/*
CALL sp_req_business_area(50);
*/

/*
SET @ASKER_ID = 4;
SET @TARGET_ID = 4;

CALL sp_delete_user(
	@ASKER_ID,
    @TARGET_ID
);
*/

/*
SET @USER_ID = 10;
SET @AVATAR_PATH = '12345';
call sp_update_avatar(
	@USER_ID,
    @AVATAR_PATH
);
*/

/*
SET @USER_ID = 0;
SET @SUBJECTS = NULL;
SET @CONTENTS = '해결되었습니다';
SET @SITE_ID = 111;
SET @CATEGORY = 3;
SET @SUB_CATEGORY = 1;
SET @PID = 5;
SET @RATING = NULL;
CALL sp_write_post(
	@USER_ID,
	@SUBJECTS,
	@CONTENTS,
	@SITE_ID,
	@CATEGORY,
	@SUB_CATEGORY,
	@PID,
	@RATING
);
*/
/*
SET @USER_ID = 10;
SET @SITE_ID = 111;
SET @CATEGORY = 3;
CALL sp_req_get_posts(
	@USER_ID,
	@SITE_ID,
	@CATEGORY
);
*//*
CALL sp_update_push(100, 1);
*/


/*
SET @USER_ID = 16;
SET @CONTENTS = 'HELLO_REVIEW_4_10';
SET @SITE_ID = 7;
SET @PID = 0;
SET @RATING = 3.5;
SET @DISPOSER_ORDER_ID = 10;

CALL sp_write_review(
	@USER_ID,
	@CONTENTS,
	@SITE_ID,
	@PID,
	@RATING,
	@DISPOSER_ORDER_ID
);
*/


/*
SET @USER_ID = 6;
SET @CONTENTS = 'HELLO_REVIEW';
SET @PID = 0;
SET @SUB_CATEGORY = 3;
CALL sp_write_question(
	@USER_ID,
	@CONTENTS,
	@PID,
	@SUB_CATEGORY
);
*/

/*
SET @USER_ID = 11;
CALL sp_req_get_my_reviews(
	@USER_ID
);
*/

/*
CALL sp_toggle_push(119, 0);
*/
/*
SET @USER_ID = 10;
SET @USER_NAME = 'HELLO';
CALL sp_update_user_name(
	@USER_ID,
    @USER_NAME
);
*/

/*
SET @USER_ID = 6;
SET @SITE_ID = 7;
SET @CATEGORY = 4;
CALL sp_req_get_posts(
	@USER_ID,
	@SITE_ID,
	@CATEGORY    
);
*/
/*
SET @USER_ID = 39;
SET @POST_ID = 1;
CALL sp_delete_post(
	@USER_ID,
    @POST_ID
);
*/



/*
SET @USER_ID = 101;
SET @DISPOSER_ORDER_ID = 149;
SET @VISIT_AT = '2022-03-20';
call sp_ask_visit_on_disposal_site(
	@USER_ID,
    @DISPOSER_ORDER_ID,
    @VISIT_AT
);
*/

/*
SET @AAA = '2022-03-20 15:00:00';
SET @BBB = '2022-03-20';
SELECT TIME(@BBB) INTO @CCC;
SELECT IF(TIME(@BBB) < '06:00:00', TRUE, FALSE) INTO @DDD;
SELECT @AAA, @BBB, @CCC, @DDD;
*/
/*
SELECT IF(DATE(@AAA) = DATE(@BBB), TRUE, FALSE) INTO @DDD;
select TIME(@BBB) INTO @BBB_TIME;
select IF(LEFT(TIME(@BBB), 8)='00:00:00', TRUE, FALSE) INTO @NEW_BBB_B;
select IF(TIME(@BBB)='00:00:00.000000', CONCAT(DATE(@BBB), LEFT(TIME(@AAA), 8)), @BBB) INTO @NEW_BBB;
SELECT IF(@NEW_BBB<@AAA, TRUE, FALSE) INTO @CCC;

SELECT @AAA, @BBB, @NEW_BBB, @NEW_BBB_B, @BBB_TIME, @CCC, @DDD
*/
/*
SET @USER_ID = 6;
SET @SITE_ID = 0;

CALL sp_req_get_my_question(
	@USER_ID,
	@SITE_ID
);
*/
/*
SELECT AFFILIATED_SITE INTO @USER_SITE_ID FROM USERS WHERE ID = @USER_ID;
select @USER_SITE_ID;
*/


/*
SET @USER_ID = 6;
SET @CONTENTS = 'HELLO_REVIEW_4_10';
SET @SITE_ID = 7;
SET @PID = 0;
SET @RATING = 3.5;
SET @DISPOSER_ORDER_ID = 10;

CALL sp_write_review(
	@USER_ID,
	@CONTENTS,
	@SITE_ID,
	@PID,
	@RATING,
	@DISPOSER_ORDER_ID
);
*/


/*
SET @USER_ID=119;
call sp_retrieve_my_disposal_lists(
	@USER_ID
);
*/




/*
SET @USER_ID = 122;
SET @COLLECTOR_BIDDING_ID = 77;
SET @DISPOSER_ORDER_ID = 198;
SET @VISIT_AT = '2022-03-05';
SET @RES = 0;
*/
/*
CALL sp_disposer_response_visit(
	@USER_ID,
    @COLLECTOR_BIDDING_ID,
    @RES
);
*/
/*
call sp_cancel_visiting(
	@USER_ID,
    @COLLECTOR_BIDDING_ID
);
*/
/*
SELECT COUNT(ID) INTO @ITEM_COUNT FROM COLLECTOR_BIDDING WHERE ID = @COLLECTOR_BIDDING_ID;
SELECT @ITEM_COUNT ;
*/

/*
call sp_ask_visit_on_disposal_site(
	@USER_ID,
    @DISPOSER_ORDER_ID,
    @VISIT_AT
);
*/

/*
SET @USER_ID = 119;
SET @PUSH = 0;
CALL sp_toggle_push(
	@USER_ID,
    @PUSH
);
*/

/*
SET @USER_ID = 121;
SET @NOTICE = 1;
CALL sp_toggle_notice(
	@USER_ID,
    @NOTICE
);
*/

/*
SET @USER_ID = 119;
SET @SITE_ID = 0;
CALL sp_req_get_my_question(
	
);
*/

/*
SET @USER_ID = 121;
CALL sp_req_user_detail(
	@USER_ID
);
*/

/*
SET @TEMP_A_AT = '2022-03-17';
SELECT LENGTH(@TEMP_A_AT) INTO @TEMP;
SELECT TIME(@TEMP_A_AT) INTO @TEMP_B_AT;
SET @AAA = DATE_ADD(@TEMP_A_AT, INTERVAL 1 DAY);
SELECT @TEMP_A_AT, @TEMP_B_AT, @TEMP, @AAA;
*/

/*
SET @USER_ID = 120;
SET @SITE_ID = 85;
CALL sp_req_get_my_question(
	@USER_ID,
    @SITE_ID
);
*/



/*
SET @USER_ID = 6;
CALL sp_req_get_my_question(
	@USER_ID
);
*/

/*
UPDATE COLLECTOR_BIDDING SET REJECT_BIDDING = FALSE;
*/

/*
SET @DISPOSER_ORDER_ID = 230;
CALL sp_retrieve_sites_that_can_bid(
	@DISPOSER_ORDER_ID,
    @rtn_val,
    @msg_txt,
    @json_data
);
SELECT @rtn_val,
    @msg_txt,
    @json_data;
*/

/*
SELECT 
		COLLECTOR_SITE_ID, 
        COLLECTOR_SITE_NAME, 
        COLLECTOR_BIDDING_ID,
        TRMT_BIZ_NM
    FROM V_COLLECTOR_BIDDING_WITH_STATE
	WHERE 
		DISPOSER_ORDER_ID = @DISPOSER_ORDER_ID AND
        STATUS_PID <> 211;
*/
/*
UPDATE SITE_WSTE_DISPOSAL_ORDER SET VISIT_EARLY_CLOSING = FALSE, VISIT_EARLY_CLOSED_AT = NULL WHERE ID = 230;

SET @USER_ID = 189;
SET @DISPOSER_ORDER_ID = 230;
CALL sp_req_close_visit_early(
	@USER_ID,
    @DISPOSER_ORDER_ID
);
*/
/*
SET @USER_ID = 189;
SET @DISPOSER_SITE_ID = 230;
SET @COLLECTOR_BIDDING_ID = 91;

CALL sp_req_reject_bidding_apply(
	@USER_ID,
    @DISPOSER_SITE_ID,
    @COLLECTOR_BIDDING_ID
);
*/
/*
SELECT COUNT(ID) INTO @USER_DISPOSAL_ORDER_EXISTS FROM SITE_WSTE_DISPOSAL_ORDER WHERE DISPOSER_ID = @USER_ID AND ID = @DISPOSER_SITE_ID;
SELECT @USER_DISPOSAL_ORDER_EXISTS, @USER_ID, @DISPOSER_SITE_ID;
*/

/*
SET @USER_ID = 0;
SET @SUBJECT = '공지사항';
SET @CONTENTS = '치움서비스 런칭';
CALL sp_write_notice(
	@USER_ID,
    @SUBJECT,
    @CONTENTS
);
*/

/*
SET @USER_ID = 167;
SET @COLLECTOR_BIDDING_ID = 91;
CALL sp_cancel_visiting(
	@USER_ID,
    @COLLECTOR_BIDDING_ID
);
*/




/*
SET @USER_ID = 189;
SET @COLLECTOR_BIDDING_ID = 90;
SET @RES = 0;

CALL sp_disposer_response_visit(
	@USER_ID,
    @COLLECTOR_BIDDING_ID,
    @RES
);
*/

/*
SET @USER_ID = 25;
SET @REFRESH_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InBlcl9lbWl0MDEiLCJzdWIiOiIxMjM0IiwiaWF0IjoxNjQ3NTY1OTk4LCJleHAiOjE2NzkxMjM1OTh9.BkqxmCl3LQnvo_PRXA3SB8M9d';
CALL sp_update_refresh_token(
	@USER_ID,
    @REFRESH_TOKEN
);
*/

/*
SET @USER_ID = 190;
SET @DISPOSER_ORDER_ID = 265;
SET @VISIT_AT = '2022-03-19';


call sp_ask_visit_on_disposal_site(
	@USER_ID,
    @DISPOSER_ORDER_ID,
    @VISIT_AT
);
*/
/*
SET @AAA = '2022-03-18';

CALL sp_test2(
	@AAA,
    @OUT_DATE
);
SELECT @AAA, @OUT_DATE;
*/


/*
SET @USER_ID = 11;
CALL sp_req_get_my_reviews(
	@USER_ID
);
*/


/*

SET @USER_ID = 76;
SET @COMP_ID = 56;


CALL sp_delete_company(
	@USER_ID,
    @COMP_ID
);
*/

/*
SET @USER_ID = 76;
SET @COMP_ID = 56;
CALL sp_req_super_permission_by_userid(
	@USER_ID, 
	@COMP_ID, 
	@PERMISSION, 
	@IS_USER_SITE_HEAD_OFFICE, 
    @rtn_val,
    @msg_txt
);
SELECT 
	@USER_ID, 
	@COMP_ID, 
	@PERMISSION, 
	@IS_USER_SITE_HEAD_OFFICE, 
    @rtn_val,
    @msg_txt;
*/

/*
CALL sp_calc_bidding_rank_all(@BIDDERS, @FIRST_, @SECOND_);
SELECT @BIDDERS, @FIRST_, @SECOND_;
*/


/*
UPDATE SITE_WSTE_DISPOSAL_ORDER SET SELECTED = 0 WHERE SELECTED IS NULL;
*/


/*
CALL sp_calc_make_decision_at_all();
*/


/*
INSERT INTO FINAL_BIDDER_MANAGEMENT(
	DISPOSER_ORDER_ID,
    COLLECTOR_BIDDING_ID,
    BIDDING_RANK,
    SELECTED,
    SELECTED_AT,
    MAKE_DECISION,
    MAKE_DECISION_AT,
    MAX_DECISION_AT
    ) SELECT 
    DISPOSAL_ORDER_ID,
    ID,
    BIDDING_RANK,
    SELECTED,
    SELECTED_AT,
    MAKE_DECISION,
    MAKE_DECISION_AT,
    MAX_DECISION_AT
    FROM COLLECTOR_BIDDING
*/

/*
UPDATE FINAL_BIDDER_MANAGEMENT A
LEFT JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSER_ORDER_ID = B.ID
SET A.MAX_SELECT_AT = B.MAX_SELECT_AT;
*/

/*
call sp_calc_max_select_at_all();
*/

/*
CALL sp_req_disposal_order_details(305);
*/



/*
CALL sp_retrieve_current_state(58)
*/



/*
SET @USER_ID=196;
CALL sp_retrieve_my_disposal_lists(@USER_ID);
*/

/*
SET @USER_ID=28;

CALL sp_retrieve_existing_transactions(
	@USER_ID
);
*/
/*
	SELECT 
		DISPOSER_ORDER_ID, 
		DISPOSER_ID, 
		COLLECTOR_ID, 
        COLLECTOR_SITE_NAME, 
        DISPOSER_CLOSE_AT
    FROM V_SITE_WSTE_DISPOSAL_ORDER_WITH_STATE A
	JOIN USERS B
    ON IF(B.AFFILIATED_SITE = 0, A.DISPOSER_ID = B.ID, A.DISPOSER_SITE_ID = B.AFFILIATED_SITE)
	WHERE 
		B.ID = @USER_ID AND
        B.ACTIVE = TRUE AND
        A.DISPOSER_CLOSE_AT > NOW();
*/



/*
SET @USER_ID = 203;
SET @DISPOSER_ORDER_ID = 303;
SET @BIDDING_DETAILS = '[{"WSTE_CODE":"51", "UNIT":"Kg", "UNIT_PRICE": 7, "VOLUME": "1", "TRMT_CODE": "1"}, {"WSTE_CODE":"51-01", "UNIT":"Kg", "UNIT_PRICE": 45, "VOLUME": "1", "TRMT_CODE": "2"}]';
SET @TRMT_METHOD = '1001';
SET @BID_AMOUNT= 25580;
call sp_apply_bidding(
    @USER_ID,
    @DISPOSER_ORDER_ID,
    @BID_AMOUNT,
    @TRMT_METHOD,
    @BIDDING_DETAILS
);
*/


/*
SET @USER_ID=195;

CALL sp_req_prev_transaction_site_lists(
	@USER_ID
);
*/
/*
	SELECT 
		A.DISPOSER_ORDER_ID, 
		A.DISPOSER_ID, 
		A.DISPOSER_SITE_ID, 
		A.COLLECTOR_SITE_ID, 
		A.COLLECTOR_BIDDING_ID, 
        A.DISPOSER_OPEN_AT, 
        A.DISPOSER_CLOSE_AT,
        A.STATE_CODE, 
        A.STATE
    FROM V_COLLECTOR_BIDDING_WITH_STATE A LEFT JOIN USERS B 
    ON IF(B.AFFILIATED_SITE = 0, A.DISPOSER_ID = B.ID, A.DISPOSER_SITE_ID = B.AFFILIATED_SITE)
	WHERE 
		(A.STATE_CODE = 212 OR A.STATE_CODE = 218 OR A.STATE_PID = 212 OR A.STATE_PID = 218) AND 
		A.DISPOSER_SITE_ID IS NOT NULL AND 
        A.DISPOSER_SITE_ID = B.AFFILIATED_SITE AND
        B.ID = @USER_ID AND 
        B.ACTIVE = TRUE AND
        A.COLLECTOR_MAKE_DECISION = TRUE AND
        A.COLLECTOR_SELECTED = TRUE;
*/



/*
SET @USER_ID = 91;
SET @COLLECTOR_SITE_ID = 69;
SET @KIKCD_B_CODE = '4182000000';
SET @ADDR = '마을면 계록리 1000';
SET @LNG = 1.1234;
SET @LAT = 5.6789;
SET @VISIT_START_AT = NULL;
SET @VISIT_END_AT = NULL;
SET @BIDDING_END_AT = '2022-03-05';
SET @OPEN_AT = NULL;
SET @CLOSE_AT = NULL;
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPEARANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPEARANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new999";

CALL sp_create_site_wste_discharge_order(
	@USER_ID,
	@COLLECTOR_SITE_ID,
	@KIKCD_B_CODE,
	@ADDR,
	@LNG,
	@LAT,
	@VISIT_START_AT,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE
);
*/



/*
SET @USER_ID = 91;
SET @COLLECTOR_SITE_ID = 69;
SET @DISPOSER_SITE_ID = 58;
SET @DISPOSER_TYPE = 'company';
SET @KIKCD_B_CODE = '4182000000';
SET @ADDR = '마을면 계록리 1000';
SET @VISIT_START_AT = NULL;
SET @VISIT_END_AT = NULL;
SET @BIDDING_END_AT = '2022-03-05';
SET @OPEN_AT = NULL;
SET @CLOSE_AT = NULL;
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPEARANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPEARANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new999";
SET @LNG = 1.1234;
SET @LAT = 5.6789;
CALL sp_req_current_time(@REG_DT);

CALL sp_insert_site_wste_discharge_order_to_table(
	@USER_ID,
	@COLLECTOR_SITE_ID,
	@DISPOSER_SITE_ID,
	@DISPOSER_TYPE,
	@KIKCD_B_CODE,
	@ADDR,
	@VISIT_START_AT,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE,
	@LNG,
	@LAT,
	@REG_DT,
	@rtn_val,
	@msg_txt
);

SELECT @rtn_val,
	@msg_txt
    
*/

/*
SET @USER_ID = 91;
SET @COLLECTOR_SITE_ID = 69;
SET @DISPOSER_SITE_ID = 58;
SET @DISPOSER_TYPE = 'company';
SET @KIKCD_B_CODE = '4182000000';
SET @ADDR = '마을면 계록리 1000';
SET @VISIT_START_AT = NULL;
SET @VISIT_END_AT = NULL;
SET @BIDDING_END_AT = '2022-03-05';
SET @OPEN_AT = NULL;
SET @CLOSE_AT = NULL;
SET @WSTE_CLASS = '[{"WSTE_CLASS_CODE":"51", "WSTE_APPEARANCE":1, "UNIT": "Kg", "QUANTITY": 111}, {"WSTE_CLASS_CODE":"91", "WSTE_APPEARANCE":2, "UNIT": "Kg", "QUANTITY": 222}]';
SET @PHOTO_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';
SET @NOTE = "note_new999";
SET @LNG = 1.1234;
SET @LAT = 5.6789;
CALL sp_req_current_time(@REG_DT);

CALL sp_insert_site_wste_discharge_order_without_handler(
	@USER_ID,
	@COLLECTOR_SITE_ID,
	@DISPOSER_SITE_ID,
	@DISPOSER_TYPE,
	@KIKCD_B_CODE,
	@ADDR,
	@VISIT_START_AT,
	@VISIT_END_AT,
	@BIDDING_END_AT,
	@OPEN_AT,
	@CLOSE_AT,
	@WSTE_CLASS,
	@PHOTO_LIST,
	@NOTE,
	@LAT,
	@LNG,
	@REG_DT,
	@rtn_val,
	@msg_txt
);

SELECT @rtn_val,
	@msg_txt
*/


/*
SET @USER_ID = 206;
SET @COLLECT_BIDDING_ID = 147;
SET @FINAL_DECISION = 0;
CALL sp_collector_make_final_decision_on_bidding(
	@USER_ID,
	@COLLECT_BIDDING_ID,
	@FINAL_DECISION
);
*/


/*
SET @SIDO = '4200000000';
CALL sp_req_sigungu(
	@SIDO
);
*/

/*
	CALL sp_req_policy_direction(
		'max_selection_duration',
		@max_selection_duration
	);

    CALL sp_req_current_time(@REG_DT);
SET @MAX_SELECT_AT = ADDTIME(@REG_DT, CONCAT(CAST(@max_selection_duration AS UNSIGNED), ':00:00'));
    SET @MAX_SELECT2_AT = ADDTIME(@REG_DT, CONCAT(CAST(@max_selection_duration AS UNSIGNED)*2, ':00:00'));
    
SELECT @REG_DT, @MAX_SELECT_AT, @MAX_SELECT2_AT;
*/


/*
call sp_calc_collector_max_decision_at_all();
*/

/*
SET @USER_ID=202;
CALL sp_retrieve_my_disposal_lists(@USER_ID);
*/

/*
CALL sp_req_disposal_order_details(309);
*/

/*
CALL sp_req_collector_bidding_details(4);
*/


/*
SET @USER_ID = 13;
SET @SITE_ID = 2;
SET @IMG_PATH = '12345';
call sp_upload_license(
	@USER_ID,
    @SITE_ID,
    @IMG_PATH
);
*/
/*
CALL sp_retrieve_existing_transactions(28);
*/


/*
SET @USER_ID = 18;

CALL sp_req_user_detail(
	@USER_ID
);
*/
/*
SET @SITE_ID=7;

CALL sp_req_get_site_reviews_without_handler(
	@SITE_ID,
    @rtn_val,
    @msg_txt,
    @avg_rating,
    @json_data
);
select @SITE_ID,
    @rtn_val,
    @msg_txt,
    @avg_rating,
    @json_data
*/
    
/*    
SELECT 
		POST_ID, 
		POST_CREATOR_ID, 
        POST_RATING, 
        POST_SITE_ID, 
        POST_SITE_NAME, 
        POST_CONTENTS, 
        POST_CREATED_AT, 
        POST_DISPOSER_ORDER_ID
	FROM V_POSTS 
    WHERE 
        POST_SITE_ID 	= @SITE_ID AND 
        POST_CATEGORY_ID 	= 4  AND 
        POST_ACTIVE		 	= TRUE 
*/

/*
CALL sp_req_prev_transaction_details(
188,166
);
*/


/*
CALL sp_cancel_bidding(122, 69);
*/



/*
CALL sp_retrieve_existing_transactions(28);
*/

/*
SELECT JSON_ARRAYAGG(JSON_OBJECT(
			'SITE_ID'					, C.COMP_SITE_ID, 
            'SITE_NAME'					, C.COMP_SITE_NAME, 
            'ADDR'						, C.COMP_SITE_ADDR, 
            'B_CODE'					, C.COMP_SITE_KIKCD_B_CODE, 
            'SI_DO'						, C.COMP_SITE_SI_DO, 
            'SI_GUN_GU'					, C.COMP_SITE_SI_GUN_GU, 
            'EUP_MYEON_DONG'			, C.COMP_SITE_EUP_MYEON_DONG, 
            'DONG_RI'					, C.COMP_SITE_DONG_RI, 
            'AVATAR_PATH'				, B.AVATAR_PATH
		)) 
        INTO @COLLECTOR_INFO
        FROM V_COLLECTOR_BIDDING A 
        LEFT JOIN USERS B ON A.COLLECTOR_SITE_ID = B.AFFILIATED_SITE
        LEFT JOIN V_COMP_SITE C ON A.COLLECTOR_SITE_ID = C.COMP_SITE_ID
        WHERE A.SUCCESS_BIDDER = 176 AND 
        A.COLLECTOR_SITE_ID = A.SUCCESS_BIDDER AND
        B.CLASS = 201;
*/

/*

CALL sp_collector_make_final_decision_on_bidding(204,155,1);
*/

/*
SET @USER_ID = 100;
call sp_check_if_license_exists(100);
*/


/*
SET @USER_ID = 204;
SET @TRANSACTION_ID = 300;
SET @RESPONSE = 1;

call sp_collector_response_to_discharged_end_at(
	@USER_ID,
    @TRANSACTION_ID,
    @RESPONSE
);
*/
/*
CALL sp_req_collector_id_of_transaction(
	@TRANSACTION_ID,
    @OUT_SITE_ID,
    @rtn_val,
    @msg_txt    
);

SELECT 
	@TRANSACTION_ID,
    @OUT_SITE_ID,
    @rtn_val,
    @msg_txt    
*/
/*
CALL sp_req_business_area(50);
*/

/*
CALL sp_calc_clct_trmt_vist_schedule_all();
*/


/*
CALL sp_req_current_time(@REG_DT);

SET @USER_ID = 28;
SET @TRANSACTION_ID = 1;
SET @WSTE_CODE = '01-03-99';
SET @QUANTITY = 3500;
SET @PRICE = 52000000;
SET @TRMT_METHOD = '1001';
SET @IMG_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"img_0001_path", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"img_0002_path", "FILE_SIZE": 4.35}]';

CALL sp_req_collector_ask_transaction_completed(
	@USER_ID,
	@TRANSACTION_ID,
	@WSTE_CODE,
	@QUANTITY,
	@REG_DT,
	@PRICE,
	@TRMT_METHOD,
	@IMG_LIST
);
*/


/*
SET @USER_ID = 192;
SET @COLLECT_BIDDING_ID = 184;
call sp_cancel_bidding(
	@USER_ID,
    @COLLECT_BIDDING_ID
);
*/

/*
UPDATE COLLECTOR_BIDDING SET GIVEUP_BIDDING = FALSE;
*/

/*
SET @USER_ID = 28;
SET @DISPOSER_ORDER_ID = 10;
SET @TRANSACTION_ID = 1;
SET @END_AT = '2022-03-30';
*/
/*
CALL sp_req_site_id_of_transaction_id(
	@TRANSACTION_ID,
	@DISPOSER_SITE_ID,
	@COLLECTOR_SITE_ID
);
SELECT 
	@DISPOSER_SITE_ID,
	@COLLECTOR_SITE_ID;
*/
/*
CALL sp_disposer_change_discharged_end_at(
	@USER_ID,
    @DISPOSER_ORDER_ID,
    @TRANSACTION_ID,
    @END_AT
);
*/


/*
SET @USER_ID = 202;
SET @SITE_ID = 192;
SET @IMG_PATH = 'https://chium02.s3.ap-northeast-2.amazonaws.com//temp/087b5c54-b198-4197-b02a-8ec69ca2b1d4.jpeg';
call sp_upload_license(
	@USER_ID,
    @SITE_ID,
    @IMG_PATH
);
*/
/*
call sp_req_transaction_report(1,1)
*/



/*
SET @USER_ID=119;
SET @COLLECTOR_BIDDING_ID=73;
SET @DISPOSER_ORDER_ID=194;
CALL sp_req_select_collector (
	@USER_ID,
    @COLLECTOR_BIDDING_ID,
    @DISPOSER_ORDER_ID
);
*/


/*
SET @CUR_STATE_CATEGORY_ID = 1;
SET @HELLO = 5;
SELECT 
	CASE
		WHEN @CUR_STATE_CATEGORY_ID = 1
		THEN (SELECT USER_NAME FROM USERS WHERE ID = @HELLO)
		WHEN @CUR_STATE_CATEGORY_ID = 2
		THEN '222'
		WHEN @CUR_STATE_CATEGORY_ID = 3
		THEN '333'
		ELSE '444'
	END INTO @AAA;
SELECT @AAA;
	DROP TABLE IF EXISTS TRANSACTION_REPORT_TEMP;
*/
/*
SET @TRANSACTION_REPORT_ID = 1;

CALL sp_req_transaction_report_without_handler(
	@TRANSACTION_REPORT_ID,
    @rtn_val,
    @msg_txt,
    @json_data
);

SELECT 
    @rtn_val,
    @msg_txt,
    @json_data;
*/    

/*
SET @TRANSACTION_REPORT_ID = 1;
SELECT 
		A.ID, 
        A.TRANSACTION_ID, 
        A.COLLECTOR_SITE_ID,   
        A.DISPOSER_SITE_ID,        
        A.COLLECTOR_MANAGER_ID,
        C.AVATAR_PATH,
        B.SITE_NAME,  
        A.QUANTITY,    
        A.UNIT,    
        A.PRICE,    
        A.TRMT_METHOD,    
        E.NAME,  
        D.DISPOSAL_ORDER_ID,  
        F.KIKCD_B_CODE,  
        G.SI_DO,   
        G.SI_GUN_GU,   
        G.EUP_MYEON_DONG,   
        G.DONG_RI,  
        F.ADDR,  
        F.LAT,  
        F.LNG
    FROM TRANSACTION_REPORT A 
    LEFT JOIN COMP_SITE B ON A.COLLECTOR_SITE_ID = B.ID
    LEFT JOIN V_USERS C ON A.COLLECTOR_SITE_ID = C.AFFILIATED_SITE
    LEFT JOIN WSTE_CLCT_TRMT_TRANSACTION D ON A.TRANSACTION_ID = D.ID
    LEFT JOIN WSTE_TRMT_METHOD E ON A.TRMT_METHOD = E.CODE
    LEFT JOIN SITE_WSTE_DISPOSAL_ORDER F ON A.DISPOSER_ORDER_ID = F.ID
    LEFT JOIN KIKCD_B G ON F.KIKCD_B_CODE = G.B_CODE
	WHERE A.ID = @TRANSACTION_REPORT_ID AND C.CLASS = 201;    
*/
/*
SET @USER_ID = 28;
SET @TRANSACTION_ID = 1;
call sp_req_transaction_report(28,1)
*/


/*
SET @USER_ID =28;
SET @SIGUNGU_CODE = '2611011100';
SET @IS_DEFAULT = 0;
CALL sp_add_sigungu(
	@USER_ID,
	@SIGUNGU_CODE,
	@IS_DEFAULT
);
*/

/*
SELECT 
		A.DISPOSER_ORDER_ID, 
        A.DISPOSER_ORDER_CODE, 
        A.DISPOSER_VISIT_START_AT,
        A.DISPOSER_VISIT_END_AT,
        A.DISPOSER_BIDDING_END_AT,
        A.WSTE_DISPOSED_KIKCD_B_CODE,
        A.WSTE_DISPOSED_ADDR,
        A.DISPOSER_CREATED_AT,
        B.SI_DO,
        B.SI_GUN_GU,
        B.EUP_MYEON_DONG,
        B.DONG_RI
    FROM V_SITE_WSTE_DISPOSAL_ORDER A LEFT JOIN KIKCD_B B ON A.WSTE_DISPOSED_KIKCD_B_CODE = B.B_CODE
    WHERE 
		A.COLLECTOR_ID IS NULL AND 
        IF(A.DISPOSER_VISIT_END_AT IS NOT NULL, DISPOSER_VISIT_END_AT >= NOW(), DISPOSER_BIDDING_END_AT >= NOW()) AND 
		LEFT(A.WSTE_DISPOSED_KIKCD_B_CODE, 5) IN (
			SELECT LEFT(C.KIKCD_B_CODE, 5) 
			FROM BUSINESS_AREA C 
			LEFT JOIN USERS D ON C.SITE_ID = D.AFFILIATED_SITE 
			WHERE D.ID = 11
		); 
*/

/*
UPDATE SITE_WSTE_DISPOSAL_ORDER A, (SELECT ID, DISPOSAL_ORDER_ID FROM WSTE_CLCT_TRMT_TRANSACTION) B SET A.TRANSACTION_ID = B.ID WHERE A.ID = B.DISPOSAL_ORDER_ID;
*/

/*
SET @USER_ID = 11;
CALL sp_retrieve_new_coming(
	@USER_ID
);
*/
/*
SET @USER_ID = 28;
SET @DISPOSER_ORDER_ID = 10;
SET @COLLECTOR_BIDDING_ID = 4;
SET @DISCHARGED_AT = '2022-04-05';
CALL sp_disposer_change_discharged_end_at(
	@USER_ID,
    @DISPOSER_ORDER_ID,
    @COLLECTOR_BIDDING_ID,
    @DISCHARGED_AT
);
*/
/*
SET @USER_ID = 190;
SET @STATE = 211;

SELECT 
		COLLECTOR_BIDDING_ID, 
		DISPOSER_ORDER_ID, 
        DISPOSER_ORDER_CODE, 
        STATE, 
        STATE_CODE, 
        STATE_CATEGORY, 
        STATE_CATEGORY_ID
    FROM V_COLLECTOR_BIDDING_WITH_STATE
	WHERE 
		STATE_CODE = @STATE AND 
        COLLECTOR_SITE_ID IN (
			SELECT AFFILIATED_SITE 
            FROM USERS 
            WHERE 
				ID = @USER_ID AND 
                ACTIVE = TRUE
        );
*/
/*
CALL sp_retrieve_current_state_by_option(
	@USER_ID,
    @STATE
);
*/
/*
CALL sp_req_disposal_order_details_2(355);
*/

/*
SELECT 
		A.DISPOSER_ORDER_ID, 
        A.DISPOSER_ORDER_CODE, 
        A.DISPOSER_VISIT_START_AT,
        A.DISPOSER_VISIT_END_AT,
        A.DISPOSER_BIDDING_END_AT,
        A.WSTE_DISPOSED_KIKCD_B_CODE,
        A.WSTE_DISPOSED_ADDR,
        A.DISPOSER_CREATED_AT,
        B.SI_DO,
        B.SI_GUN_GU,
        B.EUP_MYEON_DONG,
        B.DONG_RI
    FROM V_SITE_WSTE_DISPOSAL_ORDER A 
    LEFT JOIN KIKCD_B B ON A.WSTE_DISPOSED_KIKCD_B_CODE = B.B_CODE
    WHERE 
		A.COLLECTOR_ID IS NULL AND 				/*0.0.2에서 새롭게 추가한 부분*/
/*        
        IF(A.DISPOSER_VISIT_END_AT IS NOT NULL, 
			DISPOSER_VISIT_END_AT >= NOW(), 
            DISPOSER_BIDDING_END_AT >= NOW()
        ) AND 
		LEFT(A.WSTE_DISPOSED_KIKCD_B_CODE, 5) IN (
			SELECT LEFT(C.KIKCD_B_CODE, 5) 
			FROM BUSINESS_AREA C 
			LEFT JOIN USERS D ON C.SITE_ID = D.AFFILIATED_SITE 
			WHERE D.ID = 221
		);    
*/
/*
call sp_calc_bidding_rank_all();
*/

/*
CALL sp_retrieve_current_state(28);
*/


/*
call sp_req_close_bidding_early(119, 290);
*/

/*
SELECT B.BIDDING_END_AT INTO @BIDDING_END_AT 
    FROM COLLECTOR_BIDDING A INNER JOIN SITE_WSTE_DISPOSAL_ORDER B ON A.DISPOSAL_ORDER_ID = B.ID 
    WHERE A.ID = IN_COLLECTOR_BIDDING_ID;
*/

/*
SET @USER_ID = 188;
SET @COLLECTOR_BIDDING_ID = 231;
SET @ORDER_ID = 369;
SET @ASK_END_AT = '2022-2022-03-29';

CALL sp_req_select_collector(
	@USER_ID,
	@COLLECTOR_BIDDING_ID,
	@ORDER_ID,
	@ASK_END_AT
);
*/

/*
CALL sp_req_select_collector_without_handler(
	@COLLECTOR_BIDDING_ID,
	@ORDER_ID,
	@ASK_END_AT,
	@REG_DT,
	1,
	@rtn_val,
	@msg_txt
);

SELECT 
	@COLLECTOR_BIDDING_ID,
	@ORDER_ID,
	@ASK_END_AT,
	@REG_DT,
	@rtn_val,
	@msg_txt
*/

/*
CALL sp_get_company(14);
*/
/*
SELECT *
        FROM COMPANY PARENT LEFT JOIN COMPANY CHILD ON PARENT.ID = CHILD.P_COMP_ID
        WHERE CHILD.ID = 14;
*/

/*
SELECT 
		A.DISPOSER_ORDER_ID, 
        A.DISPOSER_ORDER_CODE, 
        A.DISPOSER_VISIT_START_AT,
        A.DISPOSER_VISIT_END_AT,
        A.DISPOSER_BIDDING_END_AT,
        A.WSTE_DISPOSED_KIKCD_B_CODE,
        A.WSTE_DISPOSED_ADDR,
        A.DISPOSER_CREATED_AT,
        B.SI_DO,
        B.SI_GUN_GU,
        B.EUP_MYEON_DONG,
        B.DONG_RI
    FROM V_SITE_WSTE_DISPOSAL_ORDER A 
    LEFT JOIN KIKCD_B B ON A.WSTE_DISPOSED_KIKCD_B_CODE = B.B_CODE
    WHERE 
		(A.COLLECTOR_ID IS NULL OR A.COLLECTOR_ID = 0) AND 
        IF(A.DISPOSER_VISIT_END_AT IS NOT NULL, 
			DISPOSER_VISIT_END_AT >= NOW(), 
            DISPOSER_BIDDING_END_AT >= NOW()
        ) AND 
		LEFT(A.WSTE_DISPOSED_KIKCD_B_CODE, 5) IN (
			SELECT LEFT(C.KIKCD_B_CODE, 5) 
			FROM BUSINESS_AREA C 
			LEFT JOIN USERS D ON C.SITE_ID = D.AFFILIATED_SITE 
			WHERE D.ID = 190
		);    
*/        

/*
SET @USER_ID = 190;
SET @STATE = 239;
CALL sp_retrieve_current_state_by_option(
	@USER_ID,
    @STATE
);
*/

/*
CALL sp_req_current_time(@REG_DT);
SET @USER_ID = 189;
SET @ORDER_ID = 400;
CALL sp_req_close_visit_early_without_handler(
	@USER_ID,
    @ORDER_ID,
    @REG_DT,
    @rtn_val,
    @msg_txt,
    @json_data
);

SELECT @USER_ID,
    @ORDER_ID,
    @REG_DT,
    @rtn_val,
    @msg_txt,
    @json_data;
    */
    
    
/*    
SET @USER_ID = 189;
SET @COLLECTOR_BIDDING_ID = 267;
SET @DISPOSAL_ORDER_ID = 400;
SET @ASK_END_AT = '2022-04-06';
*/

/*
call sp_req_select_collector(
	@USER_ID,
	@COLLECTOR_BIDDING_ID,
	@DISPOSAL_ORDER_ID,
	@ASK_END_AT
);
*/
/*
SELECT DISPOSAL_ORDER_ID, WINNER 
INTO @COLLECTOR_DISPOSAL_ORDER_ID, @WINNER 
FROM COLLECTOR_BIDDING 
WHERE ID = @COLLECTOR_BIDDING_ID;

SELECT @COLLECTOR_DISPOSAL_ORDER_ID, @WINNER ;
*/

/*
CALL sp_req_select_collector_without_handler(
	@COLLECTOR_BIDDING_ID,
	@DISPOSAL_ORDER_ID,
	@ASK_END_AT,
	@REG_DT,
	1,
	@rtn_val,
	@msg_txt
);

SELECT 
	@COLLECTOR_BIDDING_ID,
	@DISPOSAL_ORDER_ID,
	@ASK_END_AT,
	@REG_DT,
	@rtn_val,
	@msg_txt
    
*/

/*
CALL sp_setup_first_place_schedule(
	@DISPOSAL_ORDER_ID,
	@ASK_END_AT,
	@rtn_val,
	@msg_txt
);    
SELECT 
	@DISPOSAL_ORDER_ID,
	@ASK_END_AT,
	@rtn_val,
	@msg_txt
*/


/*
SET @USER_ID = 206;
SET @COLLECT_BIDDING_ID = 147;
SET @FINAL_DECISION = 0;
CALL sp_collector_make_final_decision_on_bidding(
	@USER_ID,
	@COLLECT_BIDDING_ID,
	@FINAL_DECISION
);
*/
/*
SELECT 
		A.DISPOSER_ORDER_ID, 
		A.DISPOSER_ID, 
		A.COLLECTOR_ID, 
		A.COLLECTOR_BIDDING_ID, 
        A.DISPOSER_OPEN_AT, 
        A.DISPOSER_CLOSE_AT, 
        A.DISPOSER_SITE_ID, 
        B.AVATAR_PATH
    FROM V_SITE_WSTE_DISPOSAL_ORDER_WITH_STATE A
	LEFT JOIN USERS B ON IF(B.AFFILIATED_SITE = 0, A.DISPOSER_ID = B.ID, A.DISPOSER_SITE_ID = B.AFFILIATED_SITE)
	WHERE 
		B.ID = 189 AND
        B.ACTIVE = TRUE AND
        A.DISPOSER_CLOSE_AT > NOW() AND
        A.STATE_CATEGORY_ID = 5;
*/

/*
CALL sp_retrieve_existing_transactions(198);
*/

/*
SELECT * FROM V_COLLECTOR_BIDDING_WITH_STATE A 
        LEFT JOIN USERS B ON A.COLLECTOR_SITE_ID = B.AFFILIATED_SITE
        LEFT JOIN V_COMP_SITE C ON A.COLLECTOR_SITE_ID = C.COMP_SITE_ID
        WHERE  
        A.COLLECTOR_SITE_ID = A.SUCCESS_BIDDER AND
        B.CLASS = 201;
*/


/*
UPDATE USERS SET AVATAR_PATH = 'https://chium.s3.ap-northeast-2.amazonaws.com/real/59f5f03b-4b6e-4138-b411-69403d298a4f.jpeg';
*/

/*
CALL sp_set_display_time(400, 5, @DISPLAY_TIME);
SELECT @DISPLAY_TIME;
*/

/*
SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'TRANSACTION_ID'			, TRANSACTION_ID, 
		'DISPOSAL_ORDER_ID'			, DISPOSER_ORDER_ID, 
		'COLLECT_ASK_END_AT'		, COLLECT_ASK_END_AT, 
		'COLLECTING_TRUCK_ID'		, COLLECTING_TRUCK_ID, 
		'TRUCK_DRIVER_ID'			, TRUCK_DRIVER_ID, 
		'TRUCK_START_AT'			, TRUCK_START_AT, 
		'COLLECT_END_AT'			, COLLECT_END_AT, 
		'CONTRACT_ID'				, CONTRACT_ID, 
		'DATE_OF_VISIT'				, DATE_OF_VISIT, 
		'VISIT_START_AT'			, VISIT_START_AT, 
		'VISIT_END_AT'				, VISIT_END_AT, 
		'IN_PROGRESS'				, IN_PROGRESS
	)) 
	INTO @STATE_INFO
	FROM V_WSTE_CLCT_TRMT_TRANSACTION_WITH_STATE
    WHERE  
		DISPOSER_ORDER_ID = 305 AND
        IN_PROGRESS = TRUE; 
SELECT @STATE_INFO;
*/

/*
CALL sp_calc_clct_trmt_vist_schedule_all();
*/


/*
SET @USER_ID = 166;
SET @COLLECT_BIDDING_ID = 49;
SET @FINAL_DECISION = 1;
CALL sp_collector_make_final_decision_on_bidding(
	@USER_ID,
	@COLLECT_BIDDING_ID,
	@FINAL_DECISION
);
*/

/*
SET @USER_ID=77;
SET @CATEGORY=101;
CALL sp_retrieve_my_disposal_lists_by_option(@USER_ID, @CATEGORY);
*/

/*
SELECT 
		A.ID, 
		A.ORDER_CODE, 
		A.DISPOSER_ID, 
		A.COLLECTOR_ID, 
		A.COLLECTOR_BIDDING_ID, 
        A.OPEN_AT, 
        A.CLOSE_AT, 
        A.SITE_ID, 
        B.AVATAR_PATH
    FROM SITE_WSTE_DISPOSAL_ORDER A
	LEFT JOIN USERS B ON IF(B.AFFILIATED_SITE = 0, A.DISPOSER_ID = B.ID, A.SITE_ID = B.AFFILIATED_SITE)
	LEFT JOIN WSTE_CLCT_TRMT_TRANSACTION C ON A.ID = C.DISPOSAL_ORDER_ID
	LEFT JOIN V_ORDER_STATE_NAME D ON A.ID = D.DISPOSER_ORDER_ID
	WHERE 
		B.ID = 201 AND
        B.ACTIVE = TRUE AND
        A.CLOSE_AT > NOW() AND
        D.STATE_CATEGORY_ID = 6;
*/

/*
SELECT B.SITE_NAME INTO @COLLECTOR_SITE_NAME
        FROM COLLECTOR_BIDDING A
        LEFT JOIN COMP_SITE B ON A.COLLECTOR_ID = B.ID
        WHERE A.ID = 291;       
SELECT     @COLLECTOR_SITE_NAME; 
*/   


/*
CALL sp_req_current_time(@REG_DT);

SET @USER_ID = 190;
SET @TRANSACTION_ID = 394;
SET @WSTE_CODE = '51';
SET @QUANTITY = 3500;
SET @PRICE = 52000000;
SET @TRMT_METHOD = '1001';
SET @IMG_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"https://chium.s3.ap-northeast-2.amazonaws.com/real/59f5f03b-4b6e-4138-b411-69403d298a4f.jpeg", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"https://chium.s3.ap-northeast-2.amazonaws.com/real/59f5f03b-4b6e-4138-b411-69403d298a4f.jpeg", "FILE_SIZE": 4.35}]';

CALL sp_req_collector_ask_transaction_completed(
	@USER_ID,
	@TRANSACTION_ID,
	@WSTE_CODE,
	@QUANTITY,
	@REG_DT,
	@PRICE,
	@TRMT_METHOD,
	@IMG_LIST
);
*/
/*
SET @TRANSACTION_ID = 394;
CALL sp_req_site_id_of_transaction_id(
	@TRANSACTION_ID,
    @DISPOER_SITE_ID,
    @COLLECTOR_SITE_ID
);

SELECT 
	@TRANSACTION_ID,
    @DISPOER_SITE_ID,
    @COLLECTOR_SITE_ID
*/

/*
SET @IN_TRANSACTION_ID = 394;
SET @IN_STATE = FALSE ;

CALL sp_req_processing_status(
	@IN_TRANSACTION_ID,
	@IN_STATE
);
*/

/*
	SELECT 
		ID, 
        COLLECTOR_SITE_ID,
        DISPOSAL_ORDER_ID,
        COLLECTOR_BIDDING_ID
        
    FROM WSTE_CLCT_TRMT_TRANSACTION
	WHERE 
		ID = @IN_TRANSACTION_ID AND 
        ISNULL(CONFIRMED_AT) = IF(@IN_STATE = FALSE, FALSE, TRUE);
*/
/*
SELECT DISPOSER_SITE_ID, COLLECTOR_SITE_ID, COLLECTOR_BIDDING_ID 
    INTO @DISPOER_SITE_ID, @COLLECTOR_SITE_ID, @COLLECTOR_BIDDING_ID
    FROM V_WSTE_CLCT_TRMT_TRANSACTION 
    WHERE TRANSACTION_ID = 394;
SELECT @DISPOER_SITE_ID, @COLLECTOR_SITE_ID, @COLLECTOR_BIDDING_ID;
*/


/*
SELECT 
		A.COLLECTOR_ID, 
        A.ID, 
        A.DISPOSAL_ORDER_ID,
        B.STATE_CODE,
        B.STATE,
        B.STATE_PID,
        B.STATE_CATEGORY_ID,
        B.STATE_CATEGORY,
        B.COLLECTOR_CATEGORY_ID,
        B.COLLECTOR_CATEGORY
    FROM COLLECTOR_BIDDING A
    LEFT JOIN V_BIDDING_STATE_NAME B ON A.ID = B.COLLECTOR_BIDDING_ID
	WHERE A.COLLECTOR_ID IN (SELECT AFFILIATED_SITE FROM USERS WHERE ID = 204 AND ACTIVE = TRUE);
*/
/*
CALL sp_retrieve_current_state(204);    
*/
/*
 SET @DISPOSER_ORDER_ID = 273;
 SET @COLLECTOR_BIDDING_ID = 117;
 SET @STATE_CATEGORY_ID = 0;
		CALL sp_set_display_time_for_collector(
			CUR_DISPOSER_ORDER_ID,
			CUR_COLLECTOR_BIDDING_ID,
			CUR_STATE_CATEGORY_ID,
			@RETRIEVE_CURRENT_STATE_DISPLAY_DATE
		);
*/
/*
SELECT 
		A.COLLECTOR_ID, 
        A.ID, 
        A.DISPOSAL_ORDER_ID,
        B.STATE_CODE,
        B.STATE,
        B.STATE_PID,
        B.COLLECTOR_CATEGORY_ID,
        B.COLLECTOR_CATEGORY
    FROM COLLECTOR_BIDDING A
    LEFT JOIN V_BIDDING_STATE_NAME B ON A.ID = B.COLLECTOR_BIDDING_ID
	WHERE A.COLLECTOR_ID IN (SELECT AFFILIATED_SITE FROM USERS WHERE ID = 204 AND ACTIVE = TRUE);
*/

/*
CALL sp_req_transaction_report(188, 394);
*/
/*
			CALL sp_req_site_id_from_transaction_report(
				394,
                @DISPOSER_SITE_ID,
                @COLLECTOR_SITE_ID
            );
            
            SELECT 
                @DISPOSER_SITE_ID,
                @COLLECTOR_SITE_ID
*/
/*
CALL sp_req_transaction_report(188);
*/
/*
CALL sp_get_transaction_report(11, @json_data);
select @json_data
*/


/*
			CALL sp_req_site_id_of_transaction_id(
				406,
                @DISPOSER_SITE_ID,
                @COLLECTOR_SITE_ID
            );
            SELECT 
                @DISPOSER_SITE_ID,
                @COLLECTOR_SITE_ID
*/

/*
CALL sp_retrieve_existing_transactions(188);    
*/



/*
CALL sp_req_current_time(@REG_DT);

SET @USER_ID = 190;
SET @TRANSACTION_ID = 394;
SET @WSTE_CODE = '51';
SET @QUANTITY = 3500;
SET @PRICE = 52000000;
SET @TRMT_METHOD = '1001';
SET @IMG_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"https://chium.s3.ap-northeast-2.amazonaws.com/temp/880b30b4-8933-41e7-90b1-af147ce11e51.png", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"https://chium.s3.ap-northeast-2.amazonaws.com/temp/880b30b4-8933-41e7-90b1-af147ce11e51.png", "FILE_SIZE": 4.35}]';

CALL sp_req_collector_ask_transaction_completed(
	@USER_ID,
	@TRANSACTION_ID,
	@WSTE_CODE,
	@QUANTITY,
	@REG_DT,
	@PRICE,
	@TRMT_METHOD,
	@IMG_LIST
);  
*/ 
/*
SELECT TRANSACTION_STATE_CODE, DISPOSAL_ORDER_ID 
INTO @STATE, @DISPOSER_ORDER_ID 
FROM V_TRANSACTION_STATE
WHERE TRANSACTION_ID = @TRANSACTION_ID;   

SELECT @STATE, @DISPOSER_ORDER_ID;
*/
/*
CALL sp_req_site_id_of_transaction_id(
	@TRANSACTION_ID,
	@DISPOSER_SITE_ID,
	@COLLECTOR_SITE_ID
);       
CALL sp_create_site_wste_photo_information(
	432,
	421,
	@REG_DT,
	'처리',
	@IMG_LIST,
	@rtn_val,
	@msg_txt
);      

SELECT 
	@REG_DT,
	@IMG_LIST,
	@rtn_val,
	@msg_txt
*/    


/*
CALL sp_req_current_time(@REG_DT);

SET @USER_ID = 215;
SET @TRANSACTION_ID = 378;
SET @WSTE_CODE = '51';
SET @QUANTITY = 3500;
SET @COMPLETED_AT = '2022-04-25';
SET @PRICE = 52000000;
SET @UNIT = 'Kg';
SET @TRMT_METHOD = '1001';
SET @IMG_LIST = '[{"FILE_NAME":"img_0001", "IMG_PATH":"https://chium.s3.ap-northeast-2.amazonaws.com/temp/880b30b4-8933-41e7-90b1-af147ce11e51.png", "FILE_SIZE": 2.35}, {"FILE_NAME":"img_0002", "IMG_PATH":"https://chium.s3.ap-northeast-2.amazonaws.com/temp/880b30b4-8933-41e7-90b1-af147ce11e51.png", "FILE_SIZE": 4.35}]';

CALL sp_req_collector_ask_transaction_completed(
	@USER_ID,
	@TRANSACTION_ID,
	@WSTE_CODE,
	@QUANTITY,
	@COMPLETED_AT,
	@PRICE,
	@UNIT,
	@TRMT_METHOD,
	@IMG_LIST
);  
*/
/*
SET @DISPOSER_ORDER_ID = 191;
SET @STATE_CATEGORY_CODE = 2;

call sp_test(
	@DISPOSER_ORDER_ID,
    @STATE_CATEGORY_CODE,
    @COLLECTOR_LIST
);
SELECT @DISPOSER_ORDER_ID, @STATE_CATEGORY_CODE, @COLLECTOR_LIST;
*/

/*
CALL sp_test(247);
*/


SET @USER_ID = 188;
SET @RESPONSE = TRUE;
SET @REPORT_ID = 34;
CALL sp_test(
	@USER_ID,
    @REPORT_ID,
    @RESPONSE
);