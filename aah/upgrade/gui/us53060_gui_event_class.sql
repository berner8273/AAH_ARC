delete from GUI.UI_INPUT_FIELD_VALUE where UIF_CODE = 'CASH_TXN';
INSERT INTO GUI.UI_INPUT_FIELD_VALUE (
   UIF_CODE, UIF_TEXT, UIF_DESCRIPTION, 
   UIF_CATEGORY_CODE) 
VALUES ('CASH_TXN',
 'Cash Transactions',
 'Cash Transactions',
 'event_class' );
commit;
delete from GUI.UI_INPUT_FIELD_VALUE where UIF_CODE = 'MANUAL_ADJ';
INSERT INTO GUI.UI_INPUT_FIELD_VALUE (
   UIF_CODE, UIF_TEXT, UIF_DESCRIPTION, 
   UIF_CATEGORY_CODE) 
VALUES ('MANUAL_ADJ',
 'Manual Adjustments',
 'Manual Adjustments',
 'event_class' );
commit;
   
