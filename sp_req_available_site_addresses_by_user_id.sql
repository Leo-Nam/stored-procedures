CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_available_site_addresses_by_user_id`(
	IN IN_USER_ID			BIGINT,
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(100)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_available_site_addresses_by_user_id
Input param 	: 1개
Output param 	: 0개
Job 			: 입력받은 사업자 관리자에 의하여 관리되는 모든 사이트의 주소를 반환한다. 추후 JSON 리턴 로직 만들어야 함
Update 			: 2022.01.28
Version			: 0.0.2
AUTHOR 			: Leo Nam
*/

	CALL sp_req_comp_id_of_user_by_id(
	/*사용자가 속하는 사업자의 고유등록번호를 반환한다.*/	
		IN_USER_ID,
        @COMP_ID
    );
    
    CALL sp_req_site_id_of_user_reg_id(
	/*사용자가 속하는 사이트의 고유등록번호를 반환한다.*/	
		IN_USER_ID,
        @SITE_ID,
		@rtn_val,
		@msg_txt
    );    
    
	IF @rtn_val = 0 THEN
	/*사이트가 정상(개인사용자는 제외됨)적인 경우*/
		CALL sp_req_is_site_head_office(
		/*사용자가 속한 사이트가 HEAD OFFICE인지 검사한다.*/
			@SITE_ID,
			@IS_USER_SITE_HEAD_OFFICE
		);
		
		IF @IS_USER_SITE_HEAD_OFFICE = TRUE THEN
		/*사용자가 속한 사이트가 사업자의 HEAD OFFICE인 경우에는 사업자에 속하는 모든 사이트의 주소를 반환한다.*/
			CALL sp_req_comp_site_addresses(
			/*사업자에 속하는 모든 사이트의 주소를 반환한다.*/
				@COMP_ID
			);
		ELSE
		/*사용자가 속한 사이트가 사업자의 HEAD OFFICE가 아닌 경우에는 사용자가 속하는 사이트의 주소만 반환한다.*/
			CALL sp_req_site_addresses_by_site_id(
			/*사이트 고유등록번호로 사이트의 주소를 반환한다.*/
				@SITE_ID
			);
		END IF;
	ELSE
	/*사이트가 존재하지 않거나 유효하지 않은(개인사용자의 경우) 경우*/
		SET rtn_val = @rtn_val;
		SET msg_txt = @msg_txt;
	END IF;
END