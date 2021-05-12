CREATE OR REPLACE PACKAGE BODY STN.PK_JL AS
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
        dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'IDENTIFIED_RECORD' , cascade => true );
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

    PROCEDURE pr_journal_line_sval
        (
            p_step_run_sid IN NUMBER
        )
    AS
    BEGIN
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-functional-sum', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jlsfa.functional_amt) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    jl.FEED_UUID AS FEED_UUID,
                    jl.CORRELATION_ID AS CORRELATION_ID,
                    jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                    jl.FUNCTIONAL_CCY AS FUNCTIONAL_CCY,
                    SUM(jl.FUNCTIONAL_AMT) AS functional_amt
                FROM
                    journal_line jl
                GROUP BY
                    jl.FEED_UUID,
                    jl.CORRELATION_ID,
                    jl.ACCOUNTING_DT,
                    jl.FUNCTIONAL_CCY
                HAVING
                    SUM(jl.FUNCTIONAL_AMT) <> 0) jlsfa ON jl.FEED_UUID = jlsfa.FEED_UUID AND jl.CORRELATION_ID = jlsfa.CORRELATION_ID AND jl.ACCOUNTING_DT = jlsfa.ACCOUNTING_DT AND jl.FUNCTIONAL_CCY = jlsfa.FUNCTIONAL_CCY
            WHERE
                vdl.VALIDATION_CD = 'jl-functional_sum';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-functional-sum', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-reporting-sum', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jlsra.reporting_amt) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    jl.FEED_UUID AS FEED_UUID,
                    jl.CORRELATION_ID AS CORRELATION_ID,
                    jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                    jl.REPORTING_CCY AS REPORTING_CCY,
                    SUM(jl.REPORTING_AMT) AS reporting_amt
                FROM
                    journal_line jl
                GROUP BY
                    jl.FEED_UUID,
                    jl.CORRELATION_ID,
                    jl.ACCOUNTING_DT,
                    jl.REPORTING_CCY
                HAVING
                    SUM(jl.REPORTING_AMT) <> 0) jlsra ON jl.FEED_UUID = jlsra.FEED_UUID AND jl.CORRELATION_ID = jlsra.CORRELATION_ID AND jl.ACCOUNTING_DT = jlsra.ACCOUNTING_DT AND jl.REPORTING_CCY = jlsra.REPORTING_CCY
            WHERE
                vdl.VALIDATION_CD = 'jl-reporting_sum';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-reporting-sum', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-transaction-sum', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jlsta.transaction_amt) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    jl.FEED_UUID AS FEED_UUID,
                    jl.CORRELATION_ID AS CORRELATION_ID,
                    jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                    jl.TRANSACTION_CCY AS TRANSACTION_CCY,
                    SUM(jl.TRANSACTION_AMT) AS transaction_amt
                FROM
                    journal_line jl
                GROUP BY
                    jl.FEED_UUID,
                    jl.CORRELATION_ID,
                    jl.ACCOUNTING_DT,
                    jl.TRANSACTION_CCY
                HAVING
                    SUM(jl.TRANSACTION_AMT) <> 0) jlsta ON jl.FEED_UUID = jlsta.FEED_UUID AND jl.CORRELATION_ID = jlsta.CORRELATION_ID AND jl.ACCOUNTING_DT = jlsta.ACCOUNTING_DT AND jl.TRANSACTION_CCY = jlsta.TRANSACTION_CCY
            WHERE
                vdl.VALIDATION_CD = 'jl-transaction_sum';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-transaction-sum', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;

    PROCEDURE pr_journal_line_rval
        (
            p_step_run_sid IN NUMBER
        )
    AS
    BEGIN
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-le-id', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jl.LE_ID) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN journal_line_default jld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-le_id'
and not exists (
                   select
                          null
                     from
                               fdr.fr_party_legal_lookup fpll
                          join fdr.fr_party_legal        fpl  on (
                                                                         fpll.pll_lookup_key           = fpl.pl_party_legal_clicode
                                                                     and fpll.pll_sil_sys_inst_clicode = fpl.pl_si_sys_inst_id
                                                                 )
                          join fdr.fr_party_type         fpt  on fpl.pl_pt_party_type_id = fpt.pt_party_type_id
                    where
                          to_number ( fpl.pl_global_id ) = jl.LE_ID
                      and fpll.pll_sil_sys_inst_clicode  = jld.SRA_SI_PARTY_SYS_INST_CODE
                      and fpt.pt_party_type_name         = 'Ledger Entity'
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-le-id', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-acct-cd', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                jl.ACCT_CD AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN journal_line_default jld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-acct_cd'
and not exists (
                   select
                          null
                     from
                          fdr.fr_gl_account_lookup fgal
                    where
                          fgal.gal_ga_lookup_key        = jl.ACCT_CD
                      and fgal.gal_sil_sys_inst_clicode = jld.SRA_SI_ACCOUNT_SYS_INST_CODE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-acct-cd', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-ultimate-parent-le-id', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jl.ULTIMATE_PARENT_LE_ID) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN journal_line_default jld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-ultimate_parent_le_id' and jl.ULTIMATE_PARENT_LE_ID is not null
and not exists (
                   select
                          null
                     from
                               fdr.fr_party_legal_lookup fpll
                          join fdr.fr_party_legal        fpl  on (
                                                                         fpll.pll_lookup_key           = fpl.pl_party_legal_clicode
                                                                     and fpll.pll_sil_sys_inst_clicode = fpl.pl_si_sys_inst_id
                                                                 )
                          join fdr.fr_party_type         fpt  on fpl.pl_pt_party_type_id = fpt.pt_party_type_id
                    where
                          to_number ( fpl.pl_global_id ) = jl.ULTIMATE_PARENT_LE_ID
                      and fpll.pll_sil_sys_inst_clicode  = jld.SRA_SI_PARTY_SYS_INST_CODE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-ultimate-parent-le-id', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-tax_jurisdiction-cd', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                jl.TAX_JURISDICTION_CD AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-tax_jurisdiction_cd' and jl.TAX_JURISDICTION_CD is not null
and not exists (
                   select
                          null
                     from
                          fdr.fr_general_codes frgc
                    where
                          frgc.gc_client_code      = jl.TAX_JURISDICTION_CD
                      and frgc.gc_gct_code_type_id = 'TAX_JURISDICTION'
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-tax_jurisdiction-cd', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-owner-le-id', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jl.OWNER_LE_ID) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN journal_line_default jld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-owner_le_id' and jl.OWNER_LE_ID is not null
and not exists (
                   select
                          null
                     from
                               fdr.fr_party_legal_lookup fpll
                          join fdr.fr_party_legal        fpl  on (
                                                                         fpll.pll_lookup_key           = fpl.pl_party_legal_clicode
                                                                     and fpll.pll_sil_sys_inst_clicode = fpl.pl_si_sys_inst_id
                                                                 )
                          join fdr.fr_party_type         fpt  on fpl.pl_pt_party_type_id = fpt.pt_party_type_id
                    where
                          to_number ( fpl.pl_global_id ) = jl.OWNER_LE_ID
                      and fpll.pll_sil_sys_inst_clicode  = jld.SRA_SI_PARTY_SYS_INST_CODE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-owner-le-id', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-chartfield-1', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                jl.CHARTFIELD_1 AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-chartfield_1'
and jl.CHARTFIELD_1 is not null
and not exists (
                   select
                          null
                     from
                         fdr.fr_general_codes fgc
                    where
                         fgc.gc_client_code= jl.CHARTFIELD_1
and fgc.gc_gct_code_type_id='GL_CHARTFIELD'
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-chartfield-1', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-counterparty-le-id', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jl.COUNTERPARTY_LE_ID) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN journal_line_default jld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-counterparty_le_id'
and jl.COUNTERPARTY_LE_ID is not null
and not exists (
                   select
                          null
                     from
                               fdr.fr_party_legal_lookup fpll
                          join fdr.fr_party_legal        fpl  on (
                                                                         fpll.pll_lookup_key           = fpl.pl_party_legal_clicode
                                                                     and fpll.pll_sil_sys_inst_clicode = fpl.pl_si_sys_inst_id
                                                                 )
                          join fdr.fr_party_type         fpt  on fpl.pl_pt_party_type_id = fpt.pt_party_type_id
                    where
                          to_number ( fpl.pl_global_id ) = jl.COUNTERPARTY_LE_ID
                      and fpll.pll_sil_sys_inst_clicode  = jld.SRA_SI_PARTY_SYS_INST_CODE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-counterparty-le-id', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-dept-cd', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                jl.DEPT_CD AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON jl.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-dept_cd' and jl.DEPT_CD is not null
and not exists (
                   select
                          null
                     from
                      fdr.fr_book fb
                    where
                          fb.bo_book_clicode = jl.DEPT_CD
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-dept-cd', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-policy-id', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                jl.POLICY_ID AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-policy_id' and jl.POLICY_ID is not null
and not exists (
                   select
                          null
                     from
                          fdr.fr_instr_insure_extend fie
                    where
                         fie.iie_cover_signing_party = jl.POLICY_ID
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-policy-id', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-stream-id', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jl.STREAM_ID) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-stream_id' and jl.STREAM_ID is not null
and not exists (
                   select
                          null
                     from
                          fdr.fr_trade ft
                    where
                          to_number ( ft.t_source_tran_no ) = jl.STREAM_ID
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-stream-id', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-affiliate-le-id', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jl.AFFILIATE_LE_ID) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN journal_line_default jld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-affiliate_le_id'
and jl.AFFILIATE_LE_ID is not null
and not exists (
                   select
                          null
                     from
                               fdr.fr_party_legal_lookup fpll
                          join fdr.fr_party_legal        fpl  on (
                                                                         fpll.pll_lookup_key           = fpl.pl_party_legal_clicode
                                                                     and fpll.pll_sil_sys_inst_clicode = fpl.pl_si_sys_inst_id
                                                                 )
                          join fdr.fr_party_type         fpt  on fpl.pl_pt_party_type_id = fpt.pt_party_type_id
                    where
                          to_number ( fpl.pl_global_id ) = jl.AFFILIATE_LE_ID
                      and fpll.pll_sil_sys_inst_clicode  = jld.SRA_SI_PARTY_SYS_INST_CODE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-affiliate-le-id', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-basis_cd', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                jl.BASIS_CD AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                vdl.VALIDATION_CD = 'jl-basis_cd'
and not exists (
                   select
                          null
                     from
                          fdr.fr_gaap frg
                    where
                         frg.fga_gaap_id = jl.BASIS_CD
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-basis_cd', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-event-typ', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                jl.EVENT_TYP AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON jl.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-event_typ'
and jl.EVENT_TYP != 'NVS'
and not exists (
                   select
                          null
                     from
                      fdr.fr_acc_event_type faet
                    where
                         faet.aet_acc_event_type_id = jl.EVENT_TYP
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-event-typ', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-le-id-comparison', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                'LE_ID compare error' AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON jl.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-le_id-comparison'
and ( (jl.LE_ID = jl.AFFILIATE_LE_ID) OR (jl.LE_ID = jl.COUNTERPARTY_LE_ID) OR (jl.AFFILIATE_LE_ID = jl.COUNTERPARTY_LE_ID) );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-le-id-comparison', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-accounting_dt', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                to_char ( jl.ACCOUNTING_DT , 'mm/dd/yyyy' ) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON jl.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN event_hierarchy_reference er ON er.event_typ = jl.EVENT_TYP
            WHERE
                    vdl.VALIDATION_CD = 'jl-accounting_dt'
and    (not exists
                    ( select null
                            from stn.event_hierarchy_reference ehr, stn.period_status ps
                                where  ehr.event_class = ps.event_class
                                    and to_char(jl.ACCOUNTING_DT,'YYYYMM') = ps.period
                                    and ps.status = 'O' and
                                    (jl.EVENT_TYP = ehr.event_typ ) )
                      and jl.source_typ_cd <> 'HL' and er.period_close_freq <> 'N'
            )
;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-accounting_dt', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-functional-ccy', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                jl.FUNCTIONAL_CCY AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON jl.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN journal_line_default jld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-functional_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = jl.FUNCTIONAL_CCY
                      and fcl.cul_sil_sys_inst_clicode = jld.SRA_SI_STATIC_SYS_INST_CODE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-functional-ccy', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-reporting-ccy', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                jl.REPORTING_CCY AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON jl.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN journal_line_default jld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-reporting_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = jl.REPORTING_CCY
                      and fcl.cul_sil_sys_inst_clicode = jld.SRA_SI_STATIC_SYS_INST_CODE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-reporting-ccy', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-transaction-ccy', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                jl.TRANSACTION_CCY AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON jl.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN journal_line_default jld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-transaction_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = jl.TRANSACTION_CCY
                      and fcl.cul_sil_sys_inst_clicode = jld.SRA_SI_STATIC_SYS_INST_CODE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-transaction-ccy', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-policy-stream', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                (CASE
                    WHEN vdl.COLUMN_NM = 'stream_id' THEN TO_CHAR(jl.STREAM_ID)
                    WHEN vdl.COLUMN_NM = 'policy_id' THEN jl.POLICY_ID
                END) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'jl-policy-stream'
and not exists (
                   select
                          null
                     from
                          fdr.fr_trade ft
                    where
                          to_number ( ft.t_source_tran_no ) = jl.STREAM_ID
               )
and not exists (
                   select
                          null
                     from
                          fdr.fr_instr_insure_extend fie
                    where
                         fie.iie_cover_signing_party = jl.POLICY_ID
               )
and jl.STREAM_ID is not null and jl.POLICY_ID is not null;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-policy-stream', 'sql%rowcount', NULL, sql%rowcount, NULL);              


        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-usd-trans-vs-reportingt-amt', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                to_char(JL.TRANSACTION_AMT)||' vs '||to_char(jl.REPORTING_AMT) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON jl.LPG_ID = fgp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    ( vdl.VALIDATION_CD = 'jl-trans_vs_reporting_amt' AND NVL(jl.chartfield_1,' ') <> 'DNP') 
            AND (
                    JL.LEDGER_CD in ('EURGAAPADJ','UKGAAP_ADJ') 
                    AND (
                     (JL.TRANSACTION_CCY = JL.FUNCTIONAL_CCY AND JL.TRANSACTION_AMT <> JL.FUNCTIONAL_AMT)
                        OR              
                        ( JL.REPORTING_AMT <> 0 OR JL.FUNCTIONAL_CCY <> CASE JL.LEDGER_CD
                                WHEN 'EURGAAPADJ'
                                    THEN 'EUR'
                                    ELSE 'GBP'
                                END
                            )
                            )
                )                            

            OR (                       
            ( vdl.VALIDATION_CD = 'jl-trans_vs_reporting_amt' AND NVL(jl.chartfield_1,' ') <> 'DNP') AND
            JL.LEDGER_CD not in ('EURGAAPADJ','UKGAAP_ADJ')                       
                AND (
                        ( 
                            JL.REPORTING_AMT <> 0 and JL.TRANSACTION_AMT <> 0
                            AND JL.TRANSACTION_CCY = JL.REPORTING_CCY
                            AND JL.REPORTING_CCY = 'USD'
                            AND (JL.REPORTING_AMT <> JL.TRANSACTION_AMT) 
                        )           
                        OR (JL.FUNCTIONAL_AMT <> 0 OR REPORTING_CCY <> 'USD')
                    )
);            

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-usd-trans-vs-reportingt-amt', 'sql%rowcount', NULL, sql%rowcount, NULL);

    END;

    PROCEDURE pr_journal_line_bval
        (
            p_step_run_sid IN NUMBER
        )
    AS
    BEGIN
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-rval-balanced-output-functional-sum', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jlsra.functional_amt) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    jl.FEED_UUID AS FEED_UUID,
                    jl.CORRELATION_ID AS CORRELATION_ID,
                    jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                    jl.FUNCTIONAL_CCY AS FUNCTIONAL_CCY,
                    SUM(jl.FUNCTIONAL_AMT) AS functional_amt
                FROM
                    journal_line jl
                    INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                WHERE
                    not exists (
               select
                      null
                 from
                      stn.standardisation_log sl
                where
                      sl.row_in_error_key_id = jl.ROW_SID
           )
                GROUP BY
                    jl.FEED_UUID,
                    jl.CORRELATION_ID,
                    jl.ACCOUNTING_DT,
                    jl.FUNCTIONAL_CCY
                HAVING
                    SUM(jl.FUNCTIONAL_AMT) <> 0) jlsra ON jl.FEED_UUID = jlsra.FEED_UUID AND jl.CORRELATION_ID = jlsra.CORRELATION_ID AND jl.ACCOUNTING_DT = jlsra.ACCOUNTING_DT AND jl.FUNCTIONAL_CCY = jlsra.FUNCTIONAL_CCY
            WHERE
                    vdl.VALIDATION_CD = 'jl-functional_sum-rval-output'
and not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = jl.ROW_SID
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-rval-balanced-output-functional-sum', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-rval-balanced-output-reporting-sum', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jlsra.reporting_amt) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    jl.FEED_UUID AS FEED_UUID,
                    jl.CORRELATION_ID AS CORRELATION_ID,
                    jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                    jl.REPORTING_CCY AS REPORTING_CCY,
                    SUM(jl.REPORTING_AMT) AS reporting_amt
                FROM
                    journal_line jl
                    INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                WHERE
                    not exists (
               select
                      null
                 from
                      stn.standardisation_log sl
                where
                      sl.row_in_error_key_id = jl.ROW_SID
           )
                GROUP BY
                    jl.FEED_UUID,
                    jl.CORRELATION_ID,
                    jl.ACCOUNTING_DT,
                    jl.REPORTING_CCY
                HAVING
                    SUM(jl.REPORTING_AMT) <> 0) jlsra ON jl.FEED_UUID = jlsra.FEED_UUID AND jl.CORRELATION_ID = jlsra.CORRELATION_ID AND jl.ACCOUNTING_DT = jlsra.ACCOUNTING_DT AND jl.REPORTING_CCY = jlsra.REPORTING_CCY
            WHERE
                    vdl.VALIDATION_CD = 'jl-reporting_sum-rval-output'
and not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = jl.ROW_SID
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-rval-balanced-output-reporting-sum', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-rval-balanced-output-transaction-sum', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jlsra.transaction_amt) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    jl.FEED_UUID AS FEED_UUID,
                    jl.CORRELATION_ID AS CORRELATION_ID,
                    jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                    jl.TRANSACTION_CCY AS TRANSACTION_CCY,
                    SUM(jl.TRANSACTION_AMT) AS transaction_amt
                FROM
                    journal_line jl
                    INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                WHERE
                    not exists (
               select
                      null
                 from
                      stn.standardisation_log sl
                where
                      sl.row_in_error_key_id = jl.ROW_SID
           )
                GROUP BY
                    jl.FEED_UUID,
                    jl.CORRELATION_ID,
                    jl.ACCOUNTING_DT,
                    jl.TRANSACTION_CCY
                HAVING
                    SUM(jl.TRANSACTION_AMT) <> 0) jlsra ON jl.FEED_UUID = jlsra.FEED_UUID AND jl.CORRELATION_ID = jlsra.CORRELATION_ID AND jl.ACCOUNTING_DT = jlsra.ACCOUNTING_DT AND jl.TRANSACTION_CCY = jlsra.TRANSACTION_CCY
            WHERE
                    vdl.VALIDATION_CD = 'jl-transaction_sum-rval-output'
and not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = jl.ROW_SID
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-rval-balanced-output-transaction-sum', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-rval-balanced-header-functional-sum', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jlsra.functional_amt) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    jl.FEED_UUID AS FEED_UUID,
                    jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                    jl.FUNCTIONAL_CCY AS FUNCTIONAL_CCY,
                    SUM(jl.FUNCTIONAL_AMT) AS functional_amt
                FROM
                    journal_line jl
                    INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                WHERE
                    not exists (
               select
                      null
                 from
                      stn.standardisation_log sl
                where
                      sl.row_in_error_key_id = jl.ROW_SID
           )
                GROUP BY
                    jl.FEED_UUID,
                    jl.ACCOUNTING_DT,
                    jl.FUNCTIONAL_CCY,
                    jl.EVENT_TYP,
                    jl.LE_ID
                HAVING
                    SUM(jl.FUNCTIONAL_AMT) <> 0) jlsra ON jl.FEED_UUID = jlsra.FEED_UUID AND jl.ACCOUNTING_DT = jlsra.ACCOUNTING_DT AND jl.FUNCTIONAL_CCY = jlsra.FUNCTIONAL_CCY
            WHERE
                    vdl.VALIDATION_CD = 'jl-functional_sum-rval-headers'
and not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = jl.ROW_SID
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-rval-balanced-header-functional-sum', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-rval-balanced-headers-reporting-sum', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jlsra.reporting_amt) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    jl.FEED_UUID AS FEED_UUID,
                    jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                    jl.REPORTING_CCY AS REPORTING_CCY,
                    SUM(jl.REPORTING_AMT) AS reporting_amt
                FROM
                    journal_line jl
                    INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                WHERE
                    not exists (
               select
                      null
                 from
                      stn.standardisation_log sl
                where
                      sl.row_in_error_key_id = jl.ROW_SID
           )
                GROUP BY
                    jl.FEED_UUID,
                    jl.ACCOUNTING_DT,
                    jl.REPORTING_CCY,
                    jl.EVENT_TYP,
                    jl.LE_ID
                HAVING
                    SUM(jl.REPORTING_AMT) <> 0) jlsra ON jl.FEED_UUID = jlsra.FEED_UUID AND jl.ACCOUNTING_DT = jlsra.ACCOUNTING_DT AND jl.REPORTING_CCY = jlsra.REPORTING_CCY
            WHERE
                    vdl.VALIDATION_CD = 'jl-reporting_sum-rval-headers'
