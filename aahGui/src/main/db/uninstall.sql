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

delete from gui.t_ui_jrnl_line_meta;
delete from gui.t_ui_role_tasks         where role_id not in ( 'role.administrator' , 'role.error.viewer' , 'role.error.updater' , 'role.static.data.viewer' , 'role.static.data.updater' , 'role.static.data.authoriser' , 'role.static.data.instrument.type.maintainer' , 'role.all.journal.types' , 'role.all.accounts' );
delete from gui.t_ui_roles              where role_id not in ( 'role.administrator' , 'role.error.viewer' , 'role.error.updater' , 'role.static.data.viewer' , 'role.static.data.updater' , 'role.static.data.authoriser' , 'role.static.data.instrument.type.maintainer' , 'role.all.journal.types' , 'role.all.accounts' );
commit;

exit