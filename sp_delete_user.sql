CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_delete_user`(
    IN IN_USER_ID						BIGINT,				/*입력값 : 계정 정보를 삭제하는 사용자 아이디*/
    IN IN_TARGET_USER_ID				BIGINT				/*입력값 : 삭제할 사용자 아이디*/
)
BEGIN

/*
Procedure Name 	: sp_delete_user
Input param 	: 2개
Job 			: 개인정보를 삭제하는 기능
Update 			: 2022.01.29
Version			: 0.0.3
AUTHOR 			: Leo Nam
*/

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
    
    CALL sp_req_current_time(
		@REG_DT
    );
    
    call sp_req_user_exists_by_id(
		IN_USER_ID, 
        TRUE,
        @rtn_val, 
        @msg_txt
    );
    IF @rtn_val = 0 THEN
    /*요청자가 인증된 사용자인 경우*/ 
		call sp_req_user_exists_by_id(
			IN_TARGET_USER_ID, 
			TRUE,
			@rtn_val, 
			@msg_txt
		);
		
		IF @rtn_val = 0 THEN
		/*삭제 대상자가 인증된 사용자인 경우*/ 
			SELECT AFFILIATED_SITE, CLASS INTO @USER_SITE_ID, @USER_CLASS
			FROM USERS
			WHERE 
				ID = IN_USERS_ID AND
				ACTIVE = TRUE;
				
			SELECT AFFILIATED_SITE, CLASS INTO @TARGET_USER_SITE_ID, @TARGET_USER_CLASS
			FROM USERS
			WHERE 
				ID = IN_TARGET_USER_ID AND
				ACTIVE = TRUE;
                
			IF IN_USER_ID = IN_TARGET_USER_ID THEN
			/*사용자와 삭제대상 사용자가 동일인인 경우*/			
				IF @USER_SITE_ID = @TARGET_USER_SITE_ID THEN
				/*삭제자와 삭제대상자의 사이트가 동일한 경우 정상처리한다.*/
					SELECT COUNT(ID) INTO @COUNT_OF_USERS
					FROM USERS
					WHERE AFFILIATED_SITE = @USER_SITE_ID;
					
					IF @COUNT_OF_USERS = 1 THEN
					/*사이트에 소속하고 있는 활성 사용자가 1인인 경우*/
						CALL sp_delete_user_without_handler(
							IN_TARGET_USER_ID,
							@REG_DT,
							@rtn_val,
							@msg_txt
						);
						IF @rtn_val = 0 THEN
						/*사용자 삭제에 성공한 경우 정상처리한다.*/
							CALL sp_delete_site_without_handler(
								@USER_SITE_ID,
								@REG_DT,
								@rtn_val,
								@msg_txt
							);
							IF @rtn_val = 0 THEN
							/*사이트 삭제에 성공한 경우 정상처리한다.*/
								CALL sp_delete_company_without_handler_2(
									@USER_COMP_ID,
									@REG_DT,
									@rtn_val,
									@msg_txt
								);
								IF @rtn_val = 0 THEN
								/*사업자 삭제에 성공한 경우 정상처리한다.*/
									SELECT HEAD_OFFICE, COMP_ID INTO @HEAD_OFFICE, @USER_COMP_ID
									FROM COMP_SITE
									WHERE ID = @USER_SITE_ID;
									IF @HEAD_OFFICE = FALSE THEN
									/*현재 소속 사이트가 HEAD OFFICE가 아닌 경우 종료처리한다*/
										SET @rtn_val = 0;
										SET @msg_txt = 'Success';
									ELSE
									/*현재 소속 사이트가 HEAD OFFICE인 경우*/
										SELECT COUNT(ID) INTO @COUNT_OF_NO_HEAD_OFFICE
										FROM COMP_SITE
										WHERE COMP_ID = @USER_COMP_ID;
										IF @COUNT_OF_NO_HEAD_OFFICE = 0 THEN
										/*동일한 사업자에서 파생된 다른 사이트가 존재하지 않는 경우 정상처리한다.*/
											SELECT P_COMP_ID INTO @P_COMP_ID
											FROM COMPANY
											WHERE ID = @USER_COMP_ID;
											IF @P_COMP_ID > 0 THEN
											/*현재 소속 사업자가 모회사가 아닌 경우 종료처리한다.*/
												SET @rtn_val = 0;
												SET @msg_txt = 'Success';
											ELSE
											/*현재 소속 사업자가 모회사인 경우*/
												SELECT COUNT(ID) INTO @COUNT_OF_CHILD_COMPANY
												FROM COMPANY
												WHERE P_COMP_ID = @USER_COMP_ID;
												IF @COUNT_OF_CHILD_COMPANY = 0 THEN
												/*사용자가 소속한 사업자를 모회사로 하는 종속사업자가 존재하지 않는 경우 종료처리한다.*/
													SET @rtn_val = 0;
													SET @msg_txt = 'Success';
												ELSE
												/*사용자가 소속한 사업자를 모회사로 하는 종속사업자가 존재하는 경우 예외처리한다.*/
													SET @rtn_val = 26705;
													SET @msg_txt = 'Non-deletion of parent company with subsidiaries';
													SIGNAL SQLSTATE '23000';
												END IF;
											END IF;
										ELSE
										/*동일한 사업자에서 파생된 다른 사이트가 존재하는 경우 종료처리한다.*/
											SET @rtn_val = 0;
											SET @msg_txt = 'Success';
										END IF;
									END IF;
								ELSE
								/*사업자 삭제에 실패한 경우 예외처리한다.*/
									SIGNAL SQLSTATE '23000';
								END IF;
							ELSE
							/*사이트 삭제에 실패한 경우 예외처리한다.*/
								SIGNAL SQLSTATE '23000';
							END IF;
						ELSE
						/*사용자 삭제에 실패한 경우 예외처리한다.*/
							SIGNAL SQLSTATE '23000';
						END IF;
					ELSE
					/*사이트에 소속하고 있는 활성 사용자가 1인 이상인 경우*/
						IF @USER_CLASS > 201 THEN
                        /*최고권한자가 아닌 경우에는 정상처리한다.*/
							CALL sp_delete_user_without_handler(
								IN_TARGET_USER_ID,
								@REG_DT,
								@rtn_val,
								@msg_txt
							);
							IF @rtn_val = 0 THEN
							/*사용자 삭제에 성공한 경우 종료처리한다.*/
								SET @rtn_val = 0;
								SET @msg_txt = 'Success';
							ELSE
							/*사용자 삭제에 실패한 경우 예외처리한다.*/
								SIGNAL SQLSTATE '23000';
							END IF;
                        ELSE
                        /*최고권한자인 경우에는 예외처리한다.*/
							SET @rtn_val = 26704;
							SET @msg_txt = 'If a general user exists, the super user cannot be deleted';
							SIGNAL SQLSTATE '23000';
                        END IF;
					END IF;
				ELSE
				/*삭제자와 삭제대상자의 사이트가 동일하지 않은 경우 예외처리한다.*/
					SET @rtn_val = 26703;
					SET @msg_txt = 'Non-deletion of parent company with subsidiaries';
					SIGNAL SQLSTATE '23000';
				END IF;
			ELSE
			/*사용자와 삭제대상 사용자가 동일인이 아닌 경우*/
				IF @USER_SITE_ID = @TARGET_USER_SITE_ID THEN
                /*사용자 사이트와 삭제 대상 사용자의 사이트가 동일한 경우*/
					IF @USER_CLASS < @TARGET_USER_CLASS THEN
                    /*사용자가 다른 사용자를 삭제할 권한이 있는 경우 정상처리한다.*/
						CALL sp_delete_user_without_handler(
							IN_TARGET_USER_ID,
							@REG_DT,
							@rtn_val,
							@msg_txt
						);
						IF @rtn_val = 0 THEN
						/*사용자 삭제에 성공한 경우 종료처리한다.*/
							SET @rtn_val = 0;
							SET @msg_txt = 'Success';
                        ELSE
						/*사용자 삭제에 실패한 경우 예외처리한다.*/
							SIGNAL SQLSTATE '23000';
						END IF;
                    ELSE
                    /*사용자가 다른 사용자를 삭제할 권한이 없는 경우 예외처리한다.*/
						SET @rtn_val = 26702;
						SET @msg_txt = 'No permission to delete other users';
						SIGNAL SQLSTATE '23000';
                    END IF;
                ELSE
                /*사용자 사이트와 삭제 대상 사용자의 사이트가 동일하지 않은 경우 예외처리한다.*/
					SET @rtn_val = 26701;
					SET @msg_txt = 'Cannot delete users from other sites';
					SIGNAL SQLSTATE '23000';
                END IF;
			END IF;
		ELSE 
		/*삭제 대상자가 인증되지 않은 사용자인 경우*/  
			SIGNAL SQLSTATE '23000';
		END IF;
    ELSE   
    /*요청자가 인증되지 않은 사용자인 경우*/
		SIGNAL SQLSTATE '23000';
	END IF;
	COMMIT;
	SET @json_data 		= NULL;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END