and not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = jl.ROW_SID
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-rval-balanced-headers-reporting-sum', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : journal-line-validate-rval-balanced-headers-transaction-sum', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(jlsra.transaction_amt) AS ERROR_VALUE,
                jl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                jl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    jl.FEED_UUID AS FEED_UUID,
                    jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                    jl.TRANSACTION_CCY AS TRANSACTION_CCY,
                    SUM(jl.TRANSACTION_AMT) AS transaction_amt
                FROM
                    journal_line jl
                    INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                WHERE
                    not exists (
               select
                      null
                 from
                      stn.standardisation_log sl
                where
                      sl.row_in_error_key_id = jl.ROW_SID
           )
                GROUP BY
                    jl.FEED_UUID,
                    jl.ACCOUNTING_DT,
                    jl.TRANSACTION_CCY,
                    jl.EVENT_TYP,
                    jl.LE_ID
                HAVING
                    SUM(jl.TRANSACTION_AMT) <> 0) jlsra ON jl.FEED_UUID = jlsra.FEED_UUID AND jl.ACCOUNTING_DT = jlsra.ACCOUNTING_DT AND jl.TRANSACTION_CCY = jlsra.TRANSACTION_CCY
            WHERE
                    vdl.VALIDATION_CD = 'jl-transaction_sum-rval-headers'
