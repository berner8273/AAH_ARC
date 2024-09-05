CREATE OR REPLACE PACKAGE BODY STN.PK_GCE AS
    PROCEDURE pr_gl_combo_edit_rval
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                gcea.LE_CD AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                gcea.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                gcea.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                gcea.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                GL_COMBO_EDIT_ASSIGNMENT gcea
                INNER JOIN GL_COMBO_EDIT_PROCESS gcep ON gcea.PRC_CD = gcep.PRC_CD AND gcea.FEED_UUID = gcep.FEED_UUID
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON gcea.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON gcea.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'gcea-le_cd'
and not exists (
                   select
                          null
                     from
                          fdr.fr_party_legal fpl
                    where
                          fpl.pl_party_legal_clicode = gcea.LE_CD
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                gcea.LEDGER_CD AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                gcea.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                gcea.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                gcea.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                GL_COMBO_EDIT_ASSIGNMENT gcea
                INNER JOIN GL_COMBO_EDIT_PROCESS gcep ON gcea.PRC_CD = gcep.PRC_CD AND gcea.FEED_UUID = gcep.FEED_UUID
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON gcea.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON gcea.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'gcea-ledger_cd'
and not exists (
                   select
                          null
                     from
                          fdr.fr_posting_schema fps
                    where
                          fps.ps_posting_schema = gcea.LEDGER_CD
               );
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                SubQuery.CATEGORY_ID AS CATEGORY_ID,
                SubQuery.ERROR_STATUS AS ERROR_STATUS,
                SubQuery.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                SubQuery.error_value AS ERROR_VALUE,
                SubQuery.event_text AS EVENT_TEXT,
                SubQuery.EVENT_TYPE AS EVENT_TYPE,
                SubQuery.field_in_error_name AS FIELD_IN_ERROR_NAME,
                SubQuery.LPG_ID AS LPG_ID,
                SubQuery.PROCESSING_STAGE AS PROCESSING_STAGE,
                SubQuery.row_in_error_key_id AS ROW_IN_ERROR_KEY_ID,
                SubQuery.table_in_error_name AS TABLE_IN_ERROR_NAME,
                SubQuery.rule_identity AS RULE_IDENTITY,
                SubQuery.CODE_MODULE_NM AS CODE_MODULE_NM,
                SubQuery.STEP_RUN_SID AS STEP_RUN_SID,
                SubQuery.FEED_SID AS FEED_SID
            FROM
                (SELECT
                    vdl.TABLE_NM AS table_in_error_name,
                    gcer.ROW_SID AS row_in_error_key_id,
                    gcer.ACCT_CD AS error_value,
                    gcer.LPG_ID AS LPG_ID,
                    vdl.COLUMN_NM AS field_in_error_name,
                    rveld.EVENT_TYPE AS EVENT_TYPE,
                    rveld.ERROR_STATUS AS ERROR_STATUS,
                    rveld.CATEGORY_ID AS CATEGORY_ID,
                    rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                    rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                    vdl.VALIDATION_CD AS rule_identity,
                    FR_GLOBAL_PARAMETER.GP_TODAYS_BUS_DATE AS todays_business_dt,
                    fd.SYSTEM_CD AS SYSTEM_CD,
                    vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                    gcer.STEP_RUN_SID AS STEP_RUN_SID,
                    vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                    fd.FEED_SID AS FEED_SID
                FROM
                    GL_COMBO_EDIT_RULE gcer
                    INNER JOIN GL_COMBO_EDIT_PROCESS gcep ON gcer.PRC_CD = gcep.PRC_CD AND gcer.FEED_UUID = gcep.FEED_UUID
                    INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                    INNER JOIN FEED fd ON gcer.FEED_UUID = fd.FEED_UUID
                    INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON gcer.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                    INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                    INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                WHERE
                        vdl.VALIDATION_CD = 'gcer-acct_cd'
and not exists (
                   select
                          null
                     from
                          fdr.fr_gl_account fga
                    where
                          fga.ga_client_text4 = gcer.acct_cd
               )) SubQuery;
    END;

    PROCEDURE pr_gl_combo_edit_sps
        (
            p_step_run_sid IN NUMBER,
            p_no_gcea_processed_records OUT NUMBER,
            p_no_gcep_processed_records OUT NUMBER,
            p_no_gcer_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE GL_COMBO_EDIT_ASSIGNMENT gcea
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                 fdr.fr_stan_raw_general_codes  fsrgc
             join
                 fdr.fr_party_legal             fpl   on gcea.LE_CD = fpl.PL_PARTY_LEGAL_CLICODE
             join
                 stn.gl_combo_edit_process      gcep  on gcea.PRC_CD = gcep.PRC_CD
                                                     and gcea.FEED_UUID = gcep.FEED_UUID
             join
                 stn.identified_record          idr   on gcep.row_sid = idr.row_sid
             join
                 stn.gce_default                gced  on 1 = 1
           where fsrgc.event_status      = 'U'
             and fsrgc.process_id        = gcea.STEP_RUN_SID
       )
;
        p_no_gcea_processed_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting processed status for gcea', 'p_no_gcea_processed_records', NULL, p_no_gcea_processed_records, NULL);
        UPDATE GL_COMBO_EDIT_PROCESS gcep
            SET
                EVENT_STATUS = 'P'
            WHERE
                        exists (
                   select
                  null
             from
                 stn.gl_combo_edit_process   gcep
             join
                 (select distinct gcep.PRC_CD,gcep.FEED_UUID from stn.gl_combo_edit_assignment) da
                 on da.prc_cd = gcep.PRC_CD and gcep.FEED_UUID = da.feed_uuid
             join
                 stn.identified_record          idr   on gcep.ROW_SID = idr.row_sid
              where gcep.EVENT_STATUS='V'
        )
and gcep.EVENT_STATUS='V';
        p_no_gcep_processed_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting processed status for gcep', 'p_no_gcep_processed_records', NULL, p_no_gcea_processed_records, NULL);
        UPDATE GL_COMBO_EDIT_RULE gcer
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                 fdr.fr_stan_raw_general_codes  fsrgc
            join stn.gl_combo_edit_process      gcep   on to_char(trunc(to_number(fsrgc.message_id))) = to_char(gcep.row_sid)||to_char(gcer.ROW_SID)
                                                      and gcep.feed_uuid = gcer.FEED_UUID
            join stn.identified_record          idr    on gcep.row_sid = idr.row_sid
       );
        p_no_gcer_processed_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting processed status for gcer', 'p_no_gcer_processed_records', NULL, p_no_gcer_processed_records, NULL);
    END;

    PROCEDURE pr_gl_combo_edit_svs
        (
            p_step_run_sid IN NUMBER,
            p_no_gcea_errored_records OUT NUMBER,
            p_no_gcea_validated_records OUT NUMBER,
            p_no_gcep_errored_records OUT NUMBER,
            p_no_gcep_validated_records OUT NUMBER,
            p_no_gcer_errored_records OUT NUMBER,
            p_no_gcer_validated_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE GL_COMBO_EDIT_ASSIGNMENT gcea
            SET
                EVENT_STATUS = 'E'
            WHERE
                exists (
           select
                  null
             from
                  stn.standardisation_log sl
            where
                  sl.row_in_error_key_id = gcea.ROW_SID
       );
        p_no_gcea_errored_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting error status for gcea', 'p_no_gcea_errored_records', NULL, p_no_gcea_errored_records, NULL);
        UPDATE GL_COMBO_EDIT_ASSIGNMENT gcea
            SET
                EVENT_STATUS = 'V'
            WHERE
                    not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = gcea.ROW_SID
               )
