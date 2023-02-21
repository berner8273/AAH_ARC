
delete from fdr.fr_general_lookup where lk_LKT_LOOKUP_TYPE_CODE = 'MADJ_BALANCE_COLUMNS';
delete from gui.ui_general_lookup where ugl_lkt_lookup_type_code = 'MADJ_BALANCE_COLUMNS';
delete from gui.ui_gen_lookup_type_properties where UGLTP_LOOKUP_TYPE_CODE = 'MADJ_BALANCE_COLUMNS'; 
delete from fdr.fr_general_lookup_type where LKT_LOOKUP_TYPE_CODE = 'MADJ_BALANCE_COLUMNS';


insert into gui.ui_gen_lookup_type_properties(
UGLTP_LOOKUP_TYPE_CODE  , UGLTP_ORDER_EXP_SEARCH, UGLTP_ORDER_EXP_USER, UGLTP_ADD_BUTTON_DISABLED,UGLTP_EDIT_BUTTON_DISABLED,UGLTP_DELETE_BUTTON_DISABLED) values
('MADJ_BALANCE_COLUMNS','LK_MATCH_KEY1 asc','UTGL_MATCH_KEY1 asc','N','N','N');

insert into fdr.fr_general_lookup_aud (
lk_LKT_LOOKUP_TYPE_CODE ,LK_MATCH_KEY1,lk_lookup_value1  ,LK_INPUT_BY    ,LK_AUTH_BY   , LK_ACTIVE )
values ('MADJ_BALANCE_COLUMNS','Affiliate','N','FDR','FDR','A');

insert into fdr.fr_general_lookup_aud (
lk_LKT_LOOKUP_TYPE_CODE ,LK_MATCH_KEY1,lk_lookup_value1  ,LK_INPUT_BY    ,LK_AUTH_BY   , LK_ACTIVE )
values ('MADJ_BALANCE_COLUMNS','Comments','N','FDR','FDR','A');

insert into fdr.fr_general_lookup_type (
LKT_LOOKUP_TYPE_CODE ,lkt_lookup_type_name,LKT_INPUT_BY    ,LKT_AUTH_BY   , LKT_ACTIVE )
values ('MADJ_BALANCE_COLUMNS','Required columns for journal balance','FDR','FDR','A');

insert into fdr.fr_general_lookup (
lk_LKT_LOOKUP_TYPE_CODE ,LK_MATCH_KEY1,lk_lookup_value1  ,LK_INPUT_BY    ,LK_AUTH_BY   , LK_ACTIVE )
values ('MADJ_BALANCE_COLUMNS','Affiliate','N','FDR','FDR','A');

insert into fdr.fr_general_lookup (
lk_LKT_LOOKUP_TYPE_CODE ,LK_MATCH_KEY1,lk_lookup_value1  ,LK_INPUT_BY    ,LK_AUTH_BY   , LK_ACTIVE )
values ('MADJ_BALANCE_COLUMNS','Comments','N','FDR','FDR','A');

delete from gui.ui_field where uf_id >= 4433375 and uf_id  <= 4433399 ;

delete from GUI.UI_COMPONENT where UC_ID = 6000; 

