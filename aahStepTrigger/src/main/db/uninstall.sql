-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which manage process invocation.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias          = @oracleTnsAlias@
define stn_user           = @stnUsername@
define stn_password       = @stnPassword@
define stn_logon          = ~stn_user/~stn_password@~tns_alias

define fdr_user           = @fdrUsername@
define fdr_password       = @fdrPassword@
define fdr_logon          = ~fdr_user/~fdr_password@~tns_alias

conn ~stn_logon

drop table stn.step_run_log;
drop table stn.step_run_param;
drop table stn.step_run_state;
drop table stn.step_run;
drop table stn.step_run_status;
drop table stn.step;
drop table stn.process;
drop table stn.process_type;
drop table stn.project;
drop table stn.project_type;
drop table stn.execution_folder;
drop table stn.param_set_item;
drop table stn.param_set;
drop view stn.step_detail;
drop view stn.step_param;
drop procedure stn.pr_step_run_log;
drop package body stn.pk_tg;
drop package      stn.pk_tg;

conn ~fdr_logon

delete from fdr.fr_batch_schedule;
commit;

exit