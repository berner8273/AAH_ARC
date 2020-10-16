CREATE OR REPLACE PACKAGE BODY stn.PK_TJ AS
    PROCEDURE pr_tax_jurisdiction_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_hopper_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE HOPPER_TAX_JURISDICTION htj
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                    htj.EVENT_STATUS != 'P'
and htj.LPG_ID        = p_lpg_id
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
                  and ftyp.feed_typ   = htj.srgc_gct_code_type_id
           );
        p_no_updated_hopper_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_tax_jurisdiction_idf
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
                tj.ROW_SID AS ROW_SID
            FROM
                tax_jurisdiction tj
                INNER JOIN FEED ON tj.FEED_UUID = feed.FEED_UUID
            WHERE
                    tj.EVENT_STATUS = 'U'
and tj.LPG_ID       = p_lpg_id
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
        UPDATE tax_jurisdiction tj
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  tj.row_sid = idr.row_sid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated tax_jurisdiction.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE tax_jurisdiction tj
            SET
                EVENT_STATUS = 'X',
                STEP_RUN_SID = p_step_run_sid
            WHERE
                   tj.EVENT_STATUS = 'U'
and not exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          tj.row_sid = idr.row_sid
               )
and not exists (
                   select
                          null
                     from
                               stn.broken_feed bf
                          join stn.feed        fd on bf.feed_sid = fd.feed_sid
                    where
                          fd.feed_uuid = tj.feed_uuid
               )
and not exists (
                  select
                         null
                    from
                              stn.superseded_feed sf
                         join stn.feed            fd on sf.superseded_feed_sid = fd.feed_sid
                   where
                         fd.feed_uuid = tj.feed_uuid
              );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated event_status to X on discarded tax_jurisdiction records', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_tax_jurisdiction_pub
        (
            p_step_run_sid IN NUMBER,
            p_total_no_published OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO HOPPER_TAX_JURISDICTION
            (TAX_JURISDICTION_CD, TAX_JURISDICTION_DESCR, SRGC_GCT_CODE_TYPE_ID, EVENT_STATUS, MESSAGE_ID, PROCESS_ID, LPG_ID, TAX_JURISDICTION_STS)
            SELECT
                tj.TAX_JURISDICTION_CD AS TAX_JURISDICTION_CD,
                tj.TAX_JURISDICTION_DESCR AS TAX_JURISDICTION_DESCR,
                tj_default.SRGC_GCT_CODE_TYPE_ID AS SRGC_GCT_CODE_TYPE_ID,
                tj.EVENT_STATUS AS EVENT_STATUS,
                TO_CHAR(tj.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                tj.LPG_ID AS LPG_ID,
                tj.TAX_JURISDICTION_STS AS TAX_JURISDICTION_STS
            FROM
                tax_jurisdiction tj
                INNER JOIN IDENTIFIED_RECORD idr ON tj.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON tj.FEED_UUID = fd.FEED_UUID
                INNER JOIN tax_jurisdiction_default tj_default ON 1 = 1;
        p_total_no_published := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_tax_jurisdiction_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE tax_jurisdiction tj
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       stn.hopper_tax_jurisdiction  htj
                  join stn.identified_record        idr  on trunc ( to_number ( htj.message_id ) ) = idr.row_sid
            where
                  idr.row_sid = tj.ROW_SID
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_tax_jurisdiction_prc
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
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify tax_jurisdiction records' );
        pr_tax_jurisdiction_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified tax jurisdiction records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed tax jurisdiction hopper records' );
            pr_tax_jurisdiction_chr(p_step_run_sid, p_lpg_id, v_no_updated_hopper_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cancellation of unprocessed tax jurisdicion hopper records', 'v_no_updated_hopper_records', NULL, v_no_updated_hopper_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish tax jurisdiction records' );
            pr_tax_jurisdiction_pub(p_step_run_sid, v_total_no_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing tax jurisdiction records', 'v_total_no_published', NULL, v_total_no_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set tax jurisdiction status = "P"' );
            pr_tax_jurisdiction_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting tax jurisdiction published status', 'v_no_processed_records', NULL, v_no_processed_records, NULL);
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
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := v_no_identified_records - v_no_processed_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_TJ;
/