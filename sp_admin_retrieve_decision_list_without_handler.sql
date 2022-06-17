CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_admin_retrieve_decision_list_without_handler`(
    OUT DECISION_LIST			JSON
)
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
			'ID'			, id, 
            'TITLE'			, title, 
            'DATA_TYPE'		, data_type, 
            'DIRECTION'		, direction
		)
	) INTO DECISION_LIST
    FROM sys_policy
    WHERE active = true;  
END