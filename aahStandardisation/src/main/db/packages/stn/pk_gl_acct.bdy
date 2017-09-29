CREATE OR REPLACE PACKAGE BODY stn.PK_GL_ACCT AS
    PROCEDURE pr_gl_account_idf
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
                gla.ROW_SID AS ROW_SID
            FROM
                GL_ACCOUNT gla
                INNER JOIN FEED ON gla.FEED_UUID = feed.FEED_UUID
                INNER JOIN (SELECT
                    gla.ACCT_CD AS acct_cd,
                    MAX(gla.EFFECTIVE_DT) AS effective_dt
                FROM
                    GL_ACCOUNT gla
                    INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON gla.LPG_ID = fgp.LPG_ID
                WHERE
                    gla.ACCT_STS = 'A' AND gla.EVENT_STATUS = 'U' AND gla.EFFECTIVE_DT <= fgp.GP_TODAYS_BUS_DATE
                GROUP BY
                    gla.ACCT_CD) "most-recent-records" ON gla.ACCT_CD = "most-recent-records".acct_cd AND gla.EFFECTIVE_DT = "most-recent-records".effective_dt
            WHERE
                    gla.EVENT_STATUS = 'U'
and gla.LPG_ID       = p_lpg_id
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
        UPDATE GL_ACCOUNT gla
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  gla.row_sid = idr.row_sid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated gl_account.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE GL_ACCOUNT gla
            SET
                EVENT_STATUS = 'X',
                STEP_RUN_SID = p_step_run_sid
            WHERE
                    gla.EVENT_STATUS = 'U'
and not exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          gla.row_sid = idr.row_sid
               )
and not exists (
                   select
                          null
                     from
                               stn.broken_feed bf
                          join stn.feed        fd on bf.feed_sid = fd.feed_sid
                    where
                          fd.feed_uuid = gla.feed_uuid
               )
and not exists (
                  select
                         null
                    from
                              stn.superseded_feed sf
                         join stn.feed            fd on sf.superseded_feed_sid = fd.feed_sid
                   where
                         fd.feed_uuid = gla.feed_uuid
              );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated event_status to X on discarded records', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_gl_account_pub
        (
            p_step_run_sid IN NUMBER,
            p_total_no_published OUT NUMBER,
            p_total_no_sub_acct_published OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO fdr.FR_STAN_RAW_GL_ACCOUNT
            (SRGA_GA_ACCOUNT_CODE, SRGA_GA_ACTIVE, SRGA_GA_ACCOUNT_TYPE, SRGA_GA_CLIENT_TEXT2, SRGA_GA_ACCOUNT_NAME, SRGA_GA_ACCOUNT_ADJ_TYPE, SRGA_GA_CLIENT_TEXT3, SRGA_GA_CLIENT_TEXT4, LPG_ID, MESSAGE_ID, PROCESS_ID)
            SELECT
                gla.ACCT_CD AS SRGA_GA_ACCOUNT_CODE,
                gla.ACCT_STS AS SRGA_GA_ACTIVE,
                gla.ACCT_TYP AS SRGA_GA_ACCOUNT_TYPE,
                gla.ACCT_CAT AS SRGA_GA_CLIENT_TEXT2,
                gla.ACCT_DESCR AS SRGA_GA_ACCOUNT_NAME,
                GLA_DEFAULT.ADJUSTMENT_TYPE AS SRGA_GA_ACCOUNT_ADJ_TYPE,
                GLA_DEFAULT.ACCOUNT_GENUS AS SRGA_GA_CLIENT_TEXT3,
                gla.ACCT_CD AS SRGA_GA_CLIENT_TEXT4,
                gla.LPG_ID AS LPG_ID,
                TO_CHAR(gla.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID
            FROM
                GL_ACCOUNT gla
                INNER JOIN IDENTIFIED_RECORD idr ON gla.ROW_SID = idr.ROW_SID
                INNER JOIN GLA_DEFAULT ON 1 = 1;
        p_total_no_published := SQL%ROWCOUNT;
        INSERT INTO fdr.FR_STAN_RAW_GL_ACCOUNT
            (SRGA_GA_ACCOUNT_CODE, SRGA_GA_ACTIVE, SRGA_GA_ACCOUNT_TYPE, SRGA_GA_CLIENT_TEXT2, SRGA_GA_ACCOUNT_NAME, SRGA_GA_ACCOUNT_ADJ_TYPE, SRGA_GA_CLIENT_TEXT3, SRGA_GA_CLIENT_TEXT4, LPG_ID, MESSAGE_ID, PROCESS_ID)
            SELECT
                gla.ACCT_CD || '-01' AS SRGA_GA_ACCOUNT_CODE,
                gla.ACCT_STS AS SRGA_GA_ACTIVE,
                gla.ACCT_TYP AS SRGA_GA_ACCOUNT_TYPE,
                gla.ACCT_CAT AS SRGA_GA_CLIENT_TEXT2,
                gla.ACCT_DESCR AS SRGA_GA_ACCOUNT_NAME,
                GLA_DEFAULT.ADJUSTMENT_TYPE AS SRGA_GA_ACCOUNT_ADJ_TYPE,
                GLA_DEFAULT.ACCOUNT_GENUS AS SRGA_GA_CLIENT_TEXT3,
                gla.ACCT_CD AS SRGA_GA_CLIENT_TEXT4,
                gla.LPG_ID AS LPG_ID,
                TO_CHAR(gla.ROW_SID) || '.01' AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID
            FROM
                GL_ACCOUNT gla
                INNER JOIN IDENTIFIED_RECORD idr ON gla.ROW_SID = idr.ROW_SID
                INNER JOIN GLA_DEFAULT ON 1 = 1;
        p_total_no_sub_acct_published := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_account_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE GL_ACCOUNT gla
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       fdr.fr_stan_raw_gl_account fsrga
                  join stn.identified_record      idr   on to_number ( fsrga.message_id ) = idr.row_sid
            where
                  idr.row_sid = gla.ROW_SID
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_account_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_hopper_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE fdr.FR_STAN_RAW_GL_ACCOUNT fsrga
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                fsrga.EVENT_STATUS <> 'P' AND fsrga.LPG_ID = p_lpg_id;
        p_no_updated_hopper_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_account_prc
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
        v_no_updated_hopper_records NUMBER(38, 9) DEFAULT 0;
        v_total_no_sub_acct_published NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify GL account records' );
        pr_gl_account_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed hopper records' );
            pr_gl_account_chr(p_step_run_sid, p_lpg_id, v_no_updated_hopper_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cancellation of unprocessed hopper records', 'v_no_updated_hopper_records', NULL, v_no_updated_hopper_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish GL account records' );
            pr_gl_account_pub(p_step_run_sid, v_total_no_published, v_total_no_sub_acct_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing GL account records', 'v_total_no_published', NULL, v_total_no_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing sub-account records', 'v_total_no_sub_acct_published', NULL, v_total_no_sub_acct_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set GL Account status = "P"' );
            pr_gl_account_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_processed_records', NULL, v_no_processed_records, NULL);
            IF v_no_processed_records <> v_no_identified_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_processed_records <> v_no_identified_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch' );
                raise pub_val_mismatch;
            END IF;
            IF v_no_processed_records <> v_total_no_published THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_processed_records <> v_total_no_published', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch' );
                raise pub_val_mismatch;
            END IF;
            IF v_total_no_published <> v_total_no_sub_acct_published THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_total_no_published <> v_total_no_sub_acct_published', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch' );
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := v_no_identified_records - v_no_processed_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_GL_ACCT;
/