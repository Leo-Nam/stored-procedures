CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_main_top_lists_create_body`(
    IN IN_PUSH_ID						INT,
    OUT OUT_BODY						VARCHAR(255)
)
BEGIN

/*
Procedure Name 	: sp_admin_main_top_lists_create_body
Input param 	: 1개
Job 			: 관리자 메인에서 사용되는 리스트의 BODY를 만들어 반환한다.
Update 			: 2022.04.24
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    SELECT 
		A.CATEGORY_ID,
        A.SENDER_ID,
        IF(A.SENDER_ID = 0, '시스템', IF(B.AFFILIATED_SITE = 0, B.USER_NAME, C.SITE_NAME)),
        A.USER_ID,
        IF(A.USER_ID = 0, '시스템', IF(D.AFFILIATED_SITE = 0, D.USER_NAME, E.SITE_NAME)),
        F.ORDER_CODE
	INTO
		@CATEGORY_ID,
        @SENDER_ID,
        @SENDER_NAME,
        @USER_ID,
        @USER_NAME,
        @ORDER_CODE
	FROM PUSH_HISTORY A
    LEFT JOIN USERS B ON A.SENDER_ID = B.ID
    LEFT JOIN COMP_SITE C ON B.AFFILIATED_SITE = C.ID
    LEFT JOIN USERS D ON A.USER_ID = D.ID
    LEFT JOIN COMP_SITE E ON D.AFFILIATED_SITE = E.ID
    LEFT JOIN SITE_WSTE_DISPOSAL_ORDER F ON A.ORDER_ID = F.ID
    WHERE A.ID = IN_PUSH_ID;
    
	IF @CATEGORY_ID = 1 THEN
		SET OUT_BODY = CONCAT('[', @ORDER_CODE, ']의 폐기물 배출신청을 하였습니다.');
        SET @PICKED = TRUE;
	END IF;
    
	IF @CATEGORY_ID = 2 THEN
		SET OUT_BODY = CONCAT('[', @ORDER_CODE, ']에 대하여 배출자가 방문신청을 수락하였습니다.');
        SET @PICKED = TRUE;
	END IF;
    
	IF @CATEGORY_ID = 3 THEN
		SET OUT_BODY = CONCAT('[', @ORDER_CODE, ']에 방문신청이 접수되었습니다.');
        SET @PICKED = TRUE;
	END IF;
    
	IF @PICKED = FALSE THEN
		SET OUT_BODY = '기타입니다.';
	END IF;
    
END