and not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = jl.ROW_SID
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : journal-line-validate-rval-balanced-headers-transaction-sum', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;

    PROCEDURE pr_journal_line_svs
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

    PROCEDURE pr_journal_line_pub
        (
            p_total_no_published OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO hopper_journal_line
            (le_id, acct_cd, ledger_cd, basis_cd, book_cd, affiliate_le_id, accident_yr, underwriting_yr, policy_id, stream_id, tax_jurisdiction_cd, posting_schema, counterparty_le_id, dept_cd, chartfield_1, execution_typ, business_typ, owner_le_id, premium_typ, journal_descr, transaction_ccy, transaction_amt, sra_ae_dr_cr, accounting_dt, ultimate_parent_le_id, event_typ, functional_ccy, functional_amt, reporting_ccy, reporting_amt, business_event_typ, event_seq_id, sra_ae_source_system, sra_ae_itsc_inst_typ_sclss_cd, event_status, lpg_id, process_id, message_id, sra_ae_posting_date, sra_ae_instr_type_map_code, sra_si_account_sys_inst_code, sra_si_instr_sys_inst_code, sra_si_party_sys_inst_code, sra_si_static_sys_inst_code, sra_ae_ipe_int_entity_code, sra_ae_pbu_ext_party_code, sra_ae_aet_acc_event_type_code, sra_ae_cu_local_currency_code, sra_ae_cu_base_currency_code, sra_ae_i_instrument_clicode, sra_ae_it_instr_type_code, sra_ae_itc_inst_typ_cls_code, sra_ae_pe_person_code, sra_ae_gl_instrument_id, sra_ae_event_audit_id, sra_ae_journal_type, sra_ae_source_jrnl_id, sra_ae_gl_narrative)
            SELECT
                pl_le_id.PL_PARTY_LEGAL_ID AS le_id,
                jl.ACCT_CD AS acct_cd,
                jl.LEDGER_CD AS ledger_cd,
                jl.BASIS_CD AS basis_cd,
                pl_le_id.PL_PARTY_LEGAL_ID AS book_cd,
                pl_affiliate.PL_PARTY_LEGAL_ID AS affiliate_le_id,
                jl.ACCIDENT_YR AS accident_yr,
                jl.UNDERWRITING_YR AS underwriting_yr,
                jl.POLICY_ID AS policy_id,
                jl.STREAM_ID AS stream_id,
                jl.TAX_JURISDICTION_CD AS tax_jurisdiction_cd,
                jl.LEDGER_CD AS posting_schema,
                pl_counter_party.PL_PARTY_LEGAL_ID AS counterparty_le_id,
                jl.DEPT_CD AS dept_cd,
                jl.CHARTFIELD_1 AS chartfield_1,
                jl.EXECUTION_TYP AS execution_typ,
                jl.BUSINESS_TYP AS business_typ,
                pl_owner_le_id.PL_PARTY_LEGAL_ID AS owner_le_id,
                NVL(jl.PREMIUM_TYP, 'NVS') AS premium_typ,
                jl.JOURNAL_DESCR AS journal_descr,
                jl.TRANSACTION_CCY AS transaction_ccy,
                jl.TRANSACTION_AMT AS transaction_amt,
                (CASE
                    WHEN jl.TRANSACTION_AMT < 0 THEN 'CR'
                    WHEN jl.TRANSACTION_AMT > 0 THEN 'DR'
                    WHEN jl.REPORTING_AMT < 0 THEN 'CR'
                    WHEN jl.REPORTING_AMT > 0 THEN 'DR'
                    WHEN jl.FUNCTIONAL_AMT < 0 THEN 'CR'
                    ELSE 'DR'
                END) AS sra_ae_dr_cr,
                jl.ACCOUNTING_DT AS accounting_dt,
                pl_ultimate_parent_le_id.PL_PARTY_LEGAL_ID AS ultimate_parent_le_id,
                jl.EVENT_TYP AS event_typ,
                jl.FUNCTIONAL_CCY AS functional_ccy,
                jl.FUNCTIONAL_AMT AS functional_amt,
                jl.REPORTING_CCY AS reporting_ccy,
                jl.REPORTING_AMT AS reporting_amt,
                jl.BUSINESS_EVENT_TYP AS business_event_typ,
                jl.EVENT_SEQ_ID AS event_seq_id,
                jl.JRNL_SOURCE AS sra_ae_source_system,
                jl_default.SRA_AE_ITSC_INST_TYP_SCLSS_CD AS sra_ae_itsc_inst_typ_sclss_cd,
                'U' AS event_status,
                jl.LPG_ID AS lpg_id,
                TO_CHAR(jl.STEP_RUN_SID) AS process_id,
                TO_CHAR(jl.ROW_SID) AS message_id,
                least(jl.ACCOUNTING_DT,gp.GP_TODAYS_BUS_DATE) AS sra_ae_posting_date,
                jl_default.SRA_AE_INSTR_TYPE_MAP_CODE AS sra_ae_instr_type_map_code,
                jl_default.SRA_SI_ACCOUNT_SYS_INST_CODE AS sra_si_account_sys_inst_code,
                jl_default.SRA_SI_INSTR_SYS_INST_CODE AS sra_si_instr_sys_inst_code,
                jl_default.SRA_SI_PARTY_SYS_INST_CODE AS sra_si_party_sys_inst_code,
                jl_default.SRA_SI_STATIC_SYS_INST_CODE AS sra_si_static_sys_inst_code,
                jl_default.SRA_AE_IPE_INT_ENTITY_CODE AS sra_ae_ipe_int_entity_code,
                pl_counter_party.PL_PARTY_LEGAL_ID AS sra_ae_pbu_ext_party_code,
                jl.EVENT_TYP AS sra_ae_aet_acc_event_type_code,
                jl_default.SRA_AE_CU_LOCAL_CURRENCY_CODE AS sra_ae_cu_local_currency_code,
                jl_default.SRA_AE_CU_BASE_CURRENCY_CODE AS sra_ae_cu_base_currency_code,
                jl_default.SRA_AE_I_INSTRUMENT_CLICODE AS sra_ae_i_instrument_clicode,
                jl_default.SRA_AE_IT_INSTR_TYPE_CODE AS sra_ae_it_instr_type_code,
                jl_default.SRA_AE_ITC_INST_TYP_CLS_CODE AS sra_ae_itc_inst_typ_cls_code,
                jl_default.SRA_AE_PE_PERSON_CODE AS sra_ae_pe_person_code,
                jl_default.SRA_AE_GL_INSTRUMENT_ID AS sra_ae_gl_instrument_id,
                jl.CORRELATION_ID AS sra_ae_event_audit_id,
                jl.JOURNAL_TYPE AS sra_ae_journal_type,
                to_char(jl.ROW_SID) AS sra_ae_source_jrnl_id,
                jl.JOURNAL_LINE_DESC AS sra_ae_gl_narrative
            FROM
                journal_line jl
                INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                INNER JOIN journal_line_default jl_default ON 1 = 1
                INNER JOIN fdr.FR_PARTY_LEGAL pl_le_id ON jl.LE_ID = to_number ( pl_le_id.PL_GLOBAL_ID )
                LEFT OUTER JOIN fdr.FR_PARTY_LEGAL pl_owner_le_id ON jl.OWNER_LE_ID = to_number ( pl_owner_le_id.PL_GLOBAL_ID )
                LEFT OUTER JOIN fdr.FR_PARTY_LEGAL pl_ultimate_parent_le_id ON jl.ULTIMATE_PARENT_LE_ID = to_number ( pl_ultimate_parent_le_id.PL_GLOBAL_ID )
                LEFT OUTER JOIN fdr.FR_PARTY_LEGAL pl_counter_party ON jl.COUNTERPARTY_LE_ID = to_number ( pl_counter_party.PL_GLOBAL_ID )
                LEFT OUTER JOIN fdr.FR_PARTY_LEGAL pl_affiliate ON jl.AFFILIATE_LE_ID = to_number ( pl_affiliate.PL_GLOBAL_ID )
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON jl.LPG_ID = gp.LPG_ID
            WHERE
                jl.EVENT_STATUS = 'V';
        p_total_no_published := SQL%ROWCOUNT;
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

    PROCEDURE pr_journal_line_pce
        (
            p_step_run_sid IN NUMBER
        )
    AS
        lcUnitName CONSTANT VARCHAR2(50) DEFAULT 'pCombinationCheck_JLH';
        lcViewName CONSTANT VARCHAR2(50) DEFAULT 'scv_combination_check_jlh';
        lcErrorCode_Combo CONSTANT VARCHAR2(50) DEFAULT 'JL_COMBO';
        v_combo_check_errors NUMBER(38, 9);
    BEGIN
         dbms_application_info.set_module(
            module_name => lcUnitName,
            action_name => 'Start');
          fdr.PG_COMMON.pLogDebug(pinMessage => 'Start Combo Check - GUI Unposted Journal Lines');

          /* Configure the optimizer hints for Combination Checking. */
          -- fdr.PG_COMBINATION_CHECK.gSQLHint_DeleteComboInput := '';
          -- fdr.PG_COMBINATION_CHECK.gSQLHint_DeleteComboError := '';
          -- fdr.PG_COMBINATION_CHECK.gSQLHint_InsertInput      := '/*+ no_parallel */';
          -- fdr.PG_COMBINATION_CHECK.gSQLHint_SelectInput      := '/*+ parallel */';
          -- fdr.PG_COMBINATION_CHECK.gSQLHint_InsertComboError := '/*+ no_parallel */';
          -- fdr.PG_COMBINATION_CHECK.gSQLHint_SelectComboError := '/*+ parallel */';

          /* Call the Combination Check for those journals that are not in error yet - use the [sub-]partitioning key. */
          fdr.PG_COMBINATION_CHECK.pCombinationCheck(
            pinObjectName   =>  'stn.scv_combination_check_jlh',
            pinFilter       =>  NULL,
            pinBusinessDate =>  NULL,
            poutErrorCount  =>  v_combo_check_errors);

        IF v_combo_check_errors > 0 THEN
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Combo Check Validations : journal-line Combo failure begin logging', 'sql%rowcount', NULL, sql%rowcount, NULL);
            INSERT INTO STANDARDISATION_LOG
                (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, EVENT_TEXT, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
                SELECT
                    vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                    jl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                    jl.ACCT_CD AS ERROR_VALUE,
                    jl.LPG_ID AS LPG_ID,
                    vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                    cce.ce_attribute_name AS FIELD_IN_ERROR_NAME,
                    rveld.EVENT_TYPE AS EVENT_TYPE,
                    rveld.ERROR_STATUS AS ERROR_STATUS,
                    rveld.CATEGORY_ID AS CATEGORY_ID,
                    rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                    rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                    cce.ce_rule AS RULE_IDENTITY,
                    vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                    jl.STEP_RUN_SID AS STEP_RUN_SID,
                    fd.FEED_SID AS FEED_SID
                FROM
                    journal_line jl
                    INNER JOIN IDENTIFIED_RECORD idr ON jl.ROW_SID = idr.ROW_SID
                    INNER JOIN FEED fd ON jl.FEED_UUID = fd.FEED_UUID
                    INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                    INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                    INNER JOIN fdr.fr_combination_check_error cce ON to_char(jl.ROW_SID) = cce.ce_input_id
                WHERE
                    vdl.VALIDATION_CD = 'jl-prc_cd';
            v_combo_check_errors := SQL%ROWCOUNT;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Combo Edit Failures: Logged Errors', 'sql%rowcount', NULL, sql%rowcount, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Combo Edit Failures: Logging any correlated rorror', 'sql%rowcount', NULL, sql%rowcount, NULL);
            INSERT INTO STANDARDISATION_LOG
                (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
                SELECT
                    vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                    jl2.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                    jl2.ACCT_CD AS ERROR_VALUE,
                    jl2.LPG_ID AS LPG_ID,
                    SubQuery.error_value AS FIELD_IN_ERROR_NAME,
                    rveld.EVENT_TYPE AS EVENT_TYPE,
                    rveld.ERROR_STATUS AS ERROR_STATUS,
                    rveld.CATEGORY_ID AS CATEGORY_ID,
                    rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                    rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                    SubQuery.error_rule AS RULE_IDENTITY,
                    vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                    jl2.STEP_RUN_SID AS STEP_RUN_SID,
                    'COMBO EDIT Correlated' AS EVENT_TEXT,
                    fd.FEED_SID AS FEED_SID
                FROM
                    journal_line jl2
                    INNER JOIN IDENTIFIED_RECORD idr ON jl2.ROW_SID = idr.ROW_SID
                    INNER JOIN FEED fd ON jl2.FEED_UUID = fd.FEED_UUID
                    INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                    INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                    LEFT OUTER JOIN fdr.fr_combination_check_error cce ON to_char(jl2.ROW_SID) = cce.ce_input_id
                    INNER JOIN (SELECT
                        j.ROW_SID AS ROW_SID
                    FROM
                        journal_line j
                        INNER JOIN (SELECT
                            jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                            jl.CORRELATION_ID AS CORRELATION_ID,
                            jl.LE_ID AS LE_ID,
                            SUM(jl.TRANSACTION_AMT) AS TRANSACTION_AMT
                        FROM
                            journal_line jl
                            INNER JOIN fdr.fr_combination_check_error ce ON 1 = 1
                        WHERE
                            to_char(jl.ROW_SID) <> ce.ce_input_id
                        GROUP BY
                            jl.CORRELATION_ID,
                            jl.ACCOUNTING_DT,
                            jl.LE_ID
                        HAVING
                            SUM (nvl(jl.transaction_amt,0)+nvl(jl.functional_amt,0)+nvl(jl.reporting_amt,0)) <> 0) jl ON j.CORRELATION_ID = jl.CORRELATION_ID AND j.ACCOUNTING_DT = jl.ACCOUNTING_DT AND j.LE_ID = jl.LE_ID
                    WHERE
                        NOT EXISTS
(SELECT NULL FROM fdr.fr_combination_check_error e   WHERE E.ce_input_id = j.ROW_SID)) jl3 ON jl2.ROW_SID = jl3.ROW_SID
                    INNER JOIN (SELECT
                        jle.ce_attribute_name AS error_value,
                        jle.ce_rule AS error_rule,
                        jl.ACCOUNTING_DT AS ACCOUNTING_DT,
                        jl.CORRELATION_ID AS CORRELATION_ID,
                        jl.LE_ID AS LE_ID,
                        jl.ROW_SID AS ROW_SID
                    FROM
                        journal_line jl
                        INNER JOIN (SELECT
                            jl.ACCOUNTING_DT AS jl_ACCOUNTING_DT_1,
                            jl.CORRELATION_ID AS jl_CORRELATION_ID_1,
                            jl.LE_ID AS jl_LE_ID_1
                        FROM
                            journal_line jl
                            INNER JOIN fdr.fr_combination_check_error ce ON 1 = 1
                        WHERE
                            to_char(jl.ROW_SID) <> ce.ce_input_id
                        GROUP BY
                            jl.CORRELATION_ID,
                            jl.ACCOUNTING_DT,
                            jl.LE_ID) j ON jl.CORRELATION_ID = j.jl_CORRELATION_ID_1 AND jl.ACCOUNTING_DT = j.jl_ACCOUNTING_DT_1 AND jl.LE_ID = j.jl_LE_ID_1
                        INNER JOIN fdr.fr_combination_check_error jle ON to_number(jle.ce_input_id)=jl.ROW_SID
                    WHERE
                        EXISTS
(SELECT jle.ce_input_id FROM fdr.fr_combination_check_error je WHERE je.ce_input_id = jl.ROW_SID)) SubQuery ON jl2.CORRELATION_ID = SubQuery.CORRELATION_ID AND jl2.ACCOUNTING_DT = SubQuery.ACCOUNTING_DT AND jl2.LE_ID = SubQuery.LE_ID
                WHERE
                    vdl.VALIDATION_CD = 'jl-prc_cd'
AND NOT EXISTS (SELECT cce.ce_input_id FROM fdr.fr_combination_check_error je2 WHERE je2.ce_input_id = jl2.ROW_SID);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Combo Edit Failures: Logged any correlated errorsr', 'sql%rowcount', NULL, sql%rowcount, NULL);
        ELSE
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed Combo Edit Checks: No Failures', 'sql%rowcount', NULL, sql%rowcount, NULL);
        END IF;
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
        v_total_no_published NUMBER(38, 9) DEFAULT 0;
        v_no_updated_hopper_records NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify journal line records' );
        pr_journal_line_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Process Combo Edit checks on journal line records' );
            pr_journal_line_pce(p_step_run_sid);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed combo edit checks', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set level validate journal line records' );
            pr_journal_line_sval(p_step_run_sid);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed set level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate journal line records' );
            pr_journal_line_rval(p_step_run_sid);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed journal line row level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Check rval output is balanced' );
            pr_journal_line_bval(p_step_run_sid);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed checking that the passed records balance', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set journal line status = "V"' );
            pr_journal_line_svs(v_no_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status', 'v_no_validated_records', NULL, v_no_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish journal line records' );
            pr_journal_line_pub(v_total_no_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing journal line hopper records', 'v_total_no_published', NULL, v_total_no_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish journal line log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set journal line status = "P"' );
            pr_journal_line_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_processed_records', NULL, v_no_processed_records, NULL);
            IF v_no_processed_records <> v_no_validated_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_processed_records <> v_no_validated_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            IF v_total_no_published <> v_no_validated_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_total_no_published <> v_no_validated_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 2' );
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
/