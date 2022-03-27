CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_ask_visit`(
	IN IN_USER_ID				BIGINT,					/*방문요청신청자(USERS.ID)*/
	IN IN_DISPOSER_ORDER_ID		BIGINT,					/*폐기물 배출 내역 고유등록번호(SITE_WSTE_DISPOSAL_ORDER.ID)*/
	IN IN_VISIT_AT				DATETIME,				/*방문요청일*/
	IN IN_REG_DT				DATETIME,				/*등록일*/
    OUT rtn_val 				INT,					/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)			/*출력값 : 처리결과 문자열*/	
)
BEGIN

/*
Procedure Name 	: sp_req_ask_visit
Input param 	: 4개
Output param 	: 2개
Job 			: 배출자의 방문요청일 수정 또는 신청
Update 			: 2022.01.21
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: REG_DT를 외부에서 입력자료로 받음
*/
    
	SELECT COUNT(ID) INTO @CHK_COUNT 
    FROM ASK_VISIT_SITE
    WHERE 
		DISPOSAL_ORDER_ID 	= IN_DISPOSER_ORDER_ID AND
		ASKER_ID 			= IN_USER_ID AND
        ACTIVE 				= TRUE;
	/*방문신청을 하는자가 기존에 방문신청을 한 사실 있는지 확인한다.*/
        
	IF @CHK_COUNT > 0 THEN
    /*만일 기존에 방문신청한 내역이 있는 경우*/
		UPDATE ASK_VISIT_SITE
        SET 
			VISIT_END_AT 		= IN_VISIT_AT,
            UPDATED_AT 			= IN_REG_DT
        WHERE 
			DISPOSAL_ORDER_ID 	= IN_DISPOSER_ORDER_ID AND
			ASKER_ID 			= IN_USER_ID;
        /*해당 방문내역의 방문시간을 변경처리한다.*/
        
        IF ROW_COUNT() = 1 THEN
        /*방문신청일 변경과정이 성공적으로 마무리 되었다면*/
			SET rtn_val = 0;
			SET msg_txt = 'Visit request success';
        ELSE
        /*방문신청일 변경과정에 오류가 발생하였다면 예외처리한다.*/
			SET rtn_val = 23201;
			SET msg_txt = 'Failed to change scheduled visit date';
        END IF;
    ELSE
    /*만일 기존에 방문신청한 내역이 없는 경우*/
		SELECT IF(MAX(ID) IS NULL, 1, MAX(ID) + 1) INTO @REG_ID
        FROM ASK_VISIT_SITE;
        /*신규로 등록할 신청고유등록번호를 계산한다.*/
        
		INSERT INTO ASK_VISIT_SITE (
			ID,
            DISPOSAL_ORDER_ID,
            ASKER_ID,
            ACTIVE,
            VISIT_END_AT,
            CREATED_AT,
            UPDATED_AT
        ) VALUES (
			@REG_ID,
            IN_DISPOSER_ORDER_ID,
            IN_USER_ID,
            TRUE,
            IN_VISIT_AT,
            IN_REG_DT,
            IN_REG_DT
        );
        /*방문신청일을 신규로 작성한다.*/
        
        IF ROW_COUNT() = 1 THEN
        /*방문신청일 신청과정이 성공적으로 마무리 되었다면*/
			SET rtn_val = 0;
			SET msg_txt = 'Visit request success';
        ELSE
        /*방문신청일 신청과정에 오류가 발생하였다면 예외처리한다.*/
			SET rtn_val = 23202;
			SET msg_txt = 'Failed to apply for scheduled visit date';
        END IF;
    END IF;
END