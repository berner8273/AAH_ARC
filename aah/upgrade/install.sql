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
INSERT INTO FDR.FR_GENERAL_CODES (
   GC_GENERAL_CODE_ID, GC_GCT_CODE_TYPE_ID, GC_CLIENT_CODE, 
   GC_CLIENT_TEXT1, GC_CLIENT_TEXT2, GC_CLIENT_TEXT3, 
   GC_CLIENT_TEXT4, GC_CLIENT_TEXT5, GC_CLIENT_TEXT6, 
   GC_CLIENT_TEXT7, GC_CLIENT_TEXT8, GC_CLIENT_TEXT9, 
   GC_CLIENT_TEXT10, GC_DESCRIPTION,GC_ACTIVE)
VALUES ( 'NVS', 'GL_CHARTFIELD', 'NVS', 'CHARTFIELD_1', 'NVS', null,null,null,null,null,null,null, null, null,'A');
INSERT INTO FDR.FR_GENERAL_CODES (
   GC_GENERAL_CODE_ID, GC_GCT_CODE_TYPE_ID, GC_CLIENT_CODE, 
   GC_CLIENT_TEXT1, GC_CLIENT_TEXT2, GC_CLIENT_TEXT3, 
   GC_CLIENT_TEXT4, GC_CLIENT_TEXT5, GC_CLIENT_TEXT6, 
   GC_CLIENT_TEXT7, GC_CLIENT_TEXT8, GC_CLIENT_TEXT9, 
   GC_CLIENT_TEXT10, GC_DESCRIPTION,GC_ACTIVE)
VALUES ( 'DNP', 'GL_CHARTFIELD', 'DNP', 'CHARTFIELD_1', 'DO NOT PROCESS', null,null,null,null,null,null,null, null, null,'A');
COMMIT;
 
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