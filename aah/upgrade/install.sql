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
@@fdr/hot_fix_remove_old_upgrade.sql

conn ~sys_logon
@@sys/00001_check_upgrade_versions.sql

/* Begin AAH custom upgrades */

conn ~slr_logon
@@slr/Customisations_SLR.sql

conn ~gui_logon
@@gui/Customisations_GUI.sql
@@gui/us44041_ui_field.sql

conn ~rdr_logon
--@@rdr/Customisations_RDR.sql --moved this to a separate branch and deploy
@@rdr/us53039_rcv_glint_journal_line_views.sql
@@rdr/us44041_rdr_pkg_bdy.sql

conn ~fdr_logon

conn ~stn_logon
@@stn/us44041_period_status.sql

conn ~sys_logon
@@sys/add_back_security.sql

/* End AAH custom upgrades */

/* Refresh grants to aah_read_only and aah_rdr roles - do not remove */
conn ~sys_logon as sysdba
@@sys/99999_refresh_aah_roles.sql

/* recompile any packages or procedures that are not compiled */
@@sys/recompile_objects.sql

/* Register upgrade - do not remove */
conn ~fdr_logon
@@fdr/99999_register_upgrade.sql


exit