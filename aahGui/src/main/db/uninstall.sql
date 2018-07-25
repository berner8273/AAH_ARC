-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which manage process invocation.
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

update gui.t_ui_gui_parameters set guiparam_value = '500' where guiparam_name = 'data.max.rows.returned';
commit;

exit