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

conn ~rdr_logon
@@rdr/us53060_rdr_views.sql

conn ~stn_logon
@@stn/us53060_stn_columns.sql

conn ~rdr_logon
@@rdr/us53060_rdr_views2.sql

conn ~stn_logon
@@stn/us53060_stn_views.sql
@@stn/us53060_packages.sql

conn ~fdr_logon
@@fdr/us58325_add_new_sub_accounts.sql
@@fdr/us53060_fr_account_lookup_param.sql
@@fdr/us53060_fdr_cleardown.sql 

-- this is still in prod - check with Marc if still needed
@@fdr/hotfix_fr_general_lookup_cash_offset.sql

conn ~stn_logon
-- add new posting rules data loader below
@@stn/us62156_posting_rules.sql

conn~gui_logon
@@gui/us53060_gui_event_class.sql

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