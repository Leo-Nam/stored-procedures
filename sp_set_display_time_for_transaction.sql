CREATE DEFINER=`chiumdb`@`%` PROCEDURE `sp_set_display_time_for_transaction`(
	IN IN_TRANSACTION_ID			BIGINT,
	IN IN_STATE_CODE				INT,
    OUT OUT_DISPLAY_TIME			DATETIME
)
BEGIN
	SELECT 
	CASE
		WHEN IN_STATE_CODE = 201
			THEN (
				SELECT VISIT_END_AT
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE ID = IN_TRANSACTION_ID
			)
		WHEN IN_STATE_CODE = 217
			THEN (
				SELECT VISIT_END_AT
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE ID = IN_TRANSACTION_ID
			)
		WHEN IN_STATE_CODE = 221
			THEN (
				SELECT COLLECTOR_REPORTED_AT
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE ID = IN_TRANSACTION_ID
			)
		WHEN IN_STATE_CODE = 247
			THEN (
				SELECT COLLECTOR_REPORTED_AT
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE ID = IN_TRANSACTION_ID
			)
		WHEN IN_STATE_CODE = 248
			THEN (
				SELECT CONFIRMED_AT
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE ID = IN_TRANSACTION_ID
			)
		WHEN IN_STATE_CODE = 246
			THEN (
				SELECT CONFIRMED_AT
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE ID = IN_TRANSACTION_ID
			)
		WHEN IN_STATE_CODE = 250
			THEN (
				SELECT MAX_DECISION_AT
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE ID = IN_TRANSACTION_ID
			)
		WHEN IN_STATE_CODE = 251
			THEN (
				SELECT ACCEPT_ASK_END_AT
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE ID = IN_TRANSACTION_ID
			)
		WHEN IN_STATE_CODE = 252
			THEN (
				SELECT MAX_DECISION_AT
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE ID = IN_TRANSACTION_ID
			)
		ELSE
			(
				SELECT UPDATED_AT
				FROM WSTE_CLCT_TRMT_TRANSACTION
				WHERE ID = IN_TRANSACTION_ID
			)
	END INTO OUT_DISPLAY_TIME;
END