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
Update 			: 2022.03.18
Version			: 0.0.4
AUTHOR 			: Leo Nam
Change			: 반환 타입은 레코드를 사용하기로 함. 모든 프로시저에 공통으로 적용(0.0.3)
				: 방문취소가 실행된 경우 전체 방문가능자수를 계산하여 SITE_WSTE_DISPOSAL_ORDER.PROSPECTIVE_VISITORS를 UPDATE한다.(0.0.4)
				
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
			SELECT COUNT(ID) INTO @ITEM_COUNT 
            FROM COLLECTOR_BIDDING 
            WHERE 
				ID 				= IN_COLLECT_BIDDING_ID AND 
                DATE_OF_VISIT 	IS NOT NULL;
            /*수거자가 방문신청을 한 사실이 있는지 확인하여 그 결과를 @TEMP_COUNT에 반환한다*/
            IF @ITEM_COUNT = 1 THEN
            /*수거자가 방문신청을 한 사실이 존재하는 경우 정상처리한다.*/
				SELECT COUNT(ID) INTO @IS_ALREADY_CANCELED 
                FROM COLLECTOR_BIDDING 
                WHERE 
					ID 				= IN_COLLECT_BIDDING_ID AND 
                    CANCEL_VISIT 	= TRUE;
				/*수거자가 자신의 방문신청에 대하여 방문취소한 사실이 있는지 확인하여 그 결과를 @IS_ALREADY_CANCELED 반환한다. 방문취소한 사실이 존재하는 경우 1, 그렇지 않으면 0*/
                IF @IS_ALREADY_CANCELED = 0 THEN
				/*수거자가 자신의 방문신청에 대하여 방문취소한 사실이 존재하지 않는 경우 정상처리한다.*/
					SELECT RESPONSE_VISIT INTO @EMITTOR_RESPONSE_FOR_VISIT 
                    FROM COLLECTOR_BIDDING 
                    WHERE ID = IN_COLLECT_BIDDING_ID;
                    /*배출자가 수거자의 방문신청에 대한 수락 또는 거절의사를 확인하여 그 결과를 @EMITTOR_RESPONSE_FOR_VISIT에 반환한다.*/
                    IF @EMITTOR_RESPONSE_FOR_VISIT IS NULL THEN
                    /*배출자가 수거업체의 방문신청에 대하여 수락 또는 거절의사를 표시하지 않은 대기상태인 경우*/
						UPDATE COLLECTOR_BIDDING 
						SET 
							CANCEL_VISIT 		= TRUE, 
							CANCEL_VISIT_AT 	= @REG_DT, 
							UPDATED_AT		 	= @REG_DT 
						WHERE ID = IN_COLLECT_BIDDING_ID;
						/*방문신청을 취소상태(비활성상태)로 변경한다.*/
						IF ROW_COUNT() = 1 THEN
						/*데이타베이스 입력에 성공한 경우*/
							SELECT COUNT(ID) INTO @PROSPECTIVE_VISITORS 
							FROM COLLECTOR_BIDDING 
							WHERE 
								DISPOSAL_ORDER_ID 		= @DISPOSAL_ORDER_ID AND 
								DATE_OF_VISIT 			IS NOT NULL AND
								CANCEL_VISIT 			= FALSE AND
								RESPONSE_VISIT 			= TRUE;
							UPDATE SITE_WSTE_DISPOSAL_ORDER 
                            SET 
								PROSPECTIVE_VISITORS 	= @PROSPECTIVE_VISITORS, 
								UPDATED_AT		 		= @REG_DT  
                            WHERE ID = @DISPOSAL_ORDER_ID;
							CALL sp_push_cancel_visit(
								IN_COLLECT_BIDDING_ID,
								@PUSH_INFO
							);
							SELECT JSON_ARRAYAGG(
								JSON_OBJECT(
									'PUSH_INFO'	, @PUSH_INFO
								)
							) INTO @json_data;
							SET @rtn_val 		= 0;
							SET @msg_txt 		= 'Success';
						ELSE
						/*데이타베이스 입력에 실패한 경우*/
							SET @rtn_val 		= 25606;
							SET @msg_txt 		= 'record cancellation error';
							SIGNAL SQLSTATE '23000';
						END IF;
                    ELSE
                    /*배출자가 수거업체의 방문신청에 대하여 수락 또는 거절의사를 표시한 경우*/
						IF @EMITTOR_RESPONSE_FOR_VISIT <> 0 THEN
						/*배출자가 수거자의 방문신청에 대하여 거절의사를 밝힌 경우가 아닌 경우에는 정상처리한다.*/
							UPDATE COLLECTOR_BIDDING 
							SET 
								CANCEL_VISIT 			= TRUE, 
								CANCEL_VISIT_AT 		= @REG_DT, 
								UPDATED_AT		 		= @REG_DT   
							WHERE ID = IN_COLLECT_BIDDING_ID;
							/*방문신청을 취소상태(비활성상태)로 변경한다.*/
							IF ROW_COUNT() = 1 THEN
							/*데이타베이스 입력에 성공한 경우*/
								SELECT COUNT(ID) INTO @PROSPECTIVE_VISITORS 
								FROM COLLECTOR_BIDDING 
								WHERE 
									DISPOSAL_ORDER_ID 		= @DISPOSAL_ORDER_ID AND 
									DATE_OF_VISIT 			IS NOT NULL AND
									CANCEL_VISIT 			= FALSE AND
									RESPONSE_VISIT 			= TRUE;
								UPDATE SITE_WSTE_DISPOSAL_ORDER 
                                SET 
									PROSPECTIVE_VISITORS 	= @PROSPECTIVE_VISITORS , 
									UPDATED_AT		 		= @REG_DT
                                WHERE ID = @DISPOSAL_ORDER_ID;
								CALL sp_push_cancel_visit(
									IN_COLLECT_BIDDING_ID,
									@PUSH_INFO
								);
								SELECT JSON_ARRAYAGG(
									JSON_OBJECT(
										'PUSH_INFO'	, @PUSH_INFO
									)
								) INTO @json_data;
								SET @rtn_val 		= 0;
								SET @msg_txt 		= 'Success';
							ELSE
							/*데이타베이스 입력에 실패한 경우*/
								SET @rtn_val 		= 25601;
								SET @msg_txt 		= 'record cancellation error';
								SIGNAL SQLSTATE '23000';
							END IF;
						ELSE
						/*배출자가 수거자의 방문신청에 대하여 거절의사를 이미 밝힌 경우에는 정상처리한다.*/
							SET @rtn_val 		= 25605;
							SET @msg_txt 		= 'The emitter has already refused to visit';
							SIGNAL SQLSTATE '23000';
						END IF;
                    END IF;
                ELSE
				/*수거자가 자신의 방문신청에 대하여 방문취소한 사실이 존재하는 경우 예외처리한다.*/
					SET @rtn_val 		= 25604;
					SET @msg_txt 		= 'The collector has already canceled the visit';
					SIGNAL SQLSTATE '23000';
                END IF;
            ELSE
            /*수거자가 방문신청을 한 사실이 존재하지 않는 경우 예외처리한다.*/
				SET @rtn_val 		= 25603;
				SET @msg_txt 		= 'No fact that the collector has requested a visit';
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
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END