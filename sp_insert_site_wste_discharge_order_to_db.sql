CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_site_wste_discharge_order_to_db`(
	IN IN_REF_DATE					DATETIME,			/*입력값 : 입찰 스케줄을 계산할 기준날짜*/
	IN IN_BIDDING_END_AT			DATETIME,			/*입력값 : 입찰종료일자*/
	IN IN_MAX_BIDDING_DURATION		INT,				/*입력값 : 입찰최대기간*/
	IN IN_CLOSE_AT					DATETIME,			/*입력값 : 배출종료일자*/
    OUT OUT_CLOSE_AT				DATETIME,			/*출력값 : 변경배출종료일*/
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_insert_site_wste_discharge_order_to_db
Input param 	: 4개
Output param 	: 3개
Job 			: 폐기물 배출 작업 ORDER를 작성(SITE_WSTE_DISPOSAL_ORDER)한다.
Update 			: 2022.02.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
     
	IF IN_BIDDING_END_AT <= DATE_ADD(IN_REF_DATE, INTERVAL IN_MAX_BIDDING_DURATION DAY) THEN
	/*입찰종료일이 정책적으로 결정된 기간 이내인 경우에는 정상처리한다.*/
		CALL sp_req_policy_direction(
			'min_disposal_duration',
			@min_disposal_duration
		);
		IF IN_CLOSE_AT IS NOT NULL THEN
		/*배출종료일이 결정된 경우*/
			IF IN_CLOSE_AT >= DATE_ADD(IN_BIDDING_END_AT, INTERVAL @min_disposal_duration DAY) THEN
			/*배출종료일이 정책적으로 결정된 기간 이후인 경우 정상처리한다.*/
			/*데이타베이스 입력처리를 시작한다.*/
				SET OUT_CLOSE_AT = IN_CLOSE_AT;
				SET rtn_val = 0;
				SET msg_txt = 'Success';
			ELSE
			/*배출종료일이 정책적으로 결정된 기간 이내인 경우에는 예외처리한다.*/
				SET rtn_val = 30801;
				SET msg_txt = CONCAT('The discharge end date must be ', @min_disposal_duration, ' days after the bidding deadline');
			END IF;
		ELSE
		/*배출종료일이 결정되지 않은 경우*/
			SET OUT_CLOSE_AT = DATE_ADD(IN_BIDDING_END_AT, INTERVAL @min_disposal_duration DAY);
			/*데이타베이스 입력처리를 시작한다.*/    
			SET rtn_val = 0;
			SET msg_txt = 'Success';                                    
		END IF;
	ELSE
	/*입찰종료일이 정책적으로 결정된 기간 이후인 경우에는 예외처리한다.*/
		SET rtn_val = 30802;
		SET msg_txt = CONCAT('The bidding end date must be within ', IN_MAX_BIDDING_DURATION, ' days from the bidding start date');
	END IF;

END