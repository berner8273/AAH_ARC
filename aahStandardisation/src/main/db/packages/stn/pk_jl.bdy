CREATE OR REPLACE PACKAGE BODY stn.PK_JL AS
    PROCEDURE pr_journal_line_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_hopper_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE hopper_journal_line hjl
            SET
                event_status = 'X',
                process_id = TO_CHAR(p_step_run_sid)
            WHERE
                    hjl.event_status != 'P'
and hjl.lpg_id        = p_lpg_id
and exists (
               select
                      null
                 from
                           stn.feed_type ftyp
                      join stn.process   prc  on ftyp.process_id = prc.process_id
                      join stn.step      stp  on prc.process_id  = stp.process_id
                      join stn.step_run  sr   on stp.step_id     = sr.step_id
                where
                      sr.step_run_sid = p_step_run_sid
                  and ftyp.feed_typ   = hjl.feed_typ
           );
        p_no_updated_hopper_records := SQL%ROWCOUNT;
    END;

    PROCEDURE pr_journal_line_idf
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
                jl.ROW_SID AS ROW_SID
            FROM
                journal_line jl
                INNER JOIN FEED ON jl.FEED_UUID = feed.FEED_UUID
            WHERE
                   jl.EVENT_STATUS = 'U'
and jl.LPG_ID       = p_lpg_id
and not exists (
                   select
                          null
                     from
                          stn.broken_feed bf
                    where
                          bf.feed_sid = feed.FEED_SID
               )
and not exists (
                  select
                         null
                    from
                         stn.superseded_feed sf
                   where
                         sf.superseded_feed_sid = feed.FEED_SID
              );
        p_no_identified_recs := SQL%ROWCOUNT;
        UPDATE journal_line jl
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                 jl.row_sid = idr.row_sid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated journal_line.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE journal_line jl
            SET
                EVENT_STATUS = 'X',
                STEP_RUN_SID = p_step_run_sid
            WHERE
                  jl.EVENT_STATUS = 'U'
and not exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                         jl.row_sid = idr.row_sid
               )
and not exists (
                   select
                          null
                     from
                               stn.broken_feed bf
                          join stn.feed        fd on bf.feed_sid = fd.feed_sid
                    where
                          fd.feed_uuid = jl.feed_uuid
               )