Insert into GUI.UI_COMPONENT
   (UC_ID, UC_SCHEMA_NAME, UC_OBJECT_NAME, UC_OBJECT_ALIAS, UC_FILTER, 
    UC_COLUMN_NAME, UC_DISPLAY_COLUMN_NAME1)
 Values
   (6000, 'GUI', 'UI_INPUT_FIELD_VALUE', 'uif', 'uif.uif_category_code=''balance''', 
    'UIF_CODE', 'UIF_TEXT');


Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433375, 1, 'fdr', 'fr_general_lookup', 'lk', 
    'lk_match_key1', 'MADJ Balance Column', 'T', 40, 0, 
    'Y', 'N', 'N', 1, 1, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433376, 2, 'fdr', 'fr_general_lookup', 'lk', 
    'lk_match_key1', 'MADJ Balance Column', 'T', 40, 0, 
    'Y', 'N', 'N', 1, 1, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH, UF_DEFAULT_VALUE)
 Values
   (4433377, 2, 'fdr', 'fr_general_lookup', 'lk', 
    'lk_lookup_value1', 'Balance Y/N', 'D', 40, 0, 
    'N', 'N', 'Y', 2, 3, 
    6000, 'N', 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_FORMAT_MASK, UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, 
    UF_ORDER, UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433378, 2, 'fdr', 'fr_general_lookup', 'lk', 
    'lk_effective_from', 'Effective From', 'A', 10, 0, 
    'MM-dd-yyyy', 'Y', 'N', 'N', 4, 
    1, 1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_FORMAT_MASK, UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, 
    UF_ORDER, UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433379, 2, 'fdr', 'fr_general_lookup', 'lk', 
    'lk_effective_to', 'Effective To', 'A', 10, 0, 
    'MM-dd-yyyy', 'Y', 'N', 'N', 5, 
    1, 1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433380, 2, 'fdr', 'fr_general_lookup', 'lk', 
    'lk_active', 'Active', 'T', 1, 0, 
    'Y', 'N', 'N', 6, 1, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433381, 3, 'gui', 'ui_temp_general_lookup', 'utgl', 
    'utgl_match_key1', 'MADJ Balance Column', 'T', 40, 0, 
    'Y', 'N', 'N', 1, 1, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH, UF_DEFAULT_VALUE)
 Values
   (4433382, 3, 'gui', 'ui_temp_general_lookup', 'utgl', 
    'utgl_lookup_value1', 'Balance Y/N', 'D', 40, 0, 
    'N', 'N', 'Y', 2, 3, 
    6000, 'N', 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_FORMAT_MASK, UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, 
    UF_ORDER, UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433383, 3, 'gui', 'ui_temp_general_lookup', 'utgl', 
    'utgl_effective_from', 'Effective From', 'A', 10, 0, 
    'MM-dd-yyyy', 'Y', 'N', 'N', 9, 
    1, 1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_FORMAT_MASK, UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, 
    UF_ORDER, UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433384, 3, 'gui', 'ui_temp_general_lookup', 'utgl', 
    'utgl_effective_to', 'Effective To', 'A', 10, 0, 
    'MM-dd-yyyy', 'Y', 'N', 'N', 10, 
    1, 1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433385, 3, 'gui', 'ui_temp_general_lookup', 'utgl', 
    'utgl_active', 'Active', 'T', 1, 0, 
    'Y', 'N', 'N', 11, 1, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433386, 4, 'gui', 'ui_temp_general_lookup', 'utgl', 
    'utgl_match_key1', 'MADJ Balance Column', 'T', 40, 0, 
    'Y', 'N', 'Y', 2, 1, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH, UF_DEFAULT_VALUE)
 Values
   (4433387, 4, 'gui', 'ui_temp_general_lookup', 'utgl', 
    'utgl_lookup_value1', 'Balance Y/N', 'D', 40, 0, 
    'N', 'N', 'Y', 2, 3, 
    6000, 'N', 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_FORMAT_MASK, UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, 
    UF_ORDER, UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433388, 4, 'gui', 'ui_temp_general_lookup', 'utgl', 
    'utgl_effective_from', 'Effective From', 'A', 10, 0, 
    'MM-dd-yyyy', 'Y', 'N', 'Y', 1, 
    1, 1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_FORMAT_MASK, UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, 
    UF_ORDER, UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433389, 4, 'gui', 'ui_temp_general_lookup', 'utgl', 
    'utgl_effective_to', 'Effective To', 'A', 10, 0, 
    'MM-dd-yyyy', 'Y', 'N', 'Y', 1, 
    2, 1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433390, 4, 'gui', 'ui_temp_general_lookup', 'utgl', 
    'utgl_active', 'Active', 'T', 1, 0, 
    'Y', 'N', 'Y', 3, 6, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433391, 5, 'gui', 'fr_general_lookup_aud', 'gla', 
    'utgl_match_key1', 'MADJ Balance Column', 'T', 40, 0, 
    'N', 'N', 'Y', 1, 1, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH, UF_DEFAULT_VALUE)
 Values
   (4433392, 5, 'gui', 'fr_general_lookup_aud', 'gla', 
    'utgl_lookup_value1', 'Balance Y/N', 'D', 40, 0, 
    'N', 'N', 'Y', 2, 3, 
    6000, 'N', 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_FORMAT_MASK, UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, 
    UF_ORDER, UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433393, 5, 'gui', 'fr_general_lookup_aud', 'gla', 
    'utgl_effective_from', 'Effective From', 'A', 10, 0, 
    'MM-dd-yyyy', 'Y', 'N', 'Y', 9, 
    1, 1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_FORMAT_MASK, UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, 
    UF_ORDER, UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433394, 5, 'gui', 'fr_general_lookup_aud', 'gla', 
    'utgl_effective_to', 'Effective To', 'A', 10, 0, 
    'MM-dd-yyyy', 'Y', 'N', 'Y', 10, 
    1, 1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433395, 5, 'gui', 'fr_general_lookup_aud', 'gla', 
    'utgl_active', 'Active', 'T', 1, 0, 
    'Y', 'N', 'Y', 11, 1, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_FORMAT_MASK, UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, 
    UF_ORDER, UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433396, 5, 'gui', 'fr_general_lookup_aud', 'gla', 
    'lk_input_time', 'Input Time', 'A', 20, 0, 
    'MM-dd-yyyy HH:mm:ss', 'Y', 'N', 'N', 10, 
    1, 1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433397, 5, 'gui', 'fr_general_lookup_aud', 'gla', 
    'lk_input_by', 'Input By', 'T', 80, 0, 
    'Y', 'N', 'N', 11, 1, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, UF_ORDER, 
    UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433398, 5, 'gui', 'fr_general_lookup_aud', 'gla', 
    'lk_auth_by', 'Auth By', 'T', 80, 0, 
    'Y', 'N', 'N', 12, 1, 
    1, 'N');
