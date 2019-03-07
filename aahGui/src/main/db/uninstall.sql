-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which manage process invocation.
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

drop view gui.scv_combination_check_gjlu;
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
drop view gui.vw_ui_madj_source_system.sql;
commit;

update gui.t_ui_gui_parameters set guiparam_value = '500' where guiparam_name = 'data.max.rows.returned';
commit;