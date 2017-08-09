
CREATE OR REPLACE PACKAGE BODY stn.PK_GCE AS
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
                  gcep.row_sid = idr.row_sid
              and gcea.PRC_CD = gcep.prc_cd
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
                  gcep.row_sid = idr.row_sid
              and gcer.PRC_CD = gcep.prc_cd
       );
        p_no_gcer_identified_recs := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated GL combo edit.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_gl_combo_edit_process_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE GL_COMBO_EDIT_PROCESS gcep
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       fdr.fr_stan_raw_general_lookup fsrgl
                  join stn.identified_record   idr   on to_number ( fsrgl.message_id ) = idr.row_sid
            where
                  idr.row_sid = gcep.ROW_SID
              and fsrgl.SRLK_LKT_LOOKUP_TYPE_CODE = 'COMBO_RULESET'
       );
        p_no_processed_records := SQL%ROWCOUNT;
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
        INSERT INTO HOPPER_GL_COMBO_EDIT_GL
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_RULE_TYP, COMBO_RULE_OR_SET, COMBO_ATTR_OR_RULE, COMBO_CONDITION, COMBO_CONDITION_TYP, COMBO_SET_CD, COMBO_ACTION, COMBO_EDIT_STS, EVENT_STATUS, EFFECTIVE_FROM, EFFECTIVE_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                GCE_DEFAULT.LKT_CODE1 AS COMBO_RULE_TYP,
                GCE_DEFAULT.RULE_SET AS COMBO_RULE_OR_SET,
                gcep.PRC_CD AS COMBO_ATTR_OR_RULE,
                NULL AS COMBO_CONDITION,
                NULL AS COMBO_CONDITION_TYP,
                NULL AS COMBO_SET_CD,
                GCE_DEFAULT.ACTION AS COMBO_ACTION,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS EFFECTIVE_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS EFFECTIVE_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
            WHERE
                gcep.EVENT_STATUS = 'V';
        p_no_fsrgl_combo_ruleset_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GL
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_RULE_TYP, COMBO_RULE_OR_SET, COMBO_ATTR_OR_RULE, COMBO_CONDITION, COMBO_CONDITION_TYP, COMBO_SET_CD, COMBO_ACTION, COMBO_EDIT_STS, EVENT_STATUS, EFFECTIVE_FROM, EFFECTIVE_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                GCE_DEFAULT.LKT_CODE2 AS COMBO_RULE_TYP,
                gcep.PRC_CD AS COMBO_RULE_OR_SET,
                'ci_attribute_' || GCE_DEFAULT.ATTRIBUTE1 AS COMBO_ATTR_OR_RULE,
                'IN' AS COMBO_CONDITION,
                'SET' AS COMBO_CONDITION_TYP,
                'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE1 AS COMBO_SET_CD,
                GCE_DEFAULT.ACTION AS COMBO_ACTION,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS EFFECTIVE_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS EFFECTIVE_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
            WHERE
                gcep.EVENT_STATUS = 'V';
        p_no_fsrgl_combo_appl_1_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GL
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_RULE_TYP, COMBO_RULE_OR_SET, COMBO_ATTR_OR_RULE, COMBO_CONDITION, COMBO_CONDITION_TYP, COMBO_SET_CD, COMBO_ACTION, COMBO_EDIT_STS, EVENT_STATUS, EFFECTIVE_FROM, EFFECTIVE_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                GCE_DEFAULT.LKT_CODE2 AS COMBO_RULE_TYP,
                gcep.PRC_CD AS COMBO_RULE_OR_SET,
                'ci_attribute_' || GCE_DEFAULT.ATTRIBUTE2 AS COMBO_ATTR_OR_RULE,
                'IN' AS COMBO_CONDITION,
                'SET' AS COMBO_CONDITION_TYP,
                'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE2 AS COMBO_SET_CD,
                GCE_DEFAULT.ACTION AS COMBO_ACTION,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS EFFECTIVE_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS EFFECTIVE_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
            WHERE
                gcep.EVENT_STATUS = 'V';
        p_no_fsrgl_combo_appl_2_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GL
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_RULE_TYP, COMBO_RULE_OR_SET, COMBO_ATTR_OR_RULE, COMBO_CONDITION, COMBO_CONDITION_TYP, COMBO_SET_CD, COMBO_ACTION, COMBO_EDIT_STS, EVENT_STATUS, EFFECTIVE_FROM, EFFECTIVE_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                GCE_DEFAULT.LKT_CODE2 AS COMBO_RULE_TYP,
                gcep.PRC_CD AS COMBO_RULE_OR_SET,
                'ci_attribute_' || GCE_DEFAULT.ATTRIBUTE3 AS COMBO_ATTR_OR_RULE,
                'IN' AS COMBO_CONDITION,
                'SET' AS COMBO_CONDITION_TYP,
                'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE3 AS COMBO_SET_CD,
                GCE_DEFAULT.ACTION AS COMBO_ACTION,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS EFFECTIVE_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS EFFECTIVE_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
            WHERE
                gcep.EVENT_STATUS = 'V';
        p_no_fsrgl_combo_appl_3_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GL
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_RULE_TYP, COMBO_RULE_OR_SET, COMBO_ATTR_OR_RULE, COMBO_CONDITION, COMBO_CONDITION_TYP, COMBO_SET_CD, COMBO_ACTION, COMBO_EDIT_STS, EVENT_STATUS, EFFECTIVE_FROM, EFFECTIVE_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                GCE_DEFAULT.LKT_CODE3 AS COMBO_RULE_TYP,
                gcep.PRC_CD AS COMBO_RULE_OR_SET,
                (CASE
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP4 THEN 'ci_attribute_' || GCE_DEFAULT.ATTRIBUTE4
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP5 THEN 'ci_attribute_' || GCE_DEFAULT.ATTRIBUTE5
                    ELSE 'ci_attribute_' || GCE_DEFAULT.ATTRIBUTE6
                END) AS COMBO_ATTR_OR_RULE,
                (CASE
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP4 AND gcer.DEPARTMENT = '%' THEN 'IN'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP4 AND gcer.DEPARTMENT <> '%' AND gcep.PRC_TYP = 'VALID' THEN 'NOT IN'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP5 AND gcer.PRODUCT = '%' THEN 'IN'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP5 AND gcer.PRODUCT <> '%' AND gcep.PRC_TYP = 'VALID' THEN 'NOT IN'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP6 AND gcer.AFFILIATE = '%' THEN 'IN'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP6 AND gcer.AFFILIATE <> '%' AND gcep.PRC_TYP = 'VALID' THEN 'NOT IN'
                    ELSE NULL
                END) AS COMBO_CONDITION,
                (CASE
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP4 AND gcer.DEPARTMENT = '%' AND gcep.PRC_TYP = 'VALID' THEN 'NOT NULL'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP4 AND gcer.DEPARTMENT = '%' AND gcep.PRC_TYP = 'INVALID' THEN 'NULL'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP4 AND gcer.DEPARTMENT <> '%' THEN 'SET'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP5 AND gcer.PRODUCT = '%' AND gcep.PRC_TYP = 'VALID' THEN 'NOT NULL'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP5 AND gcer.PRODUCT = '%' AND gcep.PRC_TYP = 'INVALID' THEN 'NULL'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP5 AND gcer.PRODUCT <> '%' THEN 'SET'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP6 AND gcer.AFFILIATE = '%' AND gcep.PRC_TYP = 'VALID' THEN 'NOT NULL'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP6 AND gcer.AFFILIATE = '%' AND gcep.PRC_TYP = 'INVALID' THEN 'NULL'
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP6 AND gcer.AFFILIATE <> '%' THEN 'SET'
                    ELSE NULL
                END) AS COMBO_CONDITION_TYP,
                (CASE
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP4 AND gcer.DEPARTMENT = '%' THEN NULL
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP4 AND gcer.DEPARTMENT <> '%' THEN 'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE4
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP5 AND gcer.PRODUCT = '%' THEN NULL
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP5 AND gcer.PRODUCT <> '%' THEN 'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE5
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP6 AND gcer.AFFILIATE = '%' THEN NULL
                    WHEN gcep.PRC_SUBJECT = GCE_DEFAULT.ATTRIBUTE_TYP6 AND gcer.AFFILIATE <> '%' THEN 'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE6
                END) AS COMBO_SET_CD,
                GCE_DEFAULT.ACTION AS COMBO_ACTION,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS EFFECTIVE_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS EFFECTIVE_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
                INNER JOIN (SELECT DISTINCT
                    gcer.EVENT_STATUS AS EVENT_STATUS,
                    gcer.FEED_UUID AS FEED_UUID,
                    gcer.DEPARTMENT AS DEPARTMENT,
                    gcer.PRODUCT AS PRODUCT,
                    gcer.AFFILIATE AS AFFILIATE,
                    gcer.LPG_ID AS LPG_ID,
                    gcer.NO_RETRIES AS NO_RETRIES,
                    gcer.PRC_CD AS PRC_CD,
                    gcer.STEP_RUN_SID AS STEP_RUN_SID
                FROM
                    GL_COMBO_EDIT_RULE gcer) gcer ON gcep.PRC_CD = gcer.PRC_CD
            WHERE
                gcep.EVENT_STATUS = 'V' AND gcer.EVENT_STATUS = 'V';
        p_no_fsrgl_combo_check_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GC
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_SET_CD, COMBO_SET_VALUE, COMBO_EDIT_STS, EVENT_STATUS, VALID_FROM, VALID_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) || TO_CHAR(gcer.ROW_SID) || '.2' AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE2 AS COMBO_SET_CD,
                gcer.ACCT_CD AS COMBO_SET_VALUE,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS VALID_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS VALID_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
                INNER JOIN GL_COMBO_EDIT_RULE gcer ON gcep.PRC_CD = gcer.PRC_CD
            WHERE
                gcep.EVENT_STATUS = 'V' AND gcer.EVENT_STATUS = 'V';
        p_no_fsrgc_acct_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GC
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_SET_CD, COMBO_SET_VALUE, COMBO_EDIT_STS, EVENT_STATUS, VALID_FROM, VALID_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) || TO_CHAR(gcea.ROW_SID) || '.1' AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE1 AS COMBO_SET_CD,
                TO_CHAR(gcea.LE_ID) AS COMBO_SET_VALUE,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS VALID_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS VALID_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
                INNER JOIN (SELECT DISTINCT
                    gcea.EVENT_STATUS AS EVENT_STATUS,
                    gcea.FEED_UUID AS FEED_UUID,
                    gcea.LE_ID AS LE_ID,
                    gcea.LPG_ID AS LPG_ID,
                    gcea.NO_RETRIES AS NO_RETRIES,
                    gcea.PRC_CD AS PRC_CD,
                    gcea.STEP_RUN_SID AS STEP_RUN_SID,
                    MIN(gcea.ROW_SID) AS ROW_SID
                FROM
                    GL_COMBO_EDIT_ASSIGNMENT gcea
                GROUP BY
                    gcea.PRC_CD,
                    gcea.LE_ID,
                    gcea.LPG_ID,
                    gcea.EVENT_STATUS,
                    gcea.FEED_UUID,
                    gcea.NO_RETRIES,
                    gcea.STEP_RUN_SID) gcea ON gcep.PRC_CD = gcea.PRC_CD
            WHERE
                gcep.EVENT_STATUS = 'V' AND gcea.EVENT_STATUS = 'V';
        p_no_fsrgc_le_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GC
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_SET_CD, COMBO_SET_VALUE, COMBO_EDIT_STS, EVENT_STATUS, VALID_FROM, VALID_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) || TO_CHAR(gcea.ROW_SID) || '.3' AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE3 AS COMBO_SET_CD,
                gcea.LEDGER_CD AS COMBO_SET_VALUE,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS VALID_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS VALID_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
                INNER JOIN (SELECT DISTINCT
                    gcea.EVENT_STATUS AS EVENT_STATUS,
                    gcea.FEED_UUID AS FEED_UUID,
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
                    gcea.LEDGER_CD,
                    gcea.LPG_ID,
                    gcea.EVENT_STATUS,
                    gcea.FEED_UUID,
                    gcea.NO_RETRIES,
                    gcea.STEP_RUN_SID) gcea ON gcep.PRC_CD = gcea.PRC_CD
            WHERE
                gcep.EVENT_STATUS = 'V' AND gcea.EVENT_STATUS = 'V';
        p_no_fsrgc_ledger_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GC
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_SET_CD, COMBO_SET_VALUE, COMBO_EDIT_STS, EVENT_STATUS, VALID_FROM, VALID_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) || TO_CHAR(gcer.ROW_SID) || '.6' AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE6 AS COMBO_SET_CD,
                gcer.AFFILIATE AS COMBO_SET_VALUE,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS VALID_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS VALID_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
                INNER JOIN (SELECT DISTINCT
                    gcer.EVENT_STATUS AS EVENT_STATUS,
                    gcer.FEED_UUID AS FEED_UUID,
                    gcer.AFFILIATE AS AFFILIATE,
                    gcer.LPG_ID AS LPG_ID,
                    gcer.NO_RETRIES AS NO_RETRIES,
                    gcer.PRC_CD AS PRC_CD,
                    gcer.STEP_RUN_SID AS STEP_RUN_SID,
                    MIN(gcer.ROW_SID) AS ROW_SID
                FROM
                    GL_COMBO_EDIT_RULE gcer
                GROUP BY
                    gcer.PRC_CD,
                    gcer.AFFILIATE,
                    gcer.LPG_ID,
                    gcer.EVENT_STATUS,
                    gcer.FEED_UUID,
                    gcer.NO_RETRIES,
                    gcer.STEP_RUN_SID) gcer ON gcep.PRC_CD = gcer.PRC_CD
            WHERE
                gcep.EVENT_STATUS = 'V' AND gcer.EVENT_STATUS = 'V' AND gcer.AFFILIATE <> '%';
        p_no_fsrgc_affiliate_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GC
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_SET_CD, COMBO_SET_VALUE, COMBO_EDIT_STS, EVENT_STATUS, VALID_FROM, VALID_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) || TO_CHAR(gcer.ROW_SID) || '.4' AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE4 AS COMBO_SET_CD,
                gcer.DEPARTMENT AS COMBO_SET_VALUE,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS VALID_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS VALID_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
                INNER JOIN (SELECT DISTINCT
                    gcer.EVENT_STATUS AS EVENT_STATUS,
                    gcer.FEED_UUID AS FEED_UUID,
                    gcer.DEPARTMENT AS DEPARTMENT,
                    gcer.LPG_ID AS LPG_ID,
                    gcer.NO_RETRIES AS NO_RETRIES,
                    gcer.PRC_CD AS PRC_CD,
                    gcer.STEP_RUN_SID AS STEP_RUN_SID,
                    MIN(gcer.ROW_SID) AS ROW_SID
                FROM
                    GL_COMBO_EDIT_RULE gcer
                GROUP BY
                    gcer.PRC_CD,
                    gcer.DEPARTMENT,
                    gcer.LPG_ID,
                    gcer.EVENT_STATUS,
                    gcer.FEED_UUID,
                    gcer.NO_RETRIES,
                    gcer.STEP_RUN_SID) gcer ON gcep.PRC_CD = gcer.PRC_CD
            WHERE
                gcep.EVENT_STATUS = 'V' AND gcer.EVENT_STATUS = 'V' AND gcer.DEPARTMENT <> '%';
        p_no_fsrgc_department_pub := SQL%ROWCOUNT;
        INSERT INTO HOPPER_GL_COMBO_EDIT_GC
            (LPG_ID, MESSAGE_ID, PROCESS_ID, COMBO_SET_CD, COMBO_SET_VALUE, COMBO_EDIT_STS, EVENT_STATUS, VALID_FROM, VALID_TO)
            SELECT
                gcep.LPG_ID AS LPG_ID,
                TO_CHAR(gcep.ROW_SID) || TO_CHAR(gcer.ROW_SID) || '.5' AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                'COMBO_' || gcep.PRC_CD || '_' || GCE_DEFAULT.ATTRIBUTE5 AS COMBO_SET_CD,
                gcer.PRODUCT AS COMBO_SET_VALUE,
                GCE_DEFAULT.ACTIVE_FLAG AS COMBO_EDIT_STS,
                GCE_DEFAULT.HOPPER_STATUS AS EVENT_STATUS,
                GCE_DEFAULT.EFFECTIVE_FROM AS VALID_FROM,
                GCE_DEFAULT.EFFECTIVE_TO AS VALID_TO
            FROM
                GL_COMBO_EDIT_PROCESS gcep
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN GCE_DEFAULT ON 1 = 1
                INNER JOIN (SELECT DISTINCT
                    gcer.EVENT_STATUS AS EVENT_STATUS,
                    gcer.FEED_UUID AS FEED_UUID,
                    gcer.PRODUCT AS PRODUCT,
                    gcer.LPG_ID AS LPG_ID,
                    gcer.NO_RETRIES AS NO_RETRIES,
                    gcer.PRC_CD AS PRC_CD,
                    gcer.STEP_RUN_SID AS STEP_RUN_SID,
                    MIN(gcer.ROW_SID) AS ROW_SID
                FROM
                    GL_COMBO_EDIT_RULE gcer
                GROUP BY
                    gcer.PRC_CD,
                    gcer.PRODUCT,
                    gcer.LPG_ID,
                    gcer.EVENT_STATUS,
                    gcer.FEED_UUID,
                    gcer.NO_RETRIES,
                    gcer.STEP_RUN_SID) gcer ON gcep.PRC_CD = gcer.PRC_CD
            WHERE
                gcep.EVENT_STATUS = 'V' AND gcer.EVENT_STATUS = 'V' AND gcer.PRODUCT <> '%';
        p_no_fsrgc_product_pub := SQL%ROWCOUNT;
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
        and fsrgc2.SRGC_GCT_CODE_TYPE_ID like 'COMBO%');
        p_no_fgct_inserted := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_combo_edit_rule_rval
    AS
    BEGIN
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
                    INNER JOIN GL_COMBO_EDIT_PROCESS gcep ON gcer.PRC_CD = gcep.PRC_CD
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
                         fga.ga_account_code = gcer.ACCT_CD
               )) SubQuery;
    END;
    
    PROCEDURE pr_gl_combo_edit_rule_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
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
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_combo_edit_rule_svs
        (
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
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
        p_no_validated_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_combo_edit_asgn_rval
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                TO_CHAR(gcea.LE_ID) AS error_value,
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
                INNER JOIN GL_COMBO_EDIT_PROCESS gcep ON gcea.PRC_CD = gcep.PRC_CD
                INNER JOIN IDENTIFIED_RECORD idr ON gcep.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON gcea.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON gcea.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'gcea-le_id'
and not exists (
                   select
                          null
                     from
                          fdr.fr_party_legal fpl
                    where
                          fpl.pl_global_id = gcea.LE_ID
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
                INNER JOIN GL_COMBO_EDIT_PROCESS gcep ON gcea.PRC_CD = gcep.PRC_CD
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
    END;
    
    PROCEDURE pr_gl_combo_edit_asgn_sps
        (
            p_no_processed_records OUT NUMBER
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
            join stn.gl_combo_edit_process      gcep   on to_char(trunc(to_number(fsrgc.message_id))) = to_char(gcep.row_sid)||to_char(gcea.ROW_SID)
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_combo_edit_asgn_svs
        (
            p_no_validated_records OUT NUMBER
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
        p_no_validated_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_combo_edit_process_svs
        (
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
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
        p_no_validated_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_combo_edit_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_gcep_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcea_validated_records NUMBER(38, 9) DEFAULT 0;
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
        v_no_gcea_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcer_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_gcep_validated_records NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify GL combo edit process records' );
        pr_gl_combo_edit_idf(p_step_run_sid, p_lpg_id, v_no_gcep_identified_records, v_no_gcea_identified_records, v_no_gcer_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_gcep_identified_records + v_no_gcea_identified_records + v_no_gcer_identified_records, NULL);
        IF v_no_gcep_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed hopper records' );
            pr_gl_combo_edit_chr(p_step_run_sid, p_lpg_id, v_total_no_fsrgc_updated, v_total_no_fsrgl_updated);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed GL Combo Edit General Code hopper records', 'v_total_no_fsrgc_updated', NULL, v_total_no_fsrgc_updated, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed GL Combo Edit General lookup hopper records', 'v_total_no_fsrgl_updated', NULL, v_total_no_fsrgl_updated, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate GL Combo Edit Assignment records' );
            pr_gl_combo_edit_asgn_rval;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations for gl-combo-edit-assignments', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate gl-combo-edit-rule records' );
            pr_gl_combo_edit_rule_rval;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations for gl-combo-edit-rule', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set gl-combo-edit-assignment status = "V"' );
            pr_gl_combo_edit_asgn_svs(v_no_gcea_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status for gl-combo-edit-assignment', 'v_no_gcea_validated_records', NULL, v_no_gcea_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set gl-combo-edit-rule status = "V"' );
            pr_gl_combo_edit_rule_svs(v_no_gcer_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status for gl-combo-edit-rule', 'v_no_gcer_validated_records', NULL, v_no_gcer_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set gl-combo-edit-rule status = "V"' );
            pr_gl_combo_edit_process_svs(v_no_gcep_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status for gl-combo-edit-rule', 'v_no_gcer_validated_records', NULL, v_no_gcer_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish gl combo edit records' );
            pr_gl_combo_edit_pub(p_step_run_sid, v_no_fsrgl_combo_ruleset_pub, v_no_fsrgl_combo_appl_1_pub, v_no_fsrgl_combo_appl_2_pub, v_no_fsrgl_combo_appl_3_pub, v_no_fsrgl_combo_check_pub, v_no_fsrgc_acct_pub, v_no_fsrgc_le_pub, v_no_fsrgc_ledger_pub, v_no_fsrgc_affiliate_pub, v_no_fsrgc_department_pub, v_no_fsrgc_product_pub, v_no_fgct_inserted);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing general lookup hopper records', 'v_total_no_fsrgl_published', NULL, v_no_fsrgl_combo_appl_1_pub + v_no_fsrgl_combo_appl_2_pub + v_no_fsrgl_combo_appl_3_pub + v_no_fsrgl_combo_check_pub + v_no_fsrgl_combo_ruleset_pub, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing general code hopper records', 'v_total_no_fsrgc_published', NULL, v_no_fsrgc_acct_pub + v_no_fsrgc_affiliate_pub + v_no_fsrgc_department_pub + v_no_fsrgc_le_pub + v_no_fsrgc_ledger_pub + v_no_fsrgc_product_pub, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing general code type records', 'v_no_fgct_inserted', NULL, v_no_fgct_inserted, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish gl combo edit log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set gl combo edit assignment status = "P"' );
            pr_gl_combo_edit_asgn_sps(v_no_gcea_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status for gl combo edit assignment records', 'v_no_gcea_processed_records', NULL, v_no_gcea_processed_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set gl combo edit process status = "P"' );
            pr_gl_combo_edit_process_sps(v_no_gcep_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status for gl combo edit process records', 'v_no_gcep_processed_records', NULL, v_no_gcep_processed_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set gl combo edit rule status = "P"' );
            pr_gl_combo_edit_rule_sps(v_no_gcer_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status gl combo edit rule records', 'v_no_gcer_processed_records', NULL, v_no_gcer_processed_records, NULL);
            IF 1 <> 1 THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_gcea_validated_records <> v_no_gcea_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            IF 1 <> 1 THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_gcer_validated_records <> v_no_gcer_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 2' );
                raise pub_val_mismatch;
            END IF;
            IF v_no_gcep_identified_records <> v_no_gcep_processed_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_gcep_identified_records <> v_no_gcep_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 3' );
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
    END;
END PK_GCE;
/