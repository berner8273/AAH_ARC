-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install AAH custom upgrades
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define fdr_logon=~1
define gui_logon=~2
define rdr_logon=~3
define sla_logon=~4
define slr_logon=~5
define stn_logon=~6
define sys_logon=~7
define unittest_login=~8


/* Check AAH upgrade versions - do not remove */
conn ~fdr_logon

conn ~sys_logon

/* Begin AAH custom upgrades */

conn ~slr_logon

conn ~gui_logon
@@gui/us62806_gui_event_class.sql

conn ~rdr_logon

conn ~fdr_logon

conn ~stn_logon

conn ~sys_logon
@@sys/add_back_security.sql;

/* End AAH custom upgrades */

/* Refresh grants to aah_read_only and aah_rdr roles - do not remove */
conn ~sys_logon as sysdba
@@sys/99999_refresh_aah_roles.sql;

/* recompile any packages or procedures that are not compiled */
@@sys/recompile_objects.sql

/* Register upgrade - do not remove */
conn ~fdr_logon
@@fdr/99999_register_upgrade.sql;


exit