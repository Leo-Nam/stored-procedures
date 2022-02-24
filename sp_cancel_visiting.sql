CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_cancel_visiting`(
	IN IN_USER_ID					BIGINT,				/*입력값 : 사용자 고유등록번호(USERS.ID)*/
	IN IN_COLLECT_BIDDING_ID		BIGINT				/*입력값 : 입찰 고유등록번호(COLLECTOR_BIDDING.ID)*/
)
BEGIN

/*
Procedure Name 	: sp_cancel_visiting
Input param 	: 2개
Job 			: 폐기물 수집업자 등이 자신이 신청한 입찰건에 대한 방문을 취소한다.
TIME_ZONE 		: UTC + 09:00 처리하여 시간을 수동입력하였음
Update 			: 2022.01.27
Version			: 0.0.3
AUTHOR 			: Leo Nam
Change			: COLLECTOR_BIDDING의 CANCEL_BIDDING 칼럼 상태를 TRUE로 변경함으로써 입찰을 포기하는 상태로 전환함(0.0.2)
				: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.3)
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  

    CALL sp_req_current_time(@REG_DT);
    /*UTC 표준시에 9시간을 추가하여 ASIA/SEOUL 시간으로 변경한 시간값을 현재 시간으로 정한다.*/
    
	CALL sp_req_user_exists_by_id(
	/*생성자가 존재하는지 체크한다.*/
		IN_USER_ID, 
		TRUE, 
		@rtn_val,
		@msg_txt
	);
	/*등록을 요청하는 사용자의 USER_ID가 이미 등록되어 있는 경우에는 @USER_EXISTS = 1, 그렇지 않은 경우에는 @USER_EXISTS = 0이 됨*/ 		
	IF @rtn_val = 0 THEN
    /*사용자가 존재하는 경우*/
		CALL sp_req_disposal_id_of_collector_bidding_id(
			IN_COLLECT_BIDDING_ID,
			@DISPOSAL_ORDER_ID
		);
		
		CALL sp_req_visit_date_expired(
		/*방문마감일정이 남아 있는지 확인한다.*/
			@DISPOSAL_ORDER_ID,
			@rtn_val,
			@msg_txt
		);
		IF @rtn_val = 26601 THEN
		/*방문마감일이 종료되지 않은 경우*/
			SELECT COUNT(ID) INTO @ITEM_COUNT FROM COLLECTOR_BIDDING WHERE ID = IN_COLLECT_BIDDING_ID;
            IF @ITEM_COUNT = 1 THEN
            /*정보를 수정하려는 데이타가 존재하는 경우 정상처리한다.*/
				UPDATE COLLECTOR_BIDDING SET CANCEL_VISIT = FALSE WHERE ID = IN_COLLECT_BIDDING_ID;
				/*방문신청을 취소상태(비활성상태)로 변경한다.*/
				IF ROW_COUNT() = 1 THEN
				/*데이타베이스 입력에 성공한 경우*/
					SET @rtn_val 		= 0;
					SET @msg_txt 		= 'Success';
				ELSE
				/*데이타베이스 입력에 실패한 경우*/
					SET @rtn_val 		= 25601;
					SET @msg_txt 		= 'record cancellation error';
					SIGNAL SQLSTATE '23000';
				END IF;
            ELSE
            /*정보를 수정하려는 데이타가 존재하지 않는 경우 예외처리한다.*/
				SET @rtn_val 		= 25603;
				SET @msg_txt 		= 'No data found';
				SIGNAL SQLSTATE '23000';
            END IF;
		ELSE
		/*방문마감일이 종료된 경우 예외처리한다.*/
			SET @rtn_val 		= 25602;
			SET @msg_txt 		= 'The visit date has already passed or No visit request plan';
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE
    /*사용자가 존재하지 않거나 유효하지 않은 경우*/
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END