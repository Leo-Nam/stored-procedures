CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_insert_sigungu`(
	IN IN_SITE_ID		INT,
	IN IN_SIGUNGU_CODE	VARCHAR(10),
	IN IN_DEFAULT		TINYINT,
	IN IN_REG_DT		DATETIME,
    OUT rtn_val			INT
)
BEGIN
	SELECT COUNT(ID) INTO @SIGUNGU_COUNT
    FROM BUSINESS_AREA
    WHERE 
		SITE_ID = IN_SITE_ID AND
        KIKCD_B_CODE = IN_SIGUNGU_CODE;
        
	IF @SIGUNGU_COUNT = 0 THEN
		INSERT INTO BUSINESS_AREA(
			SITE_ID,
            KIKCD_B_CODE,
            IS_DEFAULT,
            CREATED_AT
		) VALUES (
			IN_SITE_ID,
            IN_SIGUNGU_CODE,
            IN_DEFAULT,
            IN_REG_DT
		);
        IF ROW_COUNT() = 1 THEN
			SET rtn_val = 0;
        ELSE
			SET rtn_val = 1;
        END IF;
    ELSE
		SET rtn_val = 1;
    END IF;
END