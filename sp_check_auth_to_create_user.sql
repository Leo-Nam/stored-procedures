CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_check_auth_to_create_user`(
	IN IN_TARGET_CLASS		INT,
    IN IN_TARGET_SITE_ID	BIGINT,
    IN IN_CREATOR_CLASS		INT,
    IN IN_CREATOR_SITE_ID	BIGINT,
    OUT OUT_TARGET_COMP_ID	BIGINT,
    OUT rtn_val 			INT,				/*출력값 : 처리결과 반환값*/
    OUT msg_txt 			VARCHAR(200)		/*출력값 : 처리결과 문자열*/
)
BEGIN
	CALL sp_check_if_site_exists(
		IN_TARGET_SITE_ID,
        @rtn_val,
        @msg_txt
    );    
    IF  @rtn_val = 0 THEN
		CALL sp_check_if_site_exists(
			IN_CREATOR_SITE_ID,
			@rtn_val,
			@msg_txt
		);    
		IF  @rtn_val = 0 THEN
			CALL sp_check_if_class_exists(
				IN_CREATOR_CLASS,
				@rtn_val,
				@msg_txt
			);    
			IF  @rtn_val = 0 THEN
				CALL sp_check_if_class_exists(
					IN_TARGET_CLASS,
					@rtn_val,
					@msg_txt
				);    
				IF @rtn_val = 0 THEN
				/*생성하고자 하는 사용자의 CLASS가 유효한 경우 정상처리한다.*/
					SELECT COMP_ID INTO @CREATOR_COMP_ID 
                    FROM COMP_SITE 
                    WHERE ID = IN_CREATOR_SITE_ID;
                    
					SELECT COMP_ID INTO @TARGET_COMP_ID 
                    FROM COMP_SITE 
                    WHERE ID = IN_TARGET_SITE_ID;
                    
					SELECT P_COMP_ID INTO @TARGET_COMP_PID 
                    FROM COMPANY 
                    WHERE ID = @TARGET_COMP_ID;
                    
					SELECT HEAD_OFFICE INTO @CREATOR_SITE_HEAD_OFFICE 
                    FROM COMP_SITE 
                    WHERE ID = IN_CREATOR_SITE_ID;
                    
                    SET OUT_TARGET_COMP_ID = @TARGET_COMP_ID;
					
					IF IN_CREATOR_CLASS = 101 THEN
						IF IN_TARGET_CLASS < 200 THEN
							IF N_TARGET_CLASS = 101 THEN
								SET rtn_val = 31602;
								SET msg_txt = 'Cannot create system superuser';
							ELSE
								SET rtn_val = 0;
								SET msg_txt = 'success01';
							END IF;
						ELSE
							SET rtn_val = 0;
							SET msg_txt = 'success02';
						END IF;
					ELSE
						IF IN_CREATOR_CLASS = 102 THEN
							IF IN_TARGET_CLASS < 200 THEN
								IF IN_TARGET_CLASS > IN_CREATOR_CLASS THEN
									SET rtn_val = 0;
									SET msg_txt = 'success03';
								ELSE
									SET rtn_val = 31603;
									SET msg_txt = 'chium admins cannot create a higher authority than themselves';
								END IF;
							ELSE
								SET rtn_val = 0;
								SET msg_txt = 'success04';
							END IF;
						ELSE
							IF IN_CREATOR_CLASS = 201 OR IN_CREATOR_CLASS = 202 THEN
								IF IN_TARGET_SITE_ID = 0 THEN
									SET rtn_val = 31615;
									SET msg_txt = 'The operator of the business cannot create individual users';
                                ELSE
									IF @CREATOR_COMP_ID = @TARGET_COMP_ID THEN
										IF IN_CREATOR_SITE_ID = IN_TARGET_SITE_ID THEN
											IF IN_TARGET_CLASS > IN_CREATOR_CLASS THEN
												SET rtn_val = 0;
												SET msg_txt = 'success05';
											ELSE
												SET rtn_val = 31609;
												SET msg_txt = 'In the same workplace, only users with lower authority than the creator can be created';
											END IF;
										ELSE
											IF @CREATOR_SITE_HEAD_OFFICE = TRUE THEN
												IF IN_TARGET_CLASS = 201 THEN
													SET rtn_val = 0;
													SET msg_txt = 'success06';
												ELSE
													SET rtn_val = 31611;
													SET msg_txt = 'User rights for other sites that the head office administrator can create are limited to 201';
												END IF;
											ELSE
												SET rtn_val = 31610;
												SET msg_txt = 'Only the head office administrator can create users for other sites';
											END IF;
										END IF;
									ELSE
										IF @TARGET_COMP_PID = @CREATOR_COMP_ID THEN
											IF @CREATOR_SITE_HEAD_OFFICE = TRUE THEN
												IF IN_TARGET_CLASS = 201 THEN
													IF IN_CREATOR_CLASS = 201 THEN
														SET rtn_val = 0;
														SET msg_txt = 'success07';
													ELSE
														SET rtn_val = 31605;
														SET msg_txt = 'Lack of authority to create users in subsidiaries in non-headquarters locations';
													END IF;
												ELSE
													SET rtn_val = 31606;
													SET msg_txt = 'Permission is limited to 201 for users belonging to subsidiaries that can be created in other than the headquarters';
												END IF;
											ELSE
												SET rtn_val = 31607;
												SET msg_txt = 'Subsidiary users cannot be created for business sites other than the headquarters';
											END IF;
										ELSE
											SET rtn_val = 31608;
											SET msg_txt = 'impossible to create a user belonging to a business other than a subsidiary';
										END IF;
									END IF;
                                END IF;
							ELSE
								SET rtn_val = 31604;
								SET msg_txt = 'Business general manager cannot create users';
							END IF;
						END IF;
					END IF;
				ELSE
				/*생성하고자 하는 사용자의 CLASS가 유효하지 않은 경우 예외처리한다.*/
					SET rtn_val = @rtn_val;
					SET msg_txt = @msg_txt;
				END IF;
			ELSE
				IF IN_TARGET_CLASS = 201 THEN
					IF IN_TARGET_SITE_ID = 0 THEN
						SET rtn_val = 0;
						SET msg_txt = 'success08';
                    ELSE
						SET rtn_val = 31612;
						SET msg_txt = 'The site to which an individual user belongs must be 0';
                    END IF;
                ELSE
					SET rtn_val = 31616;
					SET msg_txt = 'Permissions for individual users must be 201';
                END IF;
			END IF;
		ELSE
			SET rtn_val = @rtn_val;
			SET msg_txt = @msg_txt;
		END IF;
    ELSE
		SET rtn_val = @rtn_val;
		SET msg_txt = @msg_txt;
    END IF;
END