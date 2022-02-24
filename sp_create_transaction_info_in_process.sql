CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_transaction_info_in_process`(
	IN IN_USER_ID						BIGINT,						/*입력값 : 사용자의 고유등록번호(USERS.ID)*/
	IN IN_COLLECTOR_BIDDING_ID			BIGINT,						/*입력값 : COLLECTOR_BIDDING.ID*/
	IN IN_WSTE_CODE						VARCHAR(8),					/*입력값 : 폐기물 코드*/
	IN IN_WSTE_QUANTITY					FLOAT,						/*입력값 : 폐기물 중량(수량)*/
	IN IN_WSTE_PRICE_UNIT				FLOAT,						/*입력값 : 폐기물 처리 단가*/
	IN IN_WSTE_UNIT						ENUM('kg','m3'),			/*입력값 : 폐기물 처리 단위*/
	IN IN_WSTE_TRMT_METHOD				VARCHAR(4),					/*입력값 : 폐기물 처리 방법*/
	IN IN_IMG_LIST						JSON,						/*입력값 : 처리사진 등록 리스트*/
	IN IN_COMPLETED_AT					DATETIME,					/*입력값 : 폐기물 처리일자*/
	OUT rtn_val							INT,						/*출력값 : 처리결과 코드*/
	OUT msg_txt 						VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_create_transaction_info_in_process
Input param 	: 9개
Output param 	: 2개
Job 			: 수거자가 자신이 처리한 폐기물에 대한 내역을 등록한다. 사진 데이타는 JSON으로 입력 받는다.
Update 			: 2022.01.25
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
        
	CALL sp_req_user_exists_by_id(
    /*등록하려는 사용자의 유효성을 검사한다.*/
		IN_USER_ID, 
		TRUE, 
		@rtn_val,
		@msg_txt
	);
	
	IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우*/
		CALL sp_req_collector_bidding_exists(
        /*폐기물 처리작업이 존재하는지 검사한다.*/
			IN_COLLECTOR_BIDDING_ID,
            TRUE,
			@rtn_val,
			@msg_txt
        );
        IF @rtn_val = 0 THEN
        /*트랜잭션이 존재하는 경우*/        
			CALL sp_req_site_id_of_user_reg_id(
			/*사용자가 소속한 사이트의 고유등록번호를 반환한다.*/
				IN_USER_ID,
				@USER_SITE_ID,
				@rtn_val,
				@msg_txt
			);
			IF @rtn_val = 0 THEN
			/*사이트가 정상(개인사용자는 제외됨)적인 경우*/
				CALL sp_req_site_id_of_collector_bidding(
				/*COLLECTOR_BIDDING의 수거자와 배출자에 대한 사이트 고유등록번호를 반환한다.*/
					IN_COLLECTOR_BIDDING_ID,
					@DISPOSER_SITE_ID,
					@COLLECTOR_SITE_ID
				);
				IF @USER_SITE_ID = @COLLECTOR_SITE_ID THEN
				/*사용자가 수거자 소속의 관리자인 경우*/
					CALL sp_req_user_class_by_user_reg_id(
					/*사이트의 관리자인 사용자의 권한을 반환한다.*/
						IN_USER_ID,
						@USER_CLASS
					);
					IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
					/*사용자자 트랜잭션 작업을 등록할 권한이 있는 경우*/
						CALL sp_insert_transaction_info_in_process_woh(
						/*폐기물 처리정보를 데이타베이스에 등록한다.*/
							IN_USER_ID,					/*입력값 : 사용자의 고유등록번호(USERS.ID)*/
							IN_TRANSACTION_ID,			/*입력값 : WSTE_CLCT_TRMT_TRANSACTION.ID*/
							IN_WSTE_CODE,				/*입력값 : 폐기물 코드*/
							IN_WSTE_QUANTITY,			/*입력값 : 폐기물 중량(수량)*/
							IN_WSTE_PRICE_UNIT,			/*입력값 : 폐기물 처리 단가*/
							IN_WSTE_UNIT,				/*입력값 : 폐기물 처리 단위*/
							IN_WSTE_TRMT_METHOD,		/*입력값 : 폐기물 처리 방법*/
							IN_IMG_LIST,				/*입력값 : 처리사진 등록 리스트*/
							IN_COMPLETED_AT,			/*입력값 : 폐기물 처리일자*/
							@rtn_val,					/*출력값 : 처리결과 코드*/
							@msg_txt					/*출력값 : 처리결과 문자열*/
						);
					ELSE
					/*사용자자 트랜잭션 작업을 등록할 권한이 없는 경우 예외처리한다.*/
						SET rtn_val = 25101;
						SET msg_txt = 'User does not have permission';
						SIGNAL SQLSTATE '23000';
					END IF;
				ELSE
				/*사용자가 수거자 소속의 관리자가 아닌 경우 예외처리한다.*/
					SET rtn_val = 25102;
					SET msg_txt = 'The user is not affiliated with the collector site';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사이트가 존재하지 않거나 유효하지 않은(개인사용자의 경우) 경우*/
				SET rtn_val = @rtn_val;
				SET msg_txt = @msg_txt;
				SIGNAL SQLSTATE '23000';
			END IF;
        ELSE
        /*트랜잭션이 존재하지 않는 경우 예외처리한다.*/
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt;
            SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*사용자가 존재하지 않거나 유효하지 않은 경우 예외처리한다.*/
		SET rtn_val = @rtn_val;
		SET msg_txt = @msg_txt;
        SIGNAL SQLSTATE '23000';
    END IF;
END