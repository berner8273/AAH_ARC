-- Populate "UI_INPUT_FIELD_VALUE"
INSERT INTO gui.ui_input_field_value ("UIF_CODE","UIF_TEXT","UIF_DESCRIPTION","UIF_CATEGORY_CODE")
  VALUES ('A','Active','Active','Status');
INSERT INTO gui.ui_input_field_value ("UIF_CODE","UIF_TEXT","UIF_DESCRIPTION","UIF_CATEGORY_CODE")
  VALUES ('I','Inactive','Inactive','Status');
INSERT INTO gui.ui_input_field_value ("UIF_CODE","UIF_TEXT","UIF_DESCRIPTION","UIF_CATEGORY_CODE")
  VALUES ('PREM_COMM','Premium & Commission','Premium & Commission','event_class');
INSERT INTO gui.ui_input_field_value ("UIF_CODE","UIF_TEXT","UIF_DESCRIPTION","UIF_CATEGORY_CODE")
  VALUES ('LOSSES','Losses','Losses','event_class');
INSERT INTO gui.ui_input_field_value ("UIF_CODE","UIF_TEXT","UIF_DESCRIPTION","UIF_CATEGORY_CODE")
  VALUES ('PROFIT_COMM','Profit Commissions','Profit Commissions','event_class');
INSERT INTO gui.ui_input_field_value ("UIF_CODE","UIF_TEXT","UIF_DESCRIPTION","UIF_CATEGORY_CODE")
  VALUES ('CONT_RSRV','Contingency Reserve','Contingency Reserve','event_class');
INSERT INTO gui.ui_input_field_value ("UIF_CODE","UIF_TEXT","UIF_DESCRIPTION","UIF_CATEGORY_CODE")
  VALUES ('OVERHEAD_TAX','Overhead and Premium Tax','Overhead and Premium Tax','event_class');
INSERT INTO gui.ui_input_field_value ("UIF_CODE","UIF_TEXT","UIF_DESCRIPTION","UIF_CATEGORY_CODE")
  VALUES ('OTHERS','Others','Others','event_class');
INSERT INTO gui.ui_input_field_value ("UIF_CODE","UIF_TEXT","UIF_DESCRIPTION","UIF_CATEGORY_CODE")
  VALUES ('O','Open Period','Open Period','open_close');
INSERT INTO gui.ui_input_field_value ("UIF_CODE","UIF_TEXT","UIF_DESCRIPTION","UIF_CATEGORY_CODE")
  VALUES ('C','Closed Period','Closed Period','open_close');
commit;
