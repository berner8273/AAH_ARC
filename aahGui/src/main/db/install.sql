-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which are involved in standardisation.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~
set echo on

define fdr_logon=~1
define gui_logon=~2
define rdr_logon=~3
define sla_logon=~4
define slr_logon=~5
define stn_logon=~6
define sys_logon=~7
define unittest_login=~8

conn ~gui_logon

@@data/gui/t_ui_jrnl_line_meta.sql
@@data/gui/t_ui_roles.sql
@@data/gui/t_ui_role_tasks.sql

delete from gui.ui_general_lookup;
delete from gui.ui_input_field_value;
delete from gui.ui_field;
delete from gui.ui_section;
delete from gui.ui_screen;
delete from gui.ui_component;
delete from gui.ui_gen_lookup_type_properties;

@@data/gui/ui_gen_lookup_type_properties.sql
@@data/gui/ui_component.sql
@@data/gui/ui_screen.sql
@@data/gui/ui_section.sql
@@data/gui/ui_field.sql
@@data/gui/ui_input_field_value.sql
@@data/gui/ui_general_lookup.sql
update gui.t_ui_gui_parameters set guiparam_value = '25000' where guiparam_name = 'data.max.rows.returned';
commit;

@@views/gui/vw_ui_attribute_1.sql
@@views/gui/vw_ui_attribute_1_val_to_lkp.sql
@@views/gui/vw_ui_attribute_2.sql
@@views/gui/vw_ui_attribute_2_val_to_lkp.sql
@@views/gui/vw_ui_attribute_3.sql
@@views/gui/vw_ui_attribute_3_val_to_lkp.sql
@@views/gui/vw_ui_attribute_4.sql
@@views/gui/vw_ui_attribute_4_val_to_lkp.sql
@@views/gui/vw_ui_segment_1_rel_value.sql
@@views/gui/vw_ui_segment_1_val_to_lkp.sql
@@views/gui/vw_ui_segment_2_rel_value.sql
@@views/gui/vw_ui_segment_2_val_to_lkp.sql
@@views/gui/vw_ui_segment_3_rel_value.sql
@@views/gui/vw_ui_segment_3_val_to_lkp.sql
@@views/gui/vw_ui_segment_4_rel_value.sql
@@views/gui/vw_ui_segment_4_val_to_lkp.sql
@@views/gui/vw_ui_segment_5_rel_value.sql
@@views/gui/vw_ui_segment_5_val_to_lkp.sql
@@views/gui/vw_ui_segment_6_rel_value.sql
@@views/gui/vw_ui_segment_6_val_to_lkp.sql
@@views/gui/vw_ui_segment_7_rel_value.sql
@@views/gui/vw_ui_segment_7_val_to_lkp.sql
@@views/gui/vw_ui_segment_8_rel_value.sql
@@views/gui/vw_ui_segment_8_val_to_lkp.sql
@@views/gui/vw_ui_segment_1.sql
@@views/gui/vw_ui_segment_2.sql
@@views/gui/vw_ui_segment_3.sql
@@views/gui/vw_ui_segment_4.sql
@@views/gui/vw_ui_segment_5.sql
@@views/gui/vw_ui_segment_6.sql
@@views/gui/vw_ui_segment_7.sql
@@views/gui/vw_ui_segment_8.sql
@@views/gui/vw_ui_reference_2.sql
@@views/gui/vw_ui_reference_4.sql
@@views/gui/vw_ui_reference_5.sql
@@views/gui/vw_ui_reference_7.sql
@@views/gui/svc_combination_check_gjlu.sql
@@views/gui/vw_ui_madj_source_system.sql
@@views/gui/uiv_journal_types.sql
@@grants/views/vw_ui_madj_source_system.sql

