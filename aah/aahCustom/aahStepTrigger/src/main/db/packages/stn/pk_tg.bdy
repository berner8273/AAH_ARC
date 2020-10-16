CREATE OR REPLACE PACKAGE BODY stn.PK_TG AS
    PROCEDURE pr_update_fbs_started
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_process_name IN VARCHAR2
        )
    AS
        v_no_rows_updated NUMBER(18) DEFAULT 0;
        BatchScheduleRecordNotFound EXCEPTION;
    BEGIN
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Invoked', 'p_lpg_id', NULL, p_lpg_id, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Invoked', 'p_process_name', NULL, NULL, p_process_name);
        UPDATE fdr.fr_batch_schedule
            SET
                bs_status = 'S'
            WHERE
                fr_batch_schedule.lpg_id = p_lpg_id AND fr_batch_schedule.bs_object_name = p_process_name;
        v_no_rows_updated := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'fr_batch_schedule updated', 'v_no_rows_updated', NULL, v_no_rows_updated, NULL);
        IF v_no_rows_updated = 1 THEN
            NULL;
        ELSE
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'v_no_rows_updated != 0 - an exception will be thrown', 'v_no_rows_updated', NULL, v_no_rows_updated, NULL);
            RAISE BatchScheduleRecordNotFound;
        END IF;
    END;
    
    PROCEDURE pr_update_fbs_failed
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_process_name IN VARCHAR2
        )
    AS
        v_no_rows_updated NUMBER(18) DEFAULT 0;
        BatchScheduleRecordNotFound EXCEPTION;
    BEGIN
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Invoked', 'p_lpg_id', NULL, p_lpg_id, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Invoked', 'p_process_name', NULL, NULL, p_process_name);
        UPDATE fdr.fr_batch_schedule
            SET
                bs_status = 'F'
            WHERE
                fr_batch_schedule.lpg_id = p_lpg_id AND fr_batch_schedule.bs_object_name = p_process_name;
        v_no_rows_updated := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'fr_batch_schedule updated', 'v_no_rows_updated', NULL, v_no_rows_updated, NULL);
        IF v_no_rows_updated = 1 THEN
            NULL;
        ELSE
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'v_no_rows_updated != 0 - an exception will be thrown', 'v_no_rows_updated', NULL, v_no_rows_updated, NULL);
            RAISE BatchScheduleRecordNotFound;
        END IF;
    END;
    
    PROCEDURE pr_update_fbs_completed
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_process_name IN VARCHAR2,
            p_no_processed_records IN NUMBER,
            p_no_failed_records IN NUMBER
        )
    AS
        v_no_rows_updated NUMBER(18);
        BatchScheduleRecordNotFound EXCEPTION;
    BEGIN
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Invoked', 'p_lpg_id', NULL, p_lpg_id, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Invoked', 'p_process_name', NULL, NULL, p_process_name);
        UPDATE fdr.fr_batch_schedule
            SET
                bs_status = 'C',
                bs_records_failed = p_no_failed_records,
                bs_records_processed = p_no_processed_records
            WHERE
                fr_batch_schedule.lpg_id = p_lpg_id AND fr_batch_schedule.bs_object_name = p_process_name;
        v_no_rows_updated := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'fr_batch_schedule updated', 'v_no_rows_updated', NULL, v_no_rows_updated, NULL);
        IF v_no_rows_updated = 1 THEN
            NULL;
        ELSE
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'v_no_rows_updated != 0 - an exception will be thrown', 'v_no_rows_updated', NULL, v_no_rows_updated, NULL);
            RAISE BatchScheduleRecordNotFound;
        END IF;
    END;
    
    PROCEDURE pr_step_run_state
        (
            p_step_run_sid IN NUMBER,
            p_step_run_status_cd IN VARCHAR2
        )
    AS
    BEGIN
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Invoked', 'p_step_run_sid', NULL, p_step_run_sid, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Invoked', 'p_step_run_status_cd', NULL, NULL, p_step_run_status_cd);
        INSERT INTO step_run_state
            (step_run_sid, step_run_status_id)
            VALUES
            (p_step_run_sid, ( select step_run_status_id from stn.step_run_status where step_run_status_cd = p_step_run_status_cd ));
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Inserted step run state record', 'sql%rowcount', NULL, NULL, sql%rowcount);
    END;
    
    PROCEDURE pr_step_run_started
        (
            p_step_cd IN VARCHAR2,
            p_step_run_sid OUT NUMBER
        )
    AS
    BEGIN
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Invoked', 'p_step_cd', NULL, NULL, p_step_cd);
           insert
             into
                  stn.step_run
                (
                    step_id
                )
           values
                (
                    ( select step_id from stn.step where step_cd = p_step_cd )
                )
        returning
                  step_run_sid into p_step_run_sid
                ;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Retrieved the step_run_sid', 'p_step_run_sid', NULL, p_step_run_sid, NULL);
        pr_step_run_state(p_step_run_sid, 'R');
        insert
          into
               stn.step_run_param
             (
                 step_run_sid
             ,   param_set_item_cd
             ,   param_set_item_val
             )
        select
               p_step_run_sid
             , psi.param_set_item_cd
             , param_set_item_val
          from
                    stn.step           s
               join stn.param_set_item psi on s.param_set_id = psi.param_set_id
         where
               s.step_cd = p_step_cd
             ;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Inserted step_run_param records', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_log_error
        (
            p_step_cd IN VARCHAR2,
            p_error_message IN VARCHAR2,
            p_error_code IN VARCHAR2,
            p_lpg_id IN NUMBER,
            p_step_run_sid IN NUMBER
        )
    AS
    BEGIN
        INSERT INTO fdr.fr_log
            (lo_event_datetime, lo_event_text, lpg_id, lo_todays_bus_date, lo_error_rule_ident, lo_row_in_error_key_id, lo_event_type_id, lo_category_id)
            SELECT
                CURRENT_DATE AS lo_event_datetime,
                p_error_message AS lo_event_text,
                fr_global_parameter.lpg_id AS lpg_id,
                fr_global_parameter.gp_todays_bus_date AS lo_todays_bus_date,
                p_step_cd AS lo_error_rule_ident,
                p_step_run_sid AS lo_row_in_error_key_id,
                2 AS lo_event_type_id,
                0 AS lo_category_id
            FROM
                fdr.fr_global_parameter fr_global_parameter
            WHERE
                fr_global_parameter.lpg_id = p_lpg_id;
    END;
    
    PROCEDURE pr_get_step_params
        (
            p_step_cd IN VARCHAR2,
            p_lpg_id OUT NUMBER,
            p_process_name OUT VARCHAR2,
            p_disable_accounting OUT VARCHAR2
        )
    AS
        UndefinedBatchStep EXCEPTION;
    BEGIN
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Invoked', 'p_step_cd', NULL, NULL, p_step_cd);
        SELECT
            step_param.lpg_id,
            step_param.process_name,
            step_param.disable_accounting
        INTO
            p_lpg_id,
            p_process_name,
            p_disable_accounting
        FROM
            step_param
        WHERE
            step_param.step_cd = p_step_cd;
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Value retrieved:', 'p_lpg_id', NULL, p_lpg_id, NULL);
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Value retrieved:', 'p_process_name', NULL, NULL, p_process_name);
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Value retrieved:', 'p_disable_accounting', NULL, NULL, p_disable_accounting);
    END;
    
    PROCEDURE pr_get_step_details
        (
            p_step_cd IN VARCHAR2,
            p_folder_name OUT VARCHAR2,
            p_project_name OUT VARCHAR2,
            p_project_type_cd OUT VARCHAR2,
            p_process_name OUT VARCHAR2,
            p_process_type_cd OUT VARCHAR2,
            p_input_node_name OUT VARCHAR2
        )
    AS
        UndefinedBatchStep EXCEPTION;
    BEGIN
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Invoked', 'p_step_cd', NULL, NULL, p_step_cd);
        SELECT
            step_detail.folder_name,
            step_detail.project_name,
            step_detail.process_name,
            step_detail.process_type_cd,
            step_detail.project_type_cd,
            step_detail.input_node_name
        INTO
            p_folder_name,
            p_project_name,
            p_process_name,
            p_process_type_cd,
            p_project_type_cd,
            p_input_node_name
        FROM
            step_detail
        WHERE
            step_detail.step_cd = p_step_cd;
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Value retrieved:', 'p_folder_name', NULL, NULL, p_folder_name);
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Value retrieved:', 'p_project_name', NULL, NULL, p_project_name);
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Value retrieved:', 'p_process_name', NULL, NULL, p_process_name);
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Value retrieved:', 'p_process_type_cd', NULL, NULL, p_process_type_cd);
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Value retrieved:', 'p_project_type_cd', NULL, NULL, p_project_type_cd);
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Value retrieved:', 'p_input_node_name', NULL, NULL, p_input_node_name);
    END;
END PK_TG;
/