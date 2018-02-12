-- Populate "UI_COMPONENT"
INSERT INTO gui.ui_component ("UC_ID","UC_SCHEMA_NAME","UC_OBJECT_NAME","UC_OBJECT_ALIAS","UC_FILTER","UC_COLUMN_NAME","UC_DISPLAY_COLUMN_NAME1","UC_DISPLAY_COLUMN_NAME2","UC_DISPLAY_COLUMN_NAME3","UC_DEFAULT_VALUE")
  VALUES (1,'DEFAULT','DEFAULT','DEFAULT',NULL,'DEFAULT','DEFAULT',NULL,NULL,NULL);
INSERT INTO gui.ui_component ("UC_ID","UC_SCHEMA_NAME","UC_OBJECT_NAME","UC_OBJECT_ALIAS","UC_FILTER","UC_COLUMN_NAME","UC_DISPLAY_COLUMN_NAME1","UC_DISPLAY_COLUMN_NAME2","UC_DISPLAY_COLUMN_NAME3","UC_DEFAULT_VALUE")
  VALUES (-1,'FDR','FR_GENERAL_LOOKUP_TYPE','fglt','fglt.LKT_ACTIVE=''A''','LKT_LOOKUP_TYPE_CODE','LKT_LOOKUP_TYPE_NAME',NULL,NULL,NULL);
INSERT INTO gui.ui_component ("UC_ID","UC_SCHEMA_NAME","UC_OBJECT_NAME","UC_OBJECT_ALIAS","UC_FILTER","UC_COLUMN_NAME","UC_DISPLAY_COLUMN_NAME1","UC_DISPLAY_COLUMN_NAME2","UC_DISPLAY_COLUMN_NAME3","UC_DEFAULT_VALUE")
  VALUES (2,'GUI','UI_INPUT_FIELD_VALUE','uif','uif.uif_category_code=''event_class''','UIF_CODE','UIF_TEXT',NULL,NULL,NULL);
INSERT INTO gui.ui_component ("UC_ID","UC_SCHEMA_NAME","UC_OBJECT_NAME","UC_OBJECT_ALIAS","UC_FILTER","UC_COLUMN_NAME","UC_DISPLAY_COLUMN_NAME1","UC_DISPLAY_COLUMN_NAME2","UC_DISPLAY_COLUMN_NAME3","UC_DEFAULT_VALUE")
  VALUES (3,'GUI','UI_INPUT_FIELD_VALUE','uif','uif.uif_category_code=''open_close''','UIF_CODE','UIF_TEXT',NULL,NULL,NULL);
