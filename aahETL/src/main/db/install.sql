-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the users and roles which will be used AG's ETL processes.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@
define sys_user     = @sysUsername@
define sys_password = @sysPassword@
define sys_logon    = ~sys_user/~sys_password@~tns_alias

conn ~sys_logon as sysdba

@@roles/aah_load.sql
@@users/aah_ssis.sql

exit 