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

/* Begin AAH custom upgrades */

conn ~sys_logon as sysdba
grant execute on dbms_alert to SLR;

conn ~slr_logon
@@slr/upgrade_slr_packages.sql

conn ~gui_logon
@@gui/upgrade_gui_packages.sql

conn ~rdr_logon
@@gui/upgrade_rdr_packages.sql
@@gui/upgrade_rdr_views.sql

conn ~fdr_logon
@@fdr/upgrade_fdr_procedures.sql
@@fdr/upgrade_trigger_fix.sql



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