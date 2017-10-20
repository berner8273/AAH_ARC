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

delete from gui.t_ui_jrnl_line_meta;
delete from gui.t_ui_role_tasks         where role_id in ( 'role.subledger.administrator' , 'role.reference.data.user' , 'role.reference.data.approver' , 'role.subledger.user' , 'role.subledger.manager' , 'role.subledger.viewer' , 'role.subledger.configurator' );
delete from gui.t_ui_roles              where role_id in ( 'role.subledger.administrator' , 'role.reference.data.user' , 'role.reference.data.approver' , 'role.subledger.user' , 'role.subledger.manager' , 'role.subledger.viewer' , 'role.subledger.configurator' );
commit;

exit