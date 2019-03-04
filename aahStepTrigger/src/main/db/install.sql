-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which manage process invocation.
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

conn ~stn_logon

begin
    for i in ( select owner , view_name from all_views where owner = 'STN' ) loop
        execute immediate 'drop view ' || i.owner || '.' || i.view_name ;
    end loop;
end;
/

@@tables/stn/execution_folder.sql
@@tables/stn/project_type.sql
@@tables/stn/project.sql
@@tables/stn/step.sql
@@tables/stn/process.sql
@@tables/stn/process_type.sql
@@tables/stn/step_run_state.sql
@@tables/stn/step_run_status.sql
@@tables/stn/step_run.sql
@@tables/stn/step_run_param.sql
@@tables/stn/step_run_log.sql
@@tables/stn/param_set.sql
@@tables/stn/param_set_item.sql
@@views/stn/step_detail.sql
@@views/stn/step_param.sql
@@ri_constraints/stn/project.sql
@@ri_constraints/stn/process.sql
@@ri_constraints/stn/step.sql
@@ri_constraints/stn/step_run.sql
@@ri_constraints/stn/param_set_item.sql
@@ri_constraints/stn/step_run_param.sql
@@ri_constraints/stn/step_run_state.sql
@@procedures/stn/pr_step_run_log.sql
@@packages/stn/pk_tg.hdr
@@packages/stn/pk_tg.bdy
@@data/stn/process_type.sql
@@data/stn/execution_folder.sql
@@data/stn/project_type.sql
@@data/stn/project.sql
@@data/stn/process.sql
@@data/stn/param_set.sql
@@data/stn/param_set_item.sql
@@data/stn/step.sql
@@data/stn/step_run_status.sql
@@grants/procedures/stn/pr_step_run_log.sql

conn ~fdr_logon

delete from fdr.fr_batch_schedule;
commit;
@@data/fdr/fr_batch_schedule.sql
