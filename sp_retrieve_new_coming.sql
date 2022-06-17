CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_retrieve_new_coming`(
	IN IN_USER_ID							BIGINT,
    IN IN_OFFSET_SIZE						INT,
    IN IN_PAGE_SIZE							INT
)
BEGIN

/*
Procedure Name 	: sp_retrieve_new_coming
Input param 	: 1개
Job 			: 수거자의 사업지역의 신규입찰건에 대한 리스트를 반환한다.
Update 			: 2022.02.10
Version			: 0.0.3
AUTHOR 			: Leo Nam
Change			: 기존거래를 위한 칼럼(SITE_WSTE_DISPOSAL_ORDER.COLLECTOR_ID)을 추가함으로써 이 칼럼의 값이 NULL인 경우에만 신규입찰이 되며 NULL이 아닌것은 기존거래로서 기존 업체의 나의 활동에 자동으로 등록됨(0.0.2)
*/
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET @json_data 		= NULL;
		CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
	END;        
	START TRANSACTION;							
    /*트랜잭션 시작*/  
	CALL sp_req_policy_direction(
		'include_wste_condition',
		@include_wste_condition
	);
    CALL sp_retrieve_new_coming_without_handler(
		IN_USER_ID,
        IN_OFFSET_SIZE,
        IN_PAGE_SIZE,
        @include_wste_condition,
        @rtn_val,
        @msg_txt,
        @json_data
    );
    IF @rtn_val > 0 THEN
		SIGNAL SQLSTATE '23000';
    END IF;
    COMMIT;
	CALL sp_return_results(@rtn_val, @msg_txt, @json_data);
END