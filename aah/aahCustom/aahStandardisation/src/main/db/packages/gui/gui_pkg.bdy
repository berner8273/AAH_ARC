CREATE OR REPLACE package body gui.gui_pkg
    as
        procedure pk_auto_resub
            (
                lpg in number,
                increment_retries in char
            )
        as
            s_proc_name varchar2(50) := $$plsql_unit || '.' || $$plsql_function ;
        begin
            pg_ui_error_handler.autoresubmit_transactions(lpg, increment_retries);
        end pk_auto_resub;

        procedure pk_check_resub
            (
                lpg in number
            )
        as
            s_proc_name varchar2(50) := $$plsql_unit || '.' || $$plsql_function ;
        begin
            pg_ui_error_handler.check_resubmitted_errors(lpg);
        end pk_check_resub;
end gui_pkg;
/