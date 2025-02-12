CREATE OR REPLACE PACKAGE BODY STN.PK_DEPT AS
    PROCEDURE pr_department_idf
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_identified_recs OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO IDENTIFIED_RECORD
            (ROW_SID)
            SELECT
                dept.ROW_SID AS ROW_SID
            FROM
                DEPARTMENT dept
                INNER JOIN FEED fd ON dept.FEED_UUID = fd.FEED_UUID
                INNER JOIN (SELECT
                    dept.DEPT_CD AS dept_cd,
                    MAX(dept.EFFECTIVE_DT) AS effective_dt
                FROM
                    DEPARTMENT dept
                    INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON dept.LPG_ID = fgp.LPG_ID
                WHERE
                    dept.EVENT_STATUS = 'U' AND dept.DEPT_STS = 'A' AND dept.EFFECTIVE_DT <= fgp.GP_TODAYS_BUS_DATE
                GROUP BY
                    dept.DEPT_CD) "most-recent-records" ON dept.DEPT_CD = "most-recent-records".dept_cd AND dept.EFFECTIVE_DT = "most-recent-records".effective_dt
            WHERE
                    dept.EVENT_STATUS = 'U'
and dept.LPG_ID       = p_lpg_id
and not exists (
                   select
                          null
                     from
                          stn.broken_feed bf
                    where
                          bf.feed_sid = fd.FEED_SID
               )
and not exists (
                  select
                         null
                    from
                         stn.superseded_feed sf
                   where
                         sf.superseded_feed_sid = fd.FEED_SID
              );
        p_no_identified_recs := SQL%ROWCOUNT;
        UPDATE DEPARTMENT dept
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  dept.row_sid = idr.row_sid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated department.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE DEPARTMENT dept
            SET
                EVENT_STATUS = 'X',
                STEP_RUN_SID = p_step_run_sid
            WHERE
                    dept.EVENT_STATUS = 'U'
and not exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          dept.row_sid = idr.row_sid
               )
and not exists (
                   select
                          null
                     from
                               stn.broken_feed bf
                          join stn.feed        fd on bf.feed_sid = fd.feed_sid
                    where
                          fd.feed_uuid = dept.feed_uuid
               )