and     exists (
                   select
                          null
                     from
                          stn.identified_record idr
                        , stn.gl_combo_edit_process gcep
                    where
                          gcep.row_sid = idr.row_sid
                      and gcep.prc_cd  = gcea.prc_cd
                      and gcep.feed_uuid = gcea.feed_uuid
               );
        p_no_gcea_validated_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting valid status for gcea', 'p_no_gcea_validated_records', NULL, p_no_gcea_validated_records, NULL);
        UPDATE GL_COMBO_EDIT_PROCESS gcep
            SET
                EVENT_STATUS = 'E'
            WHERE
                exists (
           select
                  null
             from
                  stn.standardisation_log sl
            where
                  sl.row_in_error_key_id = gcep.ROW_SID
       );
        p_no_gcep_errored_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting error status for gcep', 'p_no_gcep_errored_records', NULL, p_no_gcep_errored_records, NULL);
        UPDATE GL_COMBO_EDIT_PROCESS gcep
            SET
                EVENT_STATUS = 'V'
            WHERE
                    not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = gcep.ROW_SID
               )
and     exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          gcep.ROW_SID = idr.row_sid
               );
        p_no_gcep_validated_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting valid status for gcep', 'p_no_gcep_validated_records', NULL, p_no_gcep_validated_records, NULL);
        UPDATE GL_COMBO_EDIT_RULE gcer
            SET
                EVENT_STATUS = 'E'
            WHERE
                exists (
           select
                  null
             from
                  stn.standardisation_log sl
            where
                  sl.row_in_error_key_id = gcer.ROW_SID
       );
        p_no_gcer_errored_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting error status for gcer', 'p_no_gcer_errored_records', NULL, p_no_gcer_errored_records, NULL);
        UPDATE GL_COMBO_EDIT_RULE gcer
            SET
                EVENT_STATUS = 'V'
            WHERE
                    not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = gcer.ROW_SID
               )
