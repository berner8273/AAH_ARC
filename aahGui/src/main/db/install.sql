-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which are involved in standardisation.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@

define gui_user     = @guiUsername@
define gui_password = @guiPassword@
define gui_logon    = ~gui_user/~gui_password@~tns_alias

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




exit