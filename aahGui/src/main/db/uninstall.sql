-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which manage process invocation.
--         :
-- -----------------------------------------------------------------------------------------

--whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@

define gui_user     = @guiUsername@
define gui_password = @guiPassword@
define gui_logon    = ~gui_user/~gui_password@~tns_alias

conn ~gui_logon

delete from gui.ui_general_lookup;
delete from gui.ui_input_field_value;
delete from gui.ui_field;
delete from gui.ui_section;
delete from gui.ui_screen;
delete from gui.ui_component;
delete from gui.ui_gen_lookup_type_properties;
delete from gui.t_ui_jrnl_line_meta;
delete from gui.t_ui_role_tasks         where role_id in ( 'role.subledger.administrator' , 'role.reference.data.user' , 'role.reference.data.approver' , 'role.subledger.user' , 'role.subledger.manager' , 'role.subledger.viewer' , 'role.subledger.configurator' );
delete from gui.t_ui_roles              where role_id in ( 'role.subledger.administrator' , 'role.reference.data.user' , 'role.reference.data.approver' , 'role.subledger.user' , 'role.subledger.manager' , 'role.subledger.viewer' , 'role.subledger.configurator' );
commit;


drop view vw_ui_attribute_1;
drop view vw_ui_attribute_1_val_to_lkp;
drop view vw_ui_attribute_2;
drop view vw_ui_attribute_2_val_to_lkp;
drop view vw_ui_attribute_3;
drop view vw_ui_attribute_3_val_to_lkp;
drop view vw_ui_attribute_4;
drop view vw_ui_attribute_4_val_to_lkp;
drop view vw_ui_segment_1_rel_value;
drop view vw_ui_segment_1_val_to_lkp;
drop view vw_ui_segment_2_rel_value;
drop view vw_ui_segment_2_val_to_lkp;
drop view vw_ui_segment_3_rel_value;
drop view vw_ui_segment_3_val_to_lkp;
drop view vw_ui_segment_4_rel_value;
drop view vw_ui_segment_4_val_to_lkp;
drop view vw_ui_segment_5_rel_value;
drop view vw_ui_segment_5_val_to_lkp;
drop view vw_ui_segment_6_rel_value;
drop view vw_ui_segment_6_val_to_lkp;
drop view vw_ui_segment_7_rel_value;
drop view vw_ui_segment_7_val_to_lkp;
drop view vw_ui_segment_8_rel_value;
drop view vw_ui_segment_8_val_to_lkp;
drop view vw_ui_segment_1;
drop view vw_ui_segment_2;
drop view vw_ui_segment_3;
drop view vw_ui_segment_4;
drop view vw_ui_segment_5;
drop view vw_ui_segment_6;
drop view vw_ui_segment_7;
drop view vw_ui_segment_8;
commit;

exit