and not exists (
                  select
                         null
                    from
                              stn.superseded_feed sf
                         join stn.feed            fd on sf.superseded_feed_sid = fd.feed_sid
                   where
                         fd.feed_uuid = jl.feed_uuid
              );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated event_status to X on discarded journal_line records', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;

    PROCEDURE pr_journal_line_pub
        (
            p_step_run_sid IN NUMBER,
            p_total_no_published OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO hopper_journal_line
            (le_id, acct_cd, ledger_cd, basis_cd, book_cd, affiliate_le_id, accident_year, underwriting_year, policy_id, stream_id, tax_jurisdiction_cd, posting_schema, counterparty_le_id, dept_cd, chartfield_1, execution_typ, business_typ, owner_le_id, premium_typ, transaction_ccy, transaction_amt, sra_ae_dr_cr, accounting_dt, ultimate_parent_le_id, event_typ, functional_ccy, functional_amt, reporting_ccy, reporting_amt, sra_ae_source_system, sra_ae_itsc_inst_typ_sclss_cd, event_status, lpg_id)
            SELECT
                jl.LE_ID AS le_id,
                jl.ACCT_CD AS acct_cd,
                jl.LEDGER_CD AS ledger_cd,
                jl.BASIS_CD AS basis_cd,
                jl.LE_ID AS book_cd,
                jl.AFFILIATE_LE_ID AS affiliate_le_id,
                jl.ACCIDENT_YR AS accident_year,
                jl.ACCIDENT_YR AS underwriting_year,
                jl.POLICY_ID AS policy_id,
                jl.STREAM_ID AS stream_id,
                jl.TAX_JURISDICTION_CD AS tax_jurisdiction_cd,
                jl.LEDGER_CD AS posting_schema,
                jl.COUNTERPARTY_LE_ID AS counterparty_le_id,
                jl.DEPT_CD AS dept_cd,
                jl.CHARTFIELD_1 AS chartfield_1,
                jl.EXECUTION_TYP AS execution_typ,
                jl.BUSINESS_TYP AS business_typ,
                jl.OWNER_LE_ID AS owner_le_id,
                jl.PREMIUM_TYP AS premium_typ,
                jl.TRANSACTION_CCY AS transaction_ccy,
                jl.TRANSACTION_AMT AS transaction_amt,
                (CASE
                    WHEN jl.TRANSACTION_AMT >= 0 THEN 'DR'
                    ELSE 'CR'
                END) AS sra_ae_dr_cr,
                jl.ACCOUNTING_DT AS accounting_dt,
                jl.ULTIMATE_PARENT_LE_ID AS ultimate_parent_le_id,
                jl.EVENT_TYP AS event_typ,
                jl.FUNCTIONAL_CCY AS functional_ccy,
                jl.FUNCTIONAL_AMT AS functional_amt,
                jl.REPORTING_CCY AS reporting_ccy,
                jl.REPORTING_AMT AS reporting_amt,
                jl_default.SRA_AE_SOURCE_SYSTEM AS sra_ae_source_system,
                jl_default.SRA_AE_ITSC_INST_TYP_SCLSS_CD AS sra_ae_itsc_inst_typ_sclss_cd,
                jl.EVENT_STATUS AS event_status,
                jl.LPG_ID AS lpg_id
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN journal_line_default jl_default ON 1 = 1;
        p_total_no_published := SQL%ROWCOUNT;
    END;

    PROCEDURE pr_journal_line_rval
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                TO_CHAR(jl.LE_ID) AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                jl.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                jl.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON jl.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-le_id'
and not exists (
                   select
                          null
                     from
                          fdr.fr_party_legal fpl
                    where
                          fpl.pl_global_id = jl.LE_ID
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                jl.ACCT_CD AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                jl.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                jl.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON jl.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-acct_cd'
and not exists (
                   select
                          null
                     from
                          fdr.fr_gl_account fga
                    where
                         fga.ga_account_code = jl.ACCT_CD
               );
    END;

    PROCEDURE pr_journal_line_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE journal_line jl
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       fdr.fr_stan_raw_adjustment fsra
                  join stn.identified_record   idr   on to_number ( fsra.message_id ) = idr.row_sid
            where
                  idr.row_sid = jl.ROW_SID
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;

    PROCEDURE journal_line_svs
        (
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE journal_line jl
            SET
                EVENT_STATUS = 'E'
            WHERE
                exists (
           select
                  null
             from
                  stn.standardisation_log sl
            where
                  sl.row_in_error_key_id = jl.ROW_SID
       );
        UPDATE journal_line jl
            SET
                EVENT_STATUS = 'V'
            WHERE
                    not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = jl.ROW_SID
               )
and     exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          jl.ROW_SID = idr.row_sid
               );
        p_no_validated_records := SQL%ROWCOUNT;
    END;

    PROCEDURE pr_journal_line_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_processed_records NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrpl_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrpb_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrie_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrohn_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrpl_updated NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrpb_updated NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrie_updated NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrohn_updated NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify journal line records' );
        pr_journal_line_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed journal line hopper records' );
            pr_journal_line_chr(p_step_run_sid, p_lpg_id, p_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed journal line hopper records', 'v_total_no_fsrpl_updated', NULL, v_total_no_fsrpl_updated, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate journal line records' );
            pr_journal_line_rval;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed journal line row level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set journal line status = "V"' );
            journal_line_svs(v_no_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status', 'v_no_validated_records', NULL, v_no_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish legal entity records' );
            pr_journal_line_pub(p_step_run_sid, p_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing journal line hopper records', 'v_total_no_fsrpl_published', NULL, v_total_no_fsrpl_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish journal line log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set journal line status = "P"' );
            pr_journal_line_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_processed_records', NULL, v_no_processed_records, NULL);
            IF v_no_processed_records <> v_no_validated_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_processed_records <> v_no_validated_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 3' );
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := v_no_identified_records - v_no_processed_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_JL;

