CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_site_wste_discharge_order_without_handler`(
	IN IN_USER_ID					BIGINT,						/*입력값 : 폐기물 배출 주체의 고유등록번호(USERS.ID)*/
	IN IN_COLLECTOR_SITE_ID			BIGINT,						/*입력값 : 폐기물 수거자의 고유등록번호(COMP_SITE.ID)*/
	IN IN_DISPOSER_SITE_ID			BIGINT,						/*입력값 : 폐기물 배출 사이트의 고유등록번호(COMP_SITE.ID)*/
	IN IN_DISPOSER_TYPE				ENUM('person','company'),	/*입력값 : 폐기물 배출 주체의 종류*/
	IN IN_KIKCD_B_CODE				VARCHAR(10),				/*입력값 : 폐기물 배출지가 소재하는 소재지의 시군구코드(KIKCD_B.B_CODE)*/
	IN IN_ADDR						VARCHAR(200),				/*입력값 : 폐기물 배출지가 소재하는 소재지의 시군구 이하 상세주소*/
	IN IN_VISIT_START_AT			DATETIME,					/*입렦값 : 폐기물 배출지에서 요구하는 방문시작일로서 NULL인 경우에는 방문 불필요*/
	IN IN_VISIT_END_AT				DATETIME,					/*입력값 : 폐기물 배출지에서 요구하는 방문종료일로서 NULL인 경우에는 방문 불필요*/
	IN IN_BIDDING_END_AT			DATETIME,					/*입력값 : 폐기물 처리 용역 입찰 종료일*/
	IN IN_OPEN_AT					DATETIME,					/*입력값 : 폐기물 배출 시작일*/
	IN IN_CLOSE_AT					DATETIME,					/*입력값 : 폐기물 배출 종료일*/
	IN IN_WSTE_CLASS				JSON,						/*입력값 : 폐기물 배출지에서 배출되는 폐기물의 종류 리스트*/
	IN IN_PHOTO_LIST				JSON,						/*입력값 : 폐기물 배출지에서 배출되는 폐기물의 사진 리스트*/
	IN IN_NOTE						VARCHAR(255),				/*입력값 : 폐기물 배출시 요청사항*/
	IN IN_REG_DT					DATETIME,					/*입력값 : 등록일자*/
    OUT rtn_val 					INT,						/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_insert_site_wste_discharge_order_without_handler
Input param 	: 14개
Output param 	: 2개
Job 			: 폐기물 배출 작업 ORDER를 작성(SITE_WSTE_DISPOSAL_ORDER)한다.
Update 			: 2022.02.18
Version			: 0.0.7
AUTHOR 			: Leo Nam
Change			: 폐기물 배출 사이트의 고유등록번호도 저장하게 됨으로써 입력값으로 IN_DISPOSER_SITE_ID 받아서 테이블에 입력한다.
				: 폐기물 배출작업 생성 기능 추가(0.0.4)
				: sp_create_site_wste_photo_information에 IN_CLASS_CODE입력 추가(0.0.5)
				: VISIT_START_AT 칼럼 추가(0.0.6)
				: 입찰스케줄에 대한 로직 추가(0.0.7)
*/
     
	IF IN_DISPOSER_TYPE = 'company' THEN
	/*배출자가 사업자인 경우에는 사업자가 사용하는 작업지시서를 가져온다. 작업지시서가 없으면 NULL값을 반환한다.*/
		CALL sp_req_service_instruction_id_of_site(
			@SITE_ID,
			@SERVICE_INSTRUCTION_ID
		);
	END IF;
    
	SET @str_year = RIGHT(YEAR(IN_REG_DT), 2);
	IF MONTH(IN_REG_DT) < 10 THEN
		SET @str_month = CONCAT('0', MONTH(IN_REG_DT));
	ELSE
		SET @str_month = MONTH(IN_REG_DT);
	END IF;
    
    SET @YEAR_MONTH = CONCAT(@str_year, @str_month);
    SELECT COUNT(ID) INTO @MONTH_COUNT 
    FROM SITE_WSTE_DISPOSAL_ORDER 
    WHERE 
		YEAR(IN_REG_DT) 	= YEAR(CREATED_AT) AND 
        MONTH(IN_REG_DT) 	= MONTH(CREATED_AT);
	IF @MONTH_COUNT < 10 THEN
		SET @ORDER_CODE = CONCAT(@YEAR_MONTH, '-0000', @MONTH_COUNT);
    ELSE
		IF @MONTH_COUNT < 100 THEN
			SET @ORDER_CODE = CONCAT(@YEAR_MONTH, '-000', @MONTH_COUNT);
		ELSE
			IF @MONTH_COUNT < 1000 THEN
				SET @ORDER_CODE = CONCAT(@YEAR_MONTH, '-00', @MONTH_COUNT);
			ELSE
				IF @MONTH_COUNT < 10000 THEN
					SET @ORDER_CODE = CONCAT(@YEAR_MONTH, '-0', @MONTH_COUNT);
				ELSE
					SET @ORDER_CODE = CONCAT(@YEAR_MONTH, '-', @MONTH_COUNT);
				END IF;
			END IF;
		END IF;
    END IF;
    
    IF IN_VISIT_START_AT IS NOT NULL THEN
    /*방문 시작일이 결정된 경우*/
		IF IN_VISIT_START_AT >= IN_REG_DT THEN
        /*방문시작일이 입찰등록일 이후인 경우에는 정상처리한다.*/
			CALL sp_req_policy_direction(
				'max_visit_start',
                @max_visit_start
            );
            /*IF IN_VISIT_START_AT <= ADDTIME(IN_REG_DT, CONCAT(CAST(@max_visit_start AS UNSIGNED)*24, ':00:00')) THEN*/
            IF IN_VISIT_START_AT <= DATE_ADD(IN_REG_DT, INTERVAL @max_visit_start DAY) THEN
            /*방문시작일이 정책적으로 결정된 기간 이내인 경우에는 정상처리한다.*/
				IF IN_VISIT_END_AT IS NOT NULL THEN
                /*방문종료일이 결정된 경우*/
					IF IN_VISIT_END_AT >= IN_VISIT_START_AT THEN
					/*방문종료일이 방문시작일 이후인 경우에는 정상처리한다.*/
						CALL sp_req_policy_direction(
							'max_visit_duration',
							@max_visit_duration
						);
						/*IF IN_VISIT_END_AT <= ADDTIME(IN_VISIT_START_AT, CONCAT(CAST(@max_visit_duration AS UNSIGNED)*24, ':00:00')) THEN*/
						IF IN_VISIT_END_AT <= DATE_ADD(IN_VISIT_START_AT, INTERVAL @max_visit_duration DAY) THEN
						/*방문종료일이 정책적으로 결정된 기간 이내인 경우에는 정상처리한다.*/
							IF IN_OPEN_AT IS NULL THEN
								SET IN_OPEN_AT = IN_REG_DT;
							END IF;
							IF IN_BIDDING_END_AT IS NOT NULL THEN
                            /*입찰종료일을 입력한 경우에는 정상처리한다.*/
								CALL sp_req_policy_direction(
									'max_bidding_duration',
									@max_bidding_duration
								);     
								CALL sp_set_bidding_schedule(
									IN_VISIT_END_AT,
									IN_BIDDING_END_AT,
									CAST(@max_bidding_duration AS UNSIGNED),
									IN_OPEN_AT,
									IN_CLOSE_AT,
									@OPEN_AT,
									@CLOSE_AT,
									@rtn_val,
									@msg_txt
								);
                                IF @rtn_val = 0 THEN
                                /*프로시저 처리가 성공한 경우*/
									CALL sp_insert_site_wste_discharge_order_to_table(
										IN_USER_ID,
										IN_COLLECTOR_SITE_ID,
										IN_DISPOSER_SITE_ID,
										IN_DISPOSER_TYPE,
										IN_KIKCD_B_CODE,
										IN_ADDR,
										IN_VISIT_START_AT,
										IN_VISIT_END_AT,
										IN_BIDDING_END_AT,
										@OPEN_AT,
										@CLOSE_AT,
										IN_WSTE_CLASS,
										IN_PHOTO_LIST,
										IN_NOTE,
										IN_REG_DT,
										@rtn_val,
										@msg_txt
                                    );
                                    IF @rtn_val = 0 THEN
                                    /*데이타 입력작업에 성공한 경우*/
										SET rtn_val = 0;
										SET msg_txt = 'Success';
                                    ELSE
                                    /*데이타 입력작업에 실패한 경우*/
										SET rtn_val = @rtn_val;
										SET msg_txt = @msg_txt;
                                    END IF;
                                ELSE
                                /*프로시저 처리가 실패한 경우 예외처리한다.*/
									SET rtn_val = @rtn_val;
									SET msg_txt = @msg_txt;
                                END IF;
                            ELSE
                            /*입찰종료일을 입력하지 않은 경우에는 예외처리한다.*/
								SET rtn_val = 23007;
								SET msg_txt = CONCAT('No bid end date entered');
                            END IF;
						ELSE
						/*방문종료일이 정책적으로 결정된 기간 이후인 경우에는 예외처리한다.*/
							SET rtn_val = 23006;
							SET msg_txt = CONCAT('The end date of the visit must be within ', @max_visit_duration, ' days from the date of the start of the visit');
						END IF;
					ELSE
					/*방문종료일이 방문시작일 이전인 경우에는 예외처리한다.*/
						SET rtn_val = 23005;
						SET msg_txt = 'The end date of the visit must be after the start date of the visit';
					END IF;
                ELSE
                /*방문종료일이 결정되지 않은 경우*/
					SET rtn_val = 23004;
					SET msg_txt = 'Visit end date not entered';
                END IF;   
            ELSE
            /*방문시작일이 정책적으로 결정된 기간 이후인 경우에는 예외처리한다.*/
				SET rtn_val = 23003;
				SET msg_txt = CONCAT('The start date of the visit must be within ', @max_visit_start, ' days from the date of registration of the bid');
            END IF;
        ELSE
        /*방문시작일이 현재 시점보다 과거인 경우에는 예외처리한다.*/
			SET rtn_val = 23002;
			SET msg_txt = 'The start date of the visit must be after the bid registration date';
        END IF;
    ELSE
    /*방문 시작일이 지정되지 않은 경우*/
		IF IN_VISIT_END_AT IS NOT NULL THEN
		/*방문종료일이 결정된 경우*/
			SET @REF_DATE = IN_VISIT_END_AT;
		ELSE
		/*방문종료일이 결정되지 않은 경우*/
			SET @REF_DATE = IN_REG_DT;
		END IF;    
        
		IF IN_BIDDING_END_AT IS NOT NULL THEN
		/*입찰종료일을 입력한 경우에는 정상처리한다.*/
			CALL sp_req_policy_direction(
				'max_bidding_duration',
				@max_bidding_duration
			);            
            CALL sp_set_bidding_schedule(
				@REF_DATE,
				IN_BIDDING_END_AT,
				CAST(@max_bidding_duration AS UNSIGNED),
				IN_OPEN_AT,
				IN_CLOSE_AT,
				@OPEN_AT,
				@CLOSE_AT,
				@rtn_val,
				@msg_txt
            );
			IF @rtn_val = 0 THEN
			/*프로시저 처리가 성공한 경우*/
				CALL sp_insert_site_wste_discharge_order_to_table(
					IN_USER_ID,
					IN_COLLECTOR_SITE_ID,
					IN_DISPOSER_SITE_ID,
					IN_DISPOSER_TYPE,
					IN_KIKCD_B_CODE,
					IN_ADDR,
					IN_VISIT_START_AT,
					@REF_DATE,
					IN_BIDDING_END_AT,
					@OPEN_AT,
					@CLOSE_AT,
					IN_WSTE_CLASS,
					IN_PHOTO_LIST,
					IN_NOTE,
					IN_REG_DT,
					@rtn_val,
					@msg_txt
				);
				IF @rtn_val = 0 THEN
				/*데이타 입력작업에 성공한 경우*/
					SET rtn_val = 0;
					SET msg_txt = 'Success';
				ELSE
				/*데이타 입력작업에 실패한 경우*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
				END IF;
			ELSE
			/*프로시저 처리가 실패한 경우 예외처리한다.*/
				SET rtn_val = @rtn_val;
				SET msg_txt = @msg_txt;
			END IF;
		ELSE
		/*입찰종료일을 입력하지 않은 경우에는 예외처리한다.*/
			SET rtn_val = 23001;
			SET msg_txt = CONCAT('No bid end date entered');
		END IF;
	END IF;   
END