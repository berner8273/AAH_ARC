create or replace procedure stn.pr_step_run_log
(
    p_step_run_sid   in stn.step_run_log.step_run_sid%type
,   p_code_module_nm in stn.step_run_log.code_module_nm%type
,   p_code_module_ln in stn.step_run_log.code_module_ln%type
,   p_msg            in stn.step_run_log.msg%type
,   p_var_nm         in stn.step_run_log.var_nm%type
,   p_var_val_dt     in stn.step_run_log.var_val_dt%type
,   p_var_val_num    in stn.step_run_log.var_val_num%type
,   p_var_val_str    in stn.step_run_log.var_val_str%type
)
as
    pragma autonomous_transaction;
begin
    insert
      into
           stn.step_run_log
         (
             step_run_sid
         ,   code_module_nm
         ,   code_module_ln
         ,   msg
         ,   var_nm
         ,   var_val_dt
         ,   var_val_num
         ,   var_val_str
         )
    values
         (
             p_step_run_sid
         ,   p_code_module_nm
         ,   p_code_module_ln
         ,   p_msg
         ,   p_var_nm
         ,   p_var_val_dt
         ,   p_var_val_num
         ,   p_var_val_str
         );

    commit;
end;
/