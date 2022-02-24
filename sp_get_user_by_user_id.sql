CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_get_user_by_user_id`(
	IN IN_USER_ID			BIGINT,				/*입력값 : 사용자 아이디*/
    OUT OUT_REG_ID			BIGINT,				/*출력값 : 사용자 고유번호*/
    OUT OUT_PWD				VARCHAR(100),		/*출력값 : 사용자 암호*/
    OUT OUT_USER_NAME		VARCHAR(20),		/*출력값 : 사용자 이름*/
    OUT OUT_PHONE			VARCHAR(20),		/*출력값 : 사용자 등록 전화번호*/
    OUT OUT_BELONG_TO		BIGINT,				/*출력값 : 사용자 소속 사업자로서 어떤 사업자에도 소속되어 있지 않은 개인인 경우에는 0이며 특정 사업자에게 소속된 관리자인 사용자의 경우에는 소속 사업자의 고유번호(COMPANY.ID)가 등록됨*/
    OUT OUT_ACTIVE			TINYINT,			/*출력값 : 사용자의 계정 활성화 상태로서 TRUE인 경우에는 계정이 활성화 된 것이며 FALSE인 경우에는 비활성화인 상태로서 계정활성화 이후 트랜잭션이 가능함*/
    OUT OUT_JWT				VARCHAR(100),		/*출력값 : JWT 스티링*/
    OUT OUT_FCM				VARCHAR(100),		/*출력값 : FCM 스티링*/
    OUT OUT_CLASS			INT,				/*출력값 : 사용자의 클래스로서 입력값은 USERS_CLASS의 ID값이다. 사용자 클래스는 USERS_CLASS에서 정의하고 있다.*/
    OUT OUT_CLASS_NM		VARCHAR(20)			/*출력값 : 사용자의 클래스로서 일반 회원인 경우에는 member.***이고, 시스템 관리자인 경우에는 sys.***이다.*/
)
BEGIN

/*
Procedure Name 	: sp_get_user_by_user_id
Input param 	: 1개
Output param 	: 10개
Job 			: 사용자등록 아이디(USER_ID)를 사용하는 사용자에 대한 정보를 반환한다.
Update 			: 2022.01.17
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

	SELECT 
		ID, 
        PWD, 
        USER_NAME, 
        PHONE, 
        BELONG_TO, 
        ACTIVE, 
        JWT, 
        FCM, 
        CLASS, 
        CLASS_NM 
	INTO 
		OUT_REG_ID, 
        OUT_PWD, 
        OUT_USER_NAME, 
        OUT_PHONE, 
        OUT_BELONG_TO, 
        OUT_ACTIVE, 
        OUT_JWT, 
        OUT_FCM, 
        OUT_CLASS, 
        OUT_CLASS_NM
	FROM V_USERS 
    WHERE ID = IN_USER_ID;
END