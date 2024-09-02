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

conn ~slr_logon
 DECLARE
s_proc_name   VARCHAR2 (80) := 'slr.pr_reset_object_state'; 
   
BEGIN

FOR r_slr IN ( select distinct process_id from slr.prc_object_state_in_process
WHERE status in ('P','E') )
LOOP    

slr.pg_process_state.rollback_data(r_slr.process_id);

fdr.pg_common.plog('pr_reset_object_state deleted: '||to_char(r_slr.process_id));

END LOOP;


EXCEPTION
   WHEN OTHERS
   THEN
      fdr.pr_error (slr.slr_global_pkg.C_MAJERR,
                'Failure to execute pr_reset_object_state: ' || SQLERRM,
                slr.slr_global_pkg.C_TECHNICAL,
                s_proc_name,
                'prc_object_state_in_process',
                NULL,
                'SLR',
                NULL,
                'PL/SQL',
                SQLCODE);

      RAISE_APPLICATION_ERROR (
         -20001,
         'Fatal error during call of pr_reset_object_state ' || SQLERRM);
END;
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