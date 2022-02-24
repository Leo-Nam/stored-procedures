CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_return_results2`(
	IN IN_RETURN_VALUE			INT,
    IN IN_TXT_MSG				VARCHAR(200),
    IN JSON_DATA				JSON,
    IN JSON_DATA2				JSON
)
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS TEMP_TABLE2 (
		rtn_val				INT,
		msg_txt				VARCHAR(200),
		json_data			JSON,
		json_data2			JSON
	);
	INSERT INTO TEMP_TABLE2 (rtn_val, msg_txt, json_data, json_data2)
	VALUES (IN_RETURN_VALUE, IN_TXT_MSG, JSON_DATA, JSON_DATA2);
	SELECT rtn_val, msg_txt, json_data, json_data2 FROM TEMP_TABLE2;
	DROP TABLE IF EXISTS TEMP_TABLE2;
END