CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_comp_name_by_comp_id`(
	IN IN_COMP_ID			BIGINT,
    OUT OUT_COMP_NAME		VARCHAR(100)
)
BEGIN
	SELECT COMP_NAME INTO OUT_COMP_NAME FROM COMPANY WHERE ID = IN_COMP_ID;
END