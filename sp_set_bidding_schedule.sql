CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_set_bidding_schedule`(
	IN IN_REF_DATE					DATETIME,			/*입력값 : 입찰 스케줄을 계산할 기준날짜*/
	IN IN_BIDDING_END_AT			DATETIME,			/*입력값 : 입찰종료일자*/
	IN IN_MAX_BIDDING_DURATION		INT,				/*입력값 : 입찰최대기간*/
	IN IN_OPEN_AT					DATETIME,			/*입력값 : 배출시작일자*/
	IN IN_CLOSE_AT					DATETIME,			/*입력값 : 배출종료일자*/
    OUT OUT_OPEN_AT					DATETIME,			/*출력값 : 변경배출시작일*/
    OUT OUT_CLOSE_AT				DATETIME,			/*출력값 : 변경배출종료일*/
    OUT rtn_val						INT,
    OUT msg_txt						VARCHAR(200)
)
BEGIN

/*
Procedure Name 	: sp_set_bidding_schedule
Input param 	: 5개
Output param 	: 4개
Job 			: 입찰에 필요한 일정을 조정 또는 변경한다.
Update 			: 2022.02.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
	SET @MAX_BIDDING_END_TARGET_DATE = DATE_ADD(IN_REF_DATE, INTERVAL IN_MAX_BIDDING_DURATION DAY);
	IF IN_BIDDING_END_AT <= @MAX_BIDDING_END_TARGET_DATE THEN
	/*입찰종료일이 정책적으로 결정된 기간 이내인 경우에는 정상처리한다.*/
		IF IN_CLOSE_AT IS NOT NULL THEN
		/*배출종료일이 결정된 경우*/
			IF IN_CLOSE_AT >= IN_BIDDING_END_AT THEN
			/*배출종료일이 정책적으로 결정된 기간 이후인 경우 정상처리한다.*/
				IF IN_OPEN_AT < IN_BIDDING_END_AT THEN
				/*폐기물 배출시작일이 입찰마감일 이전인 경우에는 입찰마감일을 배출시작일로 한다.*/
					SET OUT_OPEN_AT = IN_BIDDING_END_AT;
				ELSE
					CALL sp_req_policy_direction(
						'max_duration_to_disposal_open_at',
						@max_duration_to_disposal_open_at
					);
					SET @MAX_OPEN_AT = DATE_ADD(IN_BIDDING_END_AT, INTERVAL CAST(@max_duration_to_disposal_close_at AS UNSIGNED) DAY);
					IF IN_OPEN_AT >= @MAX_OPEN_AT THEN
					/*정책이 정하는 기간 이후을 폐기물 배출 시작일로 정한 경우에는 정책최대일로 변경한다.*/
						SET OUT_OPEN_AT = @MAX_OPEN_AT;
					ELSE
						SET OUT_OPEN_AT = IN_OPEN_AT;
					END IF;
				END IF;
				
				CALL sp_req_policy_direction(
					'max_duration_to_disposal_close_at',
					@max_duration_to_disposal_close_at
				);
				SET @MAX_CLOSE_AT = DATE_ADD(OUT_OPEN_AT, INTERVAL CAST(@max_duration_to_disposal_close_at AS UNSIGNED) DAY);
				
				IF IN_CLOSE_AT IS NULL THEN
					SET OUT_CLOSE_AT = @MAX_CLOSE_AT;
				ELSE
					IF IN_CLOSE_AT >= @MAX_CLOSE_AT THEN
					/*정책이 정하는 기간 이후을 폐기물 배출 시작일로 정한 경우에는 정책최대일로 변경한다.*/
						SET OUT_CLOSE_AT = @MAX_CLOSE_AT;
					ELSE
						SET OUT_CLOSE_AT = IN_CLOSE_AT;
					END IF;
				END IF;
				SET rtn_val = 0;
				SET msg_txt = 'Success';
			ELSE
			/*배출종료일이 정책적으로 결정된 기간 이내인 경우에는 예외처리한다.*/
				SET rtn_val = 30801;
				SET msg_txt = CONCAT('The emission end date cannot be earlier than the bidding deadline');
			END IF;
		ELSE
		/*배출종료일이 결정되지 않은 경우*/
			SET OUT_CLOSE_AT = @MIN_DISPOSAL_START_DATE;
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