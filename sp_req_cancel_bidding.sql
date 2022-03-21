CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_cancel_bidding`(
	IN IN_USER_ID				BIGINT,				/*입력값 : 입찰취소를 시도하는 사용자 아이디(USERS.ID)*/
	IN IN_COLLECT_BIDDING_ID	BIGINT,				/*입력값 : 입찰 고유등록번호(COLLECTOR_BIDDING.ID)*/
    OUT rtn_val 				INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 				VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_req_cancel_bidding
Input param 	: 2개
Output param 	: 2개
Job 			: 수거자 등이 자신이 입찰한 내역에 대한 취소
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.30
Version			: 0.0.2
AUTHOR 			: Leo Nam
Change			: sp_cancel_bidding의 기능 전부 sp_req_cancel_bidding에 통합
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
	
	CALL sp_req_user_exists_by_id(
		IN_USER_ID, 
		TRUE, 
		@rtn_val,
		@msg_txt
	);
	/*IN_USER_ID가 이미 등록되어 있는 사용자인지 체크한다. 등록되어 있는 경우에는 @USER_EXISTS = 1, 그렇지 않은 경우에는 @USER_EXISTS = 0을 반환한다.*/
	/*이미 등록되어 있는 사용자인 경우에는 관리자(member.admin)인지 검사한 후 member.admin인 경우에는 사업자 생성권한을 부여하고 그렇지 않은 경우에는 예외처리한다.*/
	/*등록되어 있지 않은 경우에는 신규사업자 생성으로 간주하고 정상처리 진행한다.*/
	
	IF @rtn_val = 0 THEN
    /*입찰을 신청하는 사용자가 유효한 경우*/
		CALL sp_req_site_id_of_user_reg_id(
        /*사용자가 소속한 사이트의 고유등록번호를 반환한다.*/
			IN_USER_ID,
            @USER_SITE_ID
        );
        IF @USER_SITE_ID > 0 THEN
        /*사용자가 소속한 사이트가 존재하는 경우(개인 사용자 또는 치움 시스템 관리자가 아닌 경우)*/
			CALL sp_req_site_id_of_collector_bidding_id(
				IN_COLLECT_BIDDING_ID,
                @COLLECTOR_SITE_ID
            );
            IF @USER_SITE_ID = @COLLECTOR_SITE_ID THEN
            /*입찰을 취소하려는 사용자가 해당 입찰을 신청한 사업자의 사이트 소속인 경우*/
				CALL sp_req_user_class_by_user_reg_id(
				/*사용자의 권한을 반환한다.*/
					IN_USER_ID,
					@USER_CLASS
				);
				IF @USER_CLASS = 201 OR @USER_CLASS = 202 THEN
                /*입찰을 취소하려는 관리자가 취소권한을 가진 경우*/
					CALL sp_req_disposal_id_of_collector_bidding_id(
						IN_COLLECT_BIDDING_ID,
						@DISPOSAL_ORDER_ID
					);
					
					CALL sp_req_bidding_end_date_expired(
					/*입찰마감일이 종료되었는지 검사한다. 종료되었으면 TRUE, 그렇지 않으면 FALSE반환*/
						@DISPOSAL_ORDER_ID,
						@rtn_val,
						@msg_txt
					);
					IF @rtn_val = 0 THEN
					/*입찰마감일이 종료되지 않은 경우*/
						CALL sp_req_site_already_bid(
						/*이전에 입찰한 사실이 존재하는지 확인한다.*/
							@USER_SITE_ID,
							@DISPOSAL_ORDER_ID,
							@rtn_val,
							@msg_txt
						);
						IF @SITE_ALREADY_BID > 0 THEN
						/*사이트가 이전에 입찰한 사실이 있는 경우에는 입찰취소가 가능함*/
							CALL sp_req_current_time(@REG_DT);
							UPDATE COLLECTOR_BIDDING SET CANCEL_BIDDING = TRUE, CANCEL_BIDDING_AT = @REG_DT WHERE ID = IN_COLLECT_BIDDING_ID;
							/*입찰신청을 취소사태(비활성상태)로 변경한다.*/
							IF ROW_COUNT() = 0 THEN
							/*데이타베이스 입력에 실패한 경우*/
								SET rtn_val 		= 23705;
								SET msg_txt 		= 'db error occurred during bid cancellation';
								SIGNAL SQLSTATE '23000';
							ELSE
							/*데이타베이스 입력에 성공한 경우*/
								SET rtn_val 		= 0;
								SET msg_txt 		= 'Success';
							END IF;
						ELSE
						/*사이트가 이전에 입찰한 사실이 없는 경우 예외처리한다.*/
							SET rtn_val 		= 23704;
							SET msg_txt 		= 'No previous bids have been made';
							SIGNAL SQLSTATE '23000';
						END IF;
					ELSE
					/*입찰마감일이 종료된 경우 예외처리한다.*/
						SET rtn_val 		= @rtn_val;
						SET msg_txt 		= @msg_txt;
						SIGNAL SQLSTATE '23000';
					END IF;
                ELSE
                /*입찰을 취소하려는 관리자가 취소권한을 가지지 않은 경우 예외처리한다.*/
					SET rtn_val = 23701;
					SET msg_txt = 'The user who wants to cancel the bid does not have the right to cancel';
					SIGNAL SQLSTATE '23000';                    
                END IF;				
            ELSE
            /*입찰을 취소하려는 사용자가 해당 입찰을 신청한 사업자의 사이트 소속이 아닌 경우 예외처리한다.*/
				SET rtn_val = 23702;
				SET msg_txt = 'The applicant for cancellation of the bid does not belong to the site';
				SIGNAL SQLSTATE '23000';
            END IF;
        ELSE
        /*사용자가 소속한 사이트가 존재하지 않는 경우(개인 사용자 또는 치움 시스템 관리자인 경우)에는 예외처리한다.*/
			SET rtn_val = 23703;
			SET msg_txt = 'Individual users do not have the right to cancel bids';
			SIGNAL SQLSTATE '23000';
        END IF;
    ELSE
    /*입찰을 신청하는 사용자가 존재하지 않거나 유효하지 않은 경우*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
    
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END