and     exists (
                   select
                          null
                     from
                          stn.identified_record idr
                        , stn.gl_combo_edit_process gcep
                    where
                          gcep.row_sid = idr.row_sid
                      and gcep.prc_cd  = gcer.PRC_CD
                      and gcep.feed_uuid = gcer.feed_uuid
               );
        p_no_gcer_validated_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting valid status for gcer', 'p_no_gcer_validated_records', NULL, p_no_gcer_validated_records, NULL);
    END;

    PROCEDURE pr_gl_combo_edit_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_total_no_fsrgc_updated OUT NUMBER,
            p_total_no_fsrgl_updated OUT NUMBER
        )
    AS
    BEGIN
        UPDATE HOPPER_GL_COMBO_EDIT_GC hgcegc
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                hgcegc.EVENT_STATUS <> 'P' AND hgcegc.LPG_ID = p_lpg_id;
        p_total_no_fsrgc_updated := SQL%ROWCOUNT;
        UPDATE HOPPER_GL_COMBO_EDIT_GL hgcegl
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                hgcegl.EVENT_STATUS <> 'P' AND hgcegl.LPG_ID = p_lpg_id;
        p_total_no_fsrgl_updated := SQL%ROWCOUNT;
    END;

    PROCEDURE pr_gl_combo_edit_idf
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_gcep_identified_recs OUT NUMBER,
            p_no_gcea_identified_recs OUT NUMBER,
            p_no_gcer_identified_recs OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO IDENTIFIED_RECORD
            (ROW_SID)
            SELECT
                gcep.ROW_SID AS ROW_SID
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN FEED ON gcep.FEED_UUID = feed.FEED_UUID
            WHERE
                    gcep.EVENT_STATUS = 'U'
