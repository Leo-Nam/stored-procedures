CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_site_without_handler`(
    IN IN_SITE_ID						BIGINT,				/*입력값 : 삭제할 사이트 아이디*/
    IN IN_REG_DT						DATETIME,			/*입력값 : 실행 시간*/
    OUT rtn_val 						INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 						VARCHAR(200)		/*출력값 : 처리결과 문자열*/
    
)
BEGIN

/*
Procedure Name 	: sp_delete_user
Input param 	: 1개
Job 			: 사이트를 삭제하는 기능
Update 			: 2022.01.29
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/
    
    SELECT COUNT(ID) INTO @COUNT_OF_DELETED_SITE
    FROM COMP_SITE
    WHERE 
		ACTIVE = FALSE AND
		ID = IN_SITE_ID;
	IF @COUNT_OF_DELETED_SITE = 0 THEN
    /*사이트가 아직 삭제가 되지 않은 경우 정상처리한다.*/
		UPDATE COMP_SITE 
		SET 
			ACTIVE 			= FALSE, 
			UPDATED_AT 		= @REG_DT 
		WHERE ID 			= IN_SITE_ID;
			
		IF ROW_COUNT() = 1 THEN
		/*모든 트랜잭션이 성공한 경우에만 로그를 한다.*/
			CALL sp_calc_bidding_rank_after_delete_site(
				IN_SITE_ID,
                rtn_val,
                msg_txt
			);
		ELSE
		/*변경이 적용되지 않은 경우*/
			SET rtn_val = 36902;
			SET msg_txt = 'Failed to delete site account';
		END IF;
    ELSE
    /*사이트가 이미 삭제된 경우에는 예외처리한다.*/
		SET rtn_val = 36901;
		SET msg_txt = 'site already deleted';
    END IF;
END