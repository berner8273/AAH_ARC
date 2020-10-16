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
conn ~sys_logon
@@sys/00001_check_upgrade_versions.sql

/* Begin AAH custom upgrades */


conn ~stn_logon

conn ~rdr_logon
@@rdr/us53039_rcv_glint_journal_line_views.sql

conn ~stn_logon


conn ~fdr_logon
@@fdr/us53060_fr_account_lookup_param.sql
@@fdr/us53060_fdr_cleardown.sql 
@@fdr/us50700_gl_account_fix.sql 
@@fdr/hotfix_fr_general_lookup_cash_offset.sql

conn ~stn_logon
@@stn/us53060_aah_posting_rules_data_loader.sql

conn~gui_logon
@@gui/us53060_gui_event_class.sql

conn ~fdr_logon


conn ~rdr_logon
@@rdr/US53039_glint_journal_line.sql
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