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

conn ~fdr_logon
-- close balance_others.  It had to be opeded to allow entries for old balances
-- close balance_others.  It had to be opeded to allow entries for old balances
begin

delete from fdr.fr_general_lookup
where 
    lk_lkt_lookup_type_code   = 'EVENT_CLASS_PERIOD' and 
    lk_match_key1 = 'BALANCE_OTHERS' and
    lk_match_key2 >= 2024;
commit;
end;    
/
 
/* End AAH custom upgrades */

/* Refresh grants to aah_read_only and aah_rdr roles - do not remove */
conn ~sys_logon as sysdba
@@sys/99999_refresh_aah_roles.sql;

/* recompile any packages or procedures that are not compiled */
@@sys/recompile_all_objects.sql

/* Register upgrade - do not remove */
conn ~fdr_logon
@@fdr/99999_register_upgrade.sql;


exit