Insert into GUI.UI_FIELD
   (UF_ID, UF_USEC_ID, UF_SCHEMA_NAME, UF_OBJECT_NAME, UF_OBJECT_ALIAS, 
    UF_COLUMN_NAME, UF_LABEL, UF_COLUMN_TYPE, UF_COLUMN_LENGTH, UF_COLUMN_PRECISION, 
    UF_FORMAT_MASK, UF_READONLY, UF_HIDDEN, UF_MANDATORY, UF_COLUMN, 
    UF_ORDER, UF_UC_ID, UF_CHANGE_CAUSES_REFRESH)
 Values
   (4433399, 5, 'gui', 'fr_general_lookup_aud', 'gla', 
    'lk_delete_time', 'Deleted On', 'A', 20, 0, 
    'MM-dd-yyyy HH:mm:ss', 'Y', 'N', 'N', 13, 
    1, 1, 'N');


insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433375,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433376,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433377,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433378,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433379,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433380,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433381,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433382,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433383,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433384,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433385,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433386,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433387,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433388,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433389,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433390,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433391,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433392,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433393,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433394,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433395,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433396,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433397,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433398,'MADJ_BALANCE_COLUMNS');
insert into gui.ui_general_lookup (ugl_uf_id,ugl_lkt_lookup_type_code) values (4433399,'MADJ_BALANCE_COLUMNS');


delete from GUI.UI_INPUT_FIELD_VALUE where UIF_CATEGORY_CODE = 'balance';

Insert into GUI.UI_INPUT_FIELD_VALUE
   (UIF_CODE, UIF_TEXT, UIF_DESCRIPTION, UIF_CATEGORY_CODE)
 Values
   ('N', 'No', 'Balance Y/N', 'balance');
Insert into GUI.UI_INPUT_FIELD_VALUE
   (UIF_CODE, UIF_TEXT, UIF_DESCRIPTION, UIF_CATEGORY_CODE)
 Values
   ('Y', 'Yes', 'Balance Y/N', 'balance');


delete from GUI.UI_GEN_LOOKUP_TYPE_PROPERTIES where UGLTP_LOOKUP_TYPE_CODE = 'MADJ_BALANCE_COLUMNS';

Insert into GUI.UI_GEN_LOOKUP_TYPE_PROPERTIES
   (UGLTP_LOOKUP_TYPE_CODE, UGLTP_ORDER_EXP_SEARCH, UGLTP_ORDER_EXP_USER, UGLTP_ADD_BUTTON_DISABLED, UGLTP_EDIT_BUTTON_DISABLED, 
    UGLTP_DELETE_BUTTON_DISABLED)
 Values
   ('MADJ_BALANCE_COLUMNS', 'LK_MATCH_KEY1 asc', 'UTGL_MATCH_KEY1 asc', 'Y', 'N', 
    'Y');

COMMIT;    







