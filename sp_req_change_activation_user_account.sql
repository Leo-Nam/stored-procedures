CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_change_activation_user_account`(
	IN IN_USER_ID				BIGINT,
    IN IN_REG_AT				DATETIME,
    IN IN_ACTIVE				TINYINT,
    OUT rtn_val					INT,
    OUT msg_txt					VARCHAR(200)
)
BEGIN
	UPDATE USERS 
	SET 
		ACTIVE = FALSE, 
		UPDATED_AT = IN_REG_AT
	WHERE ID = IN_USER_ID;
		
	IF ROW_COUNT() = 0 THEN
	/*변경이 적용되지 않은 경우*/
		SET @rtn_val = 33001;
		SET @msg_txt = 'Failed to delete user account';
		SIGNAL SQLSTATE '23000';
	ELSE
	/*모든 트랜잭션이 성공한 경우에만 로그를 한다.*/
		SET @rtn_val = 0;
		SET @msg_txt = 'Success';
	END IF;

END