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
-- this is not needed anymore
-- conn ~sys_logon
-- @@sys/00001_check_upgrade_versions.sql

/* Begin AAH custom upgrades */

conn ~stn_logon
@@stn/jl_desc_stn_columns.sql
@@stn/jl_desc_stn_views.sql
@@stn/bug68620_reversal_hist.sql
@@stn/bug69413_validations.sql
@@stn/pk_cev.sql

conn ~fdr_logon
alter table fr_stan_raw_acc_event modify SRAE_CLIENT_SPARE_ID19 varchar2( 100 byte);
@@fdr/bug69413_fr_log_update.sql

conn ~slr_logon
@@slr/offset_desc_slr_pkg.sql

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