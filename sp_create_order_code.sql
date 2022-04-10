CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_create_order_code`(
	IN IN_REG_DT					DATETIME,					/*입력값 : 등록일자*/
    OUT ORDER_CODE 					VARCHAR(10)				/*출력값 : 처리결과 문자열*/
)
BEGIN

/*
Procedure Name 	: sp_create_order_code
Input param 	: 1개
Job 			: 오더 코드를 작성한다.
Update 			: 2022.04.10
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/
    
	SET @str_year = RIGHT(YEAR(IN_REG_DT), 2);
	IF MONTH(IN_REG_DT) < 10 THEN
		SET @str_month = CONCAT('0', MONTH(IN_REG_DT));
	ELSE
		SET @str_month = MONTH(IN_REG_DT);
	END IF;
    
    SET @YEAR_MONTH = CONCAT(@str_year, @str_month);
    SELECT COUNT(ID) INTO @MONTH_COUNT_TEMP
    FROM SITE_WSTE_DISPOSAL_ORDER 
    WHERE 
		YEAR(IN_REG_DT) 	= YEAR(CREATED_AT) AND 
        MONTH(IN_REG_DT) 	= MONTH(CREATED_AT);
        
	SET @MONTH_COUNT = @MONTH_COUNT_TEMP + 1;
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
    SET ORDER_CODE = @ORDER_CODE;
END