and not exists (
                  select
                         null
                    from
                              stn.superseded_feed sf
                         join stn.feed            fd on sf.superseded_feed_sid = fd.feed_sid
                   where
                         fd.feed_uuid = dept.feed_uuid
              );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated event_status to X on discarded records', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;

    PROCEDURE pr_department_pub
        (
            p_step_run_sid IN NUMBER,
            p_total_no_published OUT NUMBER,
            p_total_no_gui_published OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO fdr.FR_STAN_RAW_BOOK
            (SRB_BO_BOOK_CLICODE, SRB_BO_BOOK_NAME, SRB_BO_BANKING_OR_TRADING, SRB_SI_SOURCE_SYSTEM, SRB_BO_IPE_INTERNAL_ENTITY_CDE, SRB_BO_BS_BOOK_STATUS_CODE, SRB_BO_VALID_FROM, SRB_BO_ACTIVE, LPG_ID, MESSAGE_ID, PROCESS_ID)
            SELECT
                dept.DEPT_CD AS SRB_BO_BOOK_CLICODE,
                dept.DEPT_DESCR AS SRB_BO_BOOK_NAME,
                DEPT_DEFAULT.BANKING_TRADING_IND AS SRB_BO_BANKING_OR_TRADING,
                DEPT_DEFAULT.SYSTEM_INSTANCE AS SRB_SI_SOURCE_SYSTEM,
                DEPT_DEFAULT.INTERNAL_PROC_ENTITY AS SRB_BO_IPE_INTERNAL_ENTITY_CDE,
                DEPT_DEFAULT.BOOK_STATUS AS SRB_BO_BS_BOOK_STATUS_CODE,
                dept.EFFECTIVE_DT AS SRB_BO_VALID_FROM,
                dept.DEPT_STS AS SRB_BO_ACTIVE,
                dept.LPG_ID AS LPG_ID,
                TO_CHAR(dept.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID
            FROM
                DEPARTMENT dept
                INNER JOIN IDENTIFIED_RECORD idr ON dept.ROW_SID = idr.ROW_SID
                INNER JOIN DEPT_DEFAULT ON 1 = 1;
        p_total_no_published := SQL%ROWCOUNT;
        MERGE INTO gui.T_UI_DEPARTMENTS T_UI_DEPARTMENTS
            USING
                (SELECT
                    d.DEPT_CD AS DEPT_CD,
                    d.DEPT_DESCR AS DEPT_DESCR
                FROM
                    DEPARTMENT d
                    INNER JOIN IDENTIFIED_RECORD idr ON d.ROW_SID = idr.ROW_SID) stn_department
            ON (T_UI_DEPARTMENTS.DEPARTMENT_ID = stn_department.DEPT_CD)
            WHEN MATCHED THEN
                UPDATE SET
                    DEPARTMENT_NAME = stn_department.DEPT_DESCR
            WHEN NOT MATCHED THEN
                INSERT
                    (DEPARTMENT_ID, DEPARTMENT_NAME)
                    VALUES
                    (stn_department.DEPT_CD, stn_department.DEPT_DESCR);
        p_total_no_gui_published := SQL%ROWCOUNT;
    END;

    PROCEDURE pr_department_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE DEPARTMENT dept
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       fdr.fr_stan_raw_book  fsrb
                  join stn.identified_record idr  on to_number ( fsrb.message_id ) = idr.row_sid
                  join stn.step_run          sr   on to_number ( fsrb.process_id ) = sr.step_run_sid
                  join stn.step              s    on sr.step_id                    = s.step_id
                  join stn.process           p    on s.process_id                  = p.process_Id
            where
                  idr.row_sid    = dept.ROW_SID
              and p.process_name = 'department-standardise'
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;

    PROCEDURE pr_department_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_hopper_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE fdr.FR_STAN_RAW_BOOK fsrb
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                    fsrb.EVENT_STATUS != 'P'
and fsrb.LPG_ID        = p_lpg_id
and exists (
               select
                      null
                 from
                           stn.step_run sr
                      join stn.step     s  on sr.step_id   = s.step_id
                      join stn.process  p  on s.process_id = p.process_id
                where
                      sr.step_run_sid = to_number ( fsrb.PROCESS_ID )
                  and p.process_name  = 'department-standardise'
           );
        p_no_updated_hopper_records := SQL%ROWCOUNT;
    END;

    PROCEDURE pr_department_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_processed_records NUMBER(38, 9) DEFAULT 0;
        v_total_no_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_gui_published NUMBER(38, 9) DEFAULT 0;
        v_no_updated_hopper_records NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
        s_proc_name VARCHAR2(80) := 'STN.PK_DEPT.pr_department_prc';
        gv_ecode     NUMBER := -20001;
        gv_emsg VARCHAR(10000);
        s_exception_name VARCHAR2(80);

    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify department records' );
        pr_department_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed hopper records' );
            pr_department_chr(p_step_run_sid, p_lpg_id, v_no_updated_hopper_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cancellation of unprocessed hopper records', 'v_no_updated_hopper_records', NULL, v_no_updated_hopper_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish department records' );
            pr_department_pub(p_step_run_sid, v_total_no_published, v_total_no_gui_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing records', 'v_total_no_published', NULL, v_total_no_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing gui records', 'v_total_no_gui_published', NULL, v_total_no_gui_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set department status = "P"' );
            pr_department_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_processed_records', NULL, v_no_processed_records, NULL);

            IF v_no_processed_records <> v_no_identified_records THEN
                s_exception_name:= 'v_no_processed_records <> v_no_identified_records';
                raise pub_val_mismatch;
            END IF;

            IF v_no_processed_records <> v_total_no_published THEN
                s_exception_name:= 'v_no_processed_records <> v_total_no_published';
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := v_no_identified_records - v_no_processed_records;

        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;

           EXCEPTION
                WHEN pub_val_mismatch THEN
                    pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_processed_records ('||to_char(v_no_processed_records)||') <> v_total_no_published('||to_char(v_total_no_published)||')', NULL, NULL, NULL, NULL);
                    dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => s_exception_name);
                    gv_emsg := 'Failure in ' || s_proc_name  || ': '|| sqlerrm;
                    RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg||' '||s_exception_name);
                WHEN OTHERS THEN
                    ROLLBACK;
                    gv_emsg := 'Failure in ' || s_proc_name  || ': '|| sqlerrm;
                    RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

    END;
END PK_DEPT;
/