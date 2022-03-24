CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_site_wste_discharge_order_to_table`(
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
	IN IN_LAT						DECIMAL(12,9),				/*입렦값 : 폐기물 발생지 위도값*/
	IN IN_LNG						DECIMAL(12,9),				/*입렦값 : 폐기물 발생지 경도값*/
	IN IN_REG_DT					DATETIME,					/*입력값 : 등록일자*/
    OUT rtn_val 					INT,						/*출력값 : 처리결과 반환값*/
    OUT msg_txt 					VARCHAR(200)				/*출력값 : 처리결과 문자열*/
)
BEGIN

	CALL sp_req_policy_direction(
		'max_selection_duration',
		@max_selection_duration
	);
/*    
	배출자가 최종 낙찰예정이 되는 수거자를 선택할 수 있는 권한이 없도록 조치함으로써 아래 코딩을 주석처리하고 
    @MAX_SELECT_AT과 @MAX_SELECT2_AT을 IN_BIDDING_END_AT과 같은 값으로 처리함
    SET @MAX_SELECT_AT = ADDTIME(IN_BIDDING_END_AT, CONCAT(CAST(@max_selection_duration AS UNSIGNED), ':00:00'));
    SET @MAX_SELECT2_AT = ADDTIME(IN_BIDDING_END_AT, CONCAT(CAST(@max_selection_duration AS UNSIGNED)*2, ':00:00'));
	SET @COLLECTOR_MAX_DECISION_AT = ADDTIME(@MAX_SELECT_AT, CONCAT(CAST(@max_selection_duration AS UNSIGNED), ':00:00'));
	SET @COLLECTOR_MAX_DECISION2_AT = ADDTIME(@MAX_SELECT2_AT, CONCAT(CAST(@max_selection_duration AS UNSIGNED), ':00:00'));
*/
    SET @MAX_SELECT_AT = IN_BIDDING_END_AT;
    SET @MAX_SELECT2_AT = IN_BIDDING_END_AT;
	SET @COLLECTOR_MAX_DECISION_AT = ADDTIME(@MAX_SELECT_AT, CONCAT(CAST(@max_selection_duration AS UNSIGNED), ':00:00'));
	SET @COLLECTOR_MAX_DECISION2_AT = ADDTIME(@MAX_SELECT2_AT, CONCAT(CAST(@max_selection_duration AS UNSIGNED)*2, ':00:00'));
	INSERT INTO SITE_WSTE_DISPOSAL_ORDER(
		DISPOSER_ID,
		COLLECTOR_ID,
		SITE_ID,
		DISPOSER_TYPE,
		ACTIVE,
		VISIT_START_AT,
		VISIT_END_AT,
		BIDDING_END_AT,
		OPEN_AT,
		CLOSE_AT,
		SERVICE_INSTRUCTION_ID,
		ORDER_CODE,
		NOTE,
		CREATED_AT,
		UPDATED_AT,
		KIKCD_B_CODE,
		MAX_SELECT_AT,
		MAX_SELECT2_AT,
        LAT,
        LNG,
        ADDR,
        COLLECTOR_MAX_DECISION_AT,
        COLLECTOR_MAX_DECISION2_AT
	) VALUES(
		IN_USER_ID,
		IN_COLLECTOR_SITE_ID,
		IN_DISPOSER_SITE_ID,
		IN_DISPOSER_TYPE,
		TRUE,
		IN_VISIT_START_AT,
		IN_VISIT_END_AT,
		IN_BIDDING_END_AT,
		IN_OPEN_AT,
		IN_CLOSE_AT,
		@SERVICE_INSTRUCTION_ID,
		@ORDER_CODE,
		IN_NOTE,
		IN_REG_DT,
		IN_REG_DT,
        IN_KIKCD_B_CODE,
        @MAX_SELECT_AT,
        @MAX_SELECT2_AT,
        IN_LAT,
        IN_LNG,
        IN_ADDR,
        @MAX_SELECT_AT,
        @MAX_SELECT2_AT
	);
	
    SELECT LAST_INSERT_ID() INTO @WSTE_DISPOSAL_ORDER_ID;
    /*직전 INSERT 작업에서 AUTO INCREMENT로 생성된 최종 ID를 반환한다.*/
    
	IF ROW_COUNT() = 1 THEN
	/*자료 등록작업에 성공한 경우에는 후속작업을 정상진행한다.*/
		CALL sp_req_policy_direction(
			'min_disposal_duration',
			@min_disposal_duration
		);
		SET @ASK_DISPOSAL_END_AT = DATE_ADD(IN_OPEN_AT, INTERVAL @min_disposal_duration DAY);
		CALL sp_insert_clct_trmt_transaction(
		/*폐기물배출작업을 생성한다.*/
			IN_USER_ID,
			@WSTE_DISPOSAL_ORDER_ID,
            IN_VISIT_START_AT,
            IN_VISIT_END_AT,
            @ASK_DISPOSAL_END_AT,
            @rtn_val,
            @msg_txt
		);
		IF @rtn_val = 0 THEN
        /*폐기물배출작업 생성에 성공한 경우*/
        
			CALL sp_create_site_wste_discharged(
			/*처리할 폐기물 목록을 저장한다.*/
				@WSTE_DISPOSAL_ORDER_ID,
				IN_REG_DT,
				IN_WSTE_CLASS,
				@rtn_val,
				@msg_txt
			);
			IF @rtn_val = 0 THEN
			/*폐기물 종류 목록 등록에 성공한 경우*/
				CALL sp_create_site_wste_photo_information(
				/*폐기물 사진을 등록한다.*/
					@WSTE_DISPOSAL_ORDER_ID,
					IN_REG_DT,
					'입찰',
					IN_PHOTO_LIST,
					@rtn_val,
					@msg_txt
				);
				IF @rtn_val = 0 THEN
				/*폐기물 사진 등록에 성공한 경우*/
					SET rtn_val = 0;
					SET msg_txt = 'Success';
				ELSE
				/*폐기물 사진 등록에 실패한 경우 예외처리한다.*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
				END IF;
			ELSE
			/*폐기물 종류 목록 등록에 실패한 경우 예외처리한다.*/
				SET rtn_val = @rtn_val;
				SET msg_txt = @msg_txt;
			END IF;
        ELSE
        /*폐기물배출작업 생성에 실패한 경우 예외처리한다.*/
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt;
        END IF;
	ELSE
	/*자료 등록작업에 실패한 경우에는 예외처리한다.*/
		SET rtn_val = 30901;
		SET msg_txt = 'Failed to enter waste discharge data';
	END IF;

END