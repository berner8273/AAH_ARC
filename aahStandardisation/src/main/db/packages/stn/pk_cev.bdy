CREATE OR REPLACE PACKAGE BODY stn.PK_CEV AS
    PROCEDURE pr_cession_event_idf
        (
            p_lpg_id IN NUMBER,
            p_step_run_sid IN NUMBER,
            p_no_identified_records OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO IDENTIFIED_RECORD
            (ROW_SID)
            SELECT
                ce.ROW_SID AS ROW_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
            WHERE
                    ce.event_status = 'U'
and ce.lpg_id       = p_lpg_id
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
        UPDATE CESSION_EVENT ce
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  ce.row_sid = ce.row_sid
       );
        p_no_identified_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_cession_event_pub
    AS
    BEGIN
        INSERT INTO HOPPER_CESSION_EVENT
            (BUSINESS_UNIT, AFFILIATE_LE_CD, ACCOUNTING_DT, ACCIDENT_YR, UNDERWRITING_YR, POLICY_ID, ULTIMATE_PARENT_STREAM_ID, TAX_JURISDICTION_CD, EVENT_TYP, TRANSACTION_CCY, TRANSACTION_AMT, BUSINESS_TYP, POLICY_TYP, PREMIUM_TYP, SUB_EVENT, IS_MARK_TO_MARKET, VIE_CD, LPG_ID, PARTY_BUSINESS_LE_CD, PARTY_BUSINESS_SYSTEM_CD, AAH_EVENT_TYP, SRAE_STATIC_SYS_INST_CODE, SRAE_INSTR_SYS_INST_CODE, TRANSACTION_POS_NEG, SRAE_GL_PERSON_CODE, DEPT_CD, SRAE_SOURCE_SYSTEM, SRAE_INSTR_SUPER_CLASS, SRAE_INSTRUMENT_CODE, LEDGER_CD, STREAM_ID, POSTING_DT, BOOK_CD, CORRELATION_UUID, CHARTFIELD_1, COUNTERPARTY_LE_CD, EXECUTION_TYP, OWNER_LE_ID, JOURNAL_DESCR, FUNCTIONAL_CCY, FUNCTIONAL_AMT, REPORTING_CCY, REPORTING_AMT, BUSINESS_EVENT_TYP, EVENT_SEQ_ID, BASIS_CD)
            SELECT
                cep.BUSINESS_UNIT AS BUSINESS_UNIT,
                cep.AFFILIATE AS AFFILIATE_LE_CD,
                cep.ACCOUNTING_DT AS ACCOUNTING_DT,
                cep.POLICY_ACCIDENT_YR AS ACCIDENT_YR,
                cep.POLICY_UNDERWRITING_YR AS UNDERWRITING_YR,
                cep.POLICY_ID AS POLICY_ID,
                cep.ULTIMATE_PARENT_STREAM_ID AS ULTIMATE_PARENT_STREAM_ID,
                ce_default.TAX_JURISDICTION AS TAX_JURISDICTION_CD,
                cep.EVENT_TYP AS EVENT_TYP,
                cep.TRANSACTION_CCY AS TRANSACTION_CCY,
                cep.TRANSACTION_AMT AS TRANSACTION_AMT,
                cep.BUSINESS_TYP AS BUSINESS_TYP,
                cep.POLICY_TYP AS POLICY_TYP,
                cep.PREMIUM_TYP AS PREMIUM_TYP,
                cep.SUB_EVENT AS SUB_EVENT,
                cep.IS_MARK_TO_MARKET AS IS_MARK_TO_MARKET,
                cep.VIE_CD AS VIE_CD,
                cep.LPG_ID AS LPG_ID,
                cep.BUSINESS_UNIT AS PARTY_BUSINESS_LE_CD,
                ce_default.SYSTEM_INSTANCE AS PARTY_BUSINESS_SYSTEM_CD,
                cep.EVENT_TYP AS AAH_EVENT_TYP,
                ce_default.SYSTEM_INSTANCE AS SRAE_STATIC_SYS_INST_CODE,
                ce_default.SYSTEM_INSTANCE AS SRAE_INSTR_SYS_INST_CODE,
                (CASE
                    WHEN cep.TRANSACTION_AMT > 0 THEN 'POS'
                    ELSE 'NEG'
                END) AS TRANSACTION_POS_NEG,
                ce_default.SRAE_GL_PERSON_CODE AS SRAE_GL_PERSON_CODE,
                cep.BUSINESS_UNIT AS DEPT_CD,
                ce_default.SRAE_SOURCE_SYSTEM AS SRAE_SOURCE_SYSTEM,
                ce_default.SRAE_INSTR_SUPER_CLASS AS SRAE_INSTR_SUPER_CLASS,
                ce_default.SRAE_INSTRUMENT_CODE AS SRAE_INSTRUMENT_CODE,
                cep.LEDGER_CD AS LEDGER_CD,
                cep.STREAM_ID AS STREAM_ID,
                cep.ACCOUNTING_DT AS POSTING_DT,
                cep.BUSINESS_UNIT AS BOOK_CD,
                cep.CORRELATION_UUID AS CORRELATION_UUID,
                NULL AS CHARTFIELD_1,
                cep.AFFILIATE AS COUNTERPARTY_LE_CD,
                cep.EXECUTION_TYP AS EXECUTION_TYP,
                cep.BUSINESS_UNIT AS OWNER_LE_ID,
                NULL AS JOURNAL_DESCR,
                cep.FUNCTIONAL_CCY AS FUNCTIONAL_CCY,
                cep.FUNCTIONAL_AMT AS FUNCTIONAL_AMT,
                cep.REPORTING_CCY AS REPORTING_CCY,
                cep.REPORTING_AMT AS REPORTING_AMT,
                cep.BUSINESS_EVENT_TYP AS BUSINESS_EVENT_TYP,
                1 AS EVENT_SEQ_ID,
                cep.BASIS_CD AS BASIS_CD
            FROM
                CESSION_EVENT_POSTING cep
                INNER JOIN CE_DEFAULT ON 1 = 1;
    END;
    
    PROCEDURE pr_cession_event_rval
        (
            p_step_run_sid IN NUMBER
        )
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                TO_CHAR(ce.STREAM_ID) AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-stream_id'
and not exists (
                   select
                          null
                     from
                          stn.insurance_policy_reference ipr
                    where
                          ipr.stream_id = ce.STREAM_ID
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.BASIS_CD AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-basis_cd'
and not exists (
                   select
                          null
                     from
                          fdr.fr_gaap fg
                    where
                          fg.fga_gaap_id = ce.BASIS_CD
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.TRANSACTION_CCY AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN CE_DEFAULT ced ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-transaction_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = ce.TRANSACTION_CCY
                      and fcl.cul_sil_sys_inst_clicode = ced.SYSTEM_INSTANCE
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.FUNCTIONAL_CCY AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN CE_DEFAULT ced ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-functional_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = ce.FUNCTIONAL_CCY
                      and fcl.cul_sil_sys_inst_clicode = ced.SYSTEM_INSTANCE
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.REPORTING_CCY AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN CE_DEFAULT ced ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-reporting_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = ce.REPORTING_CCY
                      and fcl.cul_sil_sys_inst_clicode = ced.SYSTEM_INSTANCE
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.EVENT_TYP AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-event_typ'
and not exists (
                   select
                          null
                     from
                          fdr.fr_acc_event_type faet
                    where
                          faet.aet_acc_event_type_id = ce.EVENT_TYP
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.BUSINESS_EVENT_TYP AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-business_event_typ'
and not exists (
                   select
                          null
                     from
                          fdr.fr_general_lookup fgl
                    where
                          fgl.LK_LKT_LOOKUP_TYPE_CODE = 'ACCOUNTING_EVENT'
                      and fgl.LK_LOOKUP_VALUE2        = ce.BUSINESS_EVENT_TYP
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Loaded records to stn.standardisation_log', 'sql%rowcount', NULL, sql%rowcount, NULL);
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                "ce-validate-correlation-uuid".CATEGORY_ID AS CATEGORY_ID,
                "ce-validate-correlation-uuid".ERROR_STATUS AS ERROR_STATUS,
                "ce-validate-correlation-uuid".ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                "ce-validate-correlation-uuid".error_value AS ERROR_VALUE,
                "ce-validate-correlation-uuid".event_text AS EVENT_TEXT,
                "ce-validate-correlation-uuid".EVENT_TYPE AS EVENT_TYPE,
                "ce-validate-correlation-uuid".field_in_error_name AS FIELD_IN_ERROR_NAME,
                "ce-validate-correlation-uuid".LPG_ID AS LPG_ID,
                "ce-validate-correlation-uuid".PROCESSING_STAGE AS PROCESSING_STAGE,
                "ce-validate-correlation-uuid".row_in_error_key_id AS ROW_IN_ERROR_KEY_ID,
                "ce-validate-correlation-uuid".table_in_error_name AS TABLE_IN_ERROR_NAME,
                "ce-validate-correlation-uuid".rule_identity AS RULE_IDENTITY,
                "ce-validate-correlation-uuid".CODE_MODULE_NM AS CODE_MODULE_NM,
                "ce-validate-correlation-uuid".STEP_RUN_SID AS STEP_RUN_SID,
                "ce-validate-correlation-uuid".FEED_SID AS FEED_SID
            FROM
                (SELECT
                    vdl.TABLE_NM AS table_in_error_name,
                    ce.ROW_SID AS row_in_error_key_id,
                    'Correlated record invalid' AS error_value,
                    ce.LPG_ID AS LPG_ID,
                    vdl.COLUMN_NM AS field_in_error_name,
                    rveld.EVENT_TYPE AS EVENT_TYPE,
                    rveld.ERROR_STATUS AS ERROR_STATUS,
                    rveld.CATEGORY_ID AS CATEGORY_ID,
                    rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                    rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                    vdl.VALIDATION_CD AS rule_identity,
                    gp.GP_TODAYS_BUS_DATE AS todays_business_dt,
                    fd.SYSTEM_CD AS SYSTEM_CD,
                    vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                    ce.STEP_RUN_SID AS STEP_RUN_SID,
                    vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                    fd.FEED_SID AS FEED_SID
                FROM
                    CESSION_EVENT ce
                    INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                    INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                    INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                    INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                    INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                WHERE
                        vdl.VALIDATION_CD = 'ce-correlation_uuid'
and exists (
       select
              null
         from
              stn.standardisation_log sl
         join 
              stn.cession_event ce2 on 
            ( sl.row_in_error_key_id = ce.ROW_SID
          and sl.step_run_sid = ce.STEP_RUN_SID )
        where 
              ce.correlation_uuid = ce2.correlation_uuid
            )
and not exists (
       select
              null
         from
              stn.standardisation_log sl3
        where 
              ce.ROW_SID = sl3.row_in_error_key_id
            )) "ce-validate-correlation-uuid";
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Loaded correlated records to stn.standardisation_log', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_cession_event_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE CESSION_EVENT ce
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                  stn.hopper_cession_event hce
            where
                  hce.correlation_uuid = ce.CORRELATION_UUID
           );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_cession_event_svs
        (
            p_step_run_sid IN NUMBER,
            p_no_errored_records OUT NUMBER,
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE CESSION_EVENT ce
            SET
                EVENT_STATUS = 'E'
            WHERE
                       exists (
                  select
                         null
                    from
                         stn.standardisation_log sl
                   where
                         sl.table_in_error_name = 'cession_event'
                     and sl.row_in_error_key_id = ce.row_sid
              );
        p_no_errored_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of cession_event records set to error', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE CESSION_EVENT ce
            SET
                EVENT_STATUS = 'V'
            WHERE
                ce.EVENT_STATUS = 'U';
        p_no_validated_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of cession_event records set to passed validation', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_cession_event_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_updated_hopper_records NUMBER(38, 9) DEFAULT 0;
        v_no_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_errored_records NUMBER(38, 9) DEFAULT 0;
        v_no_processed_records NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify cession event records' );
        pr_cession_event_idf(p_lpg_id, p_step_run_sid, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified cession event records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate cession event records' );
            pr_cession_event_rval(p_step_run_sid);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set cession event status = "V"' );
            pr_cession_event_svs(p_step_run_sid, v_no_errored_records, v_no_validated_records);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish cession event records' );
            pr_cession_event_pub;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set cession event status = "P"' );
            pr_cession_event_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_processed_records', NULL, v_no_processed_records, NULL);
            IF v_no_validated_records <> v_no_processed_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_validated_records != v_no_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := v_no_errored_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_CEV;
/