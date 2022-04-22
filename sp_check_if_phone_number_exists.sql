CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_if_phone_number_exists`(
	IN IN_PHONE				VARCHAR(20),			/*입력값: 체크할 전화번호*/
    OUT OUT_PHONE_EXISTS	TINYINT
)
BEGIN

/*
Procedure Name 	: sp_check_if_phone_number_exists
Input param 	: 3개
Job 			: 등록하고자 하는 휴대폰번호의 이중등록여부 검사(이중등록이 아닌 경우 0 반환)
Update 			: 2022.03.10
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    CALL sp_req_policy_direction(
		'include_inactive_phone', 
        @include_inactive_phone
	);
    IF @include_inactive_phone = '1' THEN
    /*핸드폰 중복체크시 비활성화된 번호를 사용가능한 번호로 분류하고자 하는 경우*/
		SELECT COUNT(ID) INTO OUT_PHONE_EXISTS 
		FROM USERS 
		WHERE 
			PHONE = IN_PHONE AND 
			ACTIVE = TRUE;
    ELSE
    /*핸드폰 중복체크시 비활성화된 번호를 사용가능한 번호로 분류하지 않는 경우*/
		SELECT COUNT(ID) INTO OUT_PHONE_EXISTS 
		FROM USERS 
		WHERE 
			PHONE = IN_PHONE;
    END IF;
END