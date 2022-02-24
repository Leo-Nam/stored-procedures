CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_req_wste_class`()
BEGIN

/*
Procedure Name 	: sp_req_wste_class
Input param 	: 0개
Output param 	: 0개
Job 			: 폐기물의 대분류를 레코드로 반환함
Update 			: 2022.01.18
Version			: 0.0.1
AUTHOR 			: Leo Nam
*/

    SELECT ID, CLASS_NAME FROM WSTE_CLS_1 WHERE ACTIVE = TRUE ORDER BY ID;
END