and gcep.LPG_ID       = p_lpg_id
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
        UPDATE GL_COMBO_EDIT_PROCESS gcep
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  gcep.row_sid = idr.row_sid
       );
        p_no_gcep_identified_recs := SQL%ROWCOUNT;
        UPDATE GL_COMBO_EDIT_ASSIGNMENT gcea
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
                , stn.gl_combo_edit_process gcep
            where
                  gcep.row_sid   = idr.row_sid
              and gcea.PRC_CD    = gcep.prc_cd
              and gcea.feed_uuid = gcep.feed_uuid
       );
        p_no_gcea_identified_recs := SQL%ROWCOUNT;
        UPDATE GL_COMBO_EDIT_RULE gcer
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
                , stn.gl_combo_edit_process gcep
            where
                  gcep.row_sid   = idr.row_sid
              and gcer.PRC_CD    = gcep.prc_cd
              and gcer.feed_uuid = gcep.feed_uuid
       );
        p_no_gcer_identified_recs := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated GL combo edit.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;

    PROCEDURE pr_gl_combo_edit_pub
        (
            p_step_run_sid IN NUMBER,
            p_no_fsrgl_combo_ruleset_pub OUT NUMBER,
            p_no_fsrgl_combo_appl_1_pub OUT NUMBER,
            p_no_fsrgl_combo_appl_2_pub OUT NUMBER,
            p_no_fsrgl_combo_appl_3_pub OUT NUMBER,
            p_no_fsrgl_combo_check_pub OUT NUMBER,
            p_no_fsrgc_acct_pub OUT NUMBER,
            p_no_fsrgc_le_pub OUT NUMBER,
            p_no_fsrgc_ledger_pub OUT NUMBER,
            p_no_fsrgc_affiliate_pub OUT NUMBER,
            p_no_fsrgc_department_pub OUT NUMBER,
            p_no_fsrgc_product_pub OUT NUMBER,
            p_no_fgct_inserted OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO HOPPER_GL_COMBO_EDIT_GC
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_SET_CD, COMBO_SET_VALUE, COMBO_EDIT_STS, EVENT_STATUS, VALID_FROM, VALID_TO, COMBO_VALUE_TYPE)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(ce_p.ROW_SID) || TO_CHAR(gcep.ROW_SID) || '.1' AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE1 AS COMBO_SET_CD,
                ce_r.ACCT_CD AS COMBO_SET_VALUE,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS VALID_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS VALID_TO,
                GCE_DEFAULT.ATTRIBUTE_TYP2 AS COMBO_VALUE_TYPE
            FROM
                GL_COMBO_EDIT_RULE gcep
                INNER JOIN GL_COMBO_EDIT_PROCESS ce_p ON gcep.PRC_CD = ce_p.PRC_CD
                INNER JOIN IDENTIFIED_RECORD idr ON ce_p.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
                INNER JOIN (SELECT DISTINCT
                    gcea.EVENT_STATUS AS EVENT_STATUS,
                    gcea.FEED_UUID AS FEED_UUID,
                    gcea.ACCT_CD AS ACCT_CD,
                    gcea.LPG_ID AS LPG_ID,
                    gcea.NO_RETRIES AS NO_RETRIES,
                    gcea.PRC_CD AS PRC_CD,
                    gcea.STEP_RUN_SID AS STEP_RUN_SID,
                    MIN(gcea.ROW_SID) AS ROW_SID
                FROM
                    GL_COMBO_EDIT_RULE gcea
                GROUP BY
                    gcea.PRC_CD,
                    gcea.ACCT_CD,
                    gcea.LPG_ID,
                    gcea.EVENT_STATUS,
                    gcea.FEED_UUID,
                    gcea.NO_RETRIES,
                    gcea.STEP_RUN_SID) ce_r ON gcep.PRC_CD = ce_r.PRC_CD AND gcep.FEED_UUID = ce_r.FEED_UUID AND ce_r.ACCT_CD = gcep.ACCT_CD
            WHERE
                gcep.EVENT_STATUS = 'V' AND ce_r.EVENT_STATUS = 'V';
        p_no_fsrgc_acct_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GL
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_RULE_OR_SET, COMBO_EDIT_STS, EVENT_STATUS, COMBO_RULE_TYP, COMBO_ATTR_OR_RULE, COMBO_ACTION, EFFECTIVE_FROM, EFFECTIVE_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) || TO_CHAR(gcea.ROW_SID) || '.2' AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                gcea.LEDGER_CD || '_' || gcea.LE_CD AS COMBO_RULE_OR_SET,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.LKT_CODE1 AS COMBO_RULE_TYP,
                gcep.PRC_CD AS COMBO_ATTR_OR_RULE,
                GCE_DEFAULT.ACTION AS COMBO_ACTION,
                GCE_DEFAULT.EFFECTIVE_FROM AS EFFECTIVE_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS EFFECTIVE_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
                INNER JOIN (SELECT DISTINCT
                    gcea.EVENT_STATUS AS EVENT_STATUS,
                    gcea.FEED_UUID AS FEED_UUID,
                    gcea.LE_CD AS LE_CD,
                    gcea.LEDGER_CD AS LEDGER_CD,
                    gcea.LPG_ID AS LPG_ID,
                    gcea.NO_RETRIES AS NO_RETRIES,
                    gcea.PRC_CD AS PRC_CD,
                    gcea.STEP_RUN_SID AS STEP_RUN_SID,
                    MIN(gcea.ROW_SID) AS ROW_SID
                FROM
                    GL_COMBO_EDIT_ASSIGNMENT gcea
                GROUP BY
                    gcea.PRC_CD,
                    gcea.LE_CD,
                    gcea.LPG_ID,
                    gcea.EVENT_STATUS,
                    gcea.FEED_UUID,
                    gcea.NO_RETRIES,
                    gcea.STEP_RUN_SID,
                    gcea.LEDGER_CD) gcea ON gcep.PRC_CD = gcea.PRC_CD AND gcep.FEED_UUID = gcea.FEED_UUID
            WHERE
                    gcep.EVENT_STATUS = 'V'
and gcea.EVENT_STATUS = 'V'
and not exists (
            select null from stn.HOPPER_GL_COMBO_EDIT_GL hgl
                where hgl.combo_rule_or_set = gcea.LEDGER_CD || '_' || gcea.LE_CD and
                     hgl.combo_rule_typ = GCE_DEFAULT.LKT_CODE1 and
                     hgl.combo_attr_or_rule = gcep.PRC_CD
                     )
;
        p_no_fsrgc_le_pub := SQL%ROWCOUNT;
        INSERT INTO fdr.FR_GENERAL_CODE_TYPES
            (GCT_CODE_TYPE_ID, GCT_CODE_TYPE_NAME, GCT_CLIENT_CODE_TYPE, GCT_ACTIVE, GCT_INPUT_BY, GCT_INPUT_TIME, GCT_VALID_FROM, GCT_VALID_TO)
            SELECT
                fsrgc.SRGC_GCT_CODE_TYPE_ID AS GCT_CODE_TYPE_ID,
                fsrgc.SRGC_GCT_CODE_TYPE_ID AS GCT_CODE_TYPE_NAME,
                NULL AS GCT_CLIENT_CODE_TYPE,
                'A' AS GCT_ACTIVE,
                'FDR' AS GCT_INPUT_BY,
                CURRENT_DATE AS GCT_INPUT_TIME,
                CURRENT_DATE AS GCT_VALID_FROM,
                '2099-12-31' AS GCT_VALID_TO
            FROM
                (SELECT DISTINCT
                    fsrgc.SRGC_GCT_CODE_TYPE_ID AS SRGC_GCT_CODE_TYPE_ID
                FROM
                    fdr.FR_STAN_RAW_GENERAL_CODES fsrgc
                WHERE
                    fsrgc.SRGC_GCT_CODE_TYPE_ID LIKE 'COMBO%') fsrgc
            WHERE
                not exists
       (SELECT
            null
        FROM
            fdr.FR_GENERAL_CODE_TYPES fgct,
            fdr.FR_STAN_RAW_GENERAL_CODES fsrgc2
        WHERE
            fgct.GCT_CODE_TYPE_ID = fsrgc2.SRGC_GCT_CODE_TYPE_ID
        and fsrgc2.SRGC_GCT_CODE_TYPE_ID = fsrgc.SRGC_GCT_CODE_TYPE_ID
        and fsrgc2.SRGC_GCT_CODE_TYPE_ID like 'COMBO%');
    END;

    PROCEDURE pr_gl_combo_edit_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_gcea_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcep_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcer_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcea_errored_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcea_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcep_errored_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcep_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcer_errored_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcer_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcea_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcep_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcer_processed_records NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrgc_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrgl_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrgc_updated NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrgl_updated NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgl_combo_ruleset_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgl_combo_appl_1_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgl_combo_appl_2_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgl_combo_appl_3_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgl_combo_check_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgc_acct_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgc_le_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgc_ledger_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgc_affiliate_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgc_department_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fsrgc_product_pub NUMBER(38, 9) DEFAULT 0;
        v_no_fgct_inserted NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
        s_proc_name VARCHAR2(80) := 'STN.pk_gce.pr_gl_combo_edit_prc';
        gv_ecode     NUMBER := -20001;
        gv_emsg VARCHAR(10000);
        s_exception_name VARCHAR2(80);


    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify GL combo edit process records' );
        pr_gl_combo_edit_idf(p_step_run_sid, p_lpg_id, v_no_gcep_identified_records, v_no_gcea_identified_records, v_no_gcer_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_gcep_identified_records + v_no_gcea_identified_records + v_no_gcer_identified_records, NULL);
        IF v_no_gcep_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed hopper records' );
            pr_gl_combo_edit_chr(p_step_run_sid, p_lpg_id, v_total_no_fsrgc_updated, v_total_no_fsrgl_updated);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed GL Combo Edit General Code hopper records', 'v_total_no_fsrgc_updated', NULL, v_total_no_fsrgc_updated, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed GL Combo Edit General lookup hopper records', 'v_total_no_fsrgl_updated', NULL, v_total_no_fsrgl_updated, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validation gl combo edit records' );
            pr_gl_combo_edit_rval;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations for gl combo edit records', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set gl combo edit status = "V"' );
            pr_gl_combo_edit_svs(p_step_run_sid, v_no_gcea_errored_records, v_no_gcea_validated_records, v_no_gcep_errored_records, v_no_gcep_validated_records, v_no_gcer_errored_records, v_no_gcer_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status for gl combo edit', 'Total validated records', NULL, v_no_gcea_validated_records + v_no_gcep_validated_records + v_no_gcer_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish gl combo edit records' );
            pr_gl_combo_edit_pub(p_step_run_sid, v_no_fsrgl_combo_ruleset_pub, v_no_fsrgl_combo_appl_1_pub, v_no_fsrgl_combo_appl_2_pub, v_no_fsrgl_combo_appl_3_pub, v_no_fsrgl_combo_check_pub, v_no_fsrgc_acct_pub, v_no_fsrgc_le_pub, v_no_fsrgc_ledger_pub, v_no_fsrgc_affiliate_pub, v_no_fsrgc_department_pub, v_no_fsrgc_product_pub, v_no_fgct_inserted);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing general lookup hopper records', 'v_total_no_fsrgl_published', NULL, v_no_fsrgl_combo_appl_1_pub + v_no_fsrgl_combo_appl_2_pub + v_no_fsrgl_combo_appl_3_pub + v_no_fsrgl_combo_check_pub + v_no_fsrgl_combo_ruleset_pub, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing general code hopper records', 'v_total_no_fsrgc_published', NULL, v_no_fsrgc_acct_pub + v_no_fsrgc_affiliate_pub + v_no_fsrgc_department_pub + v_no_fsrgc_le_pub + v_no_fsrgc_ledger_pub + v_no_fsrgc_product_pub, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed inserting general code type records', 'v_no_fgct_inserted', NULL, v_no_fgct_inserted, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish gl combo edit log records' );
            pr_publish_log('STANDARDISATION_LOG');
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set gl combo edit assignment status = "P"' );
            pr_gl_combo_edit_sps(p_step_run_sid, v_no_gcea_processed_records, v_no_gcep_processed_records, v_no_gcer_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting processed status for gl combo edit records', 'Total processed records', NULL, v_no_gcea_processed_records + v_no_gcep_processed_records + v_no_gcer_processed_records, NULL);

            IF v_no_gcep_validated_records <> v_no_gcep_processed_records THEN
                s_exception_name := 'Raise pub_val_mismatch - 1';
                raise pub_val_mismatch;
            END IF;
            IF v_no_gcea_validated_records <> v_no_gcea_processed_records THEN
                s_exception_name := 'Raise pub_val_mismatch - 2';
                raise pub_val_mismatch;
            END IF;
            IF v_no_gcer_validated_records <> v_no_gcer_processed_records THEN
                s_exception_name := 'Raise pub_val_mismatch - 3';
                raise pub_val_mismatch;
            END IF;

            p_no_processed_records := v_no_gcep_processed_records
                                    + v_no_gcer_processed_records
                                    + v_no_gcea_processed_records;
            p_no_failed_records    := v_no_gcep_identified_records
                                    + v_no_gcer_identified_records
                                    + v_no_gcea_identified_records
                                    - v_no_gcep_processed_records
                                    - v_no_gcer_processed_records
                                    - v_no_gcea_processed_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;

        EXCEPTION
                WHEN pub_val_mismatch THEN
                    pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : '||s_exception_name, NULL, NULL, NULL, NULL);
                    dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => s_exception_name );
                    gv_emsg := 'Failure in ' || s_proc_name  || ': '|| sqlerrm;
                    RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg||' '||s_exception_name);
                WHEN OTHERS THEN
                    ROLLBACK;
                    gv_emsg := 'Failure in ' || s_proc_name  || ': '|| sqlerrm;
                    RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

    END;


END PK_GCE;
/