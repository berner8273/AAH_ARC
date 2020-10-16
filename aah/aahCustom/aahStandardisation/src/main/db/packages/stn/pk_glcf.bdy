CREATE OR REPLACE PACKAGE BODY stn.PK_GLCF AS
    PROCEDURE pr_gl_chartfield_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_hopper_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE HOPPER_GL_CHARTFIELD hglc
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                    hglc.EVENT_STATUS != 'P'
and hglc.LPG_ID        = p_lpg_id
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
                  and ftyp.feed_typ   = hglc.feed_typ
           );
        p_no_updated_hopper_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_chartfield_idf
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
                gcf.ROW_SID AS ROW_SID
            FROM
                GL_CHARTFIELD gcf
                INNER JOIN FEED ON gcf.FEED_UUID = feed.FEED_UUID
                INNER JOIN (SELECT
                    gcf.CHARTFIELD_TYP AS chartfield_typ,
                    gcf.CHARTFIELD_CD AS chartfield_cd,
                    MAX(gcf.EFFECTIVE_DT) AS effective_dt
                FROM
                    GL_CHARTFIELD gcf
                    INNER JOIN fdr.FR_GLOBAL_PARAMETER fgp ON gcf.LPG_ID = fgp.LPG_ID
                WHERE
                    gcf.CHARTFIELD_STS = 'A' AND gcf.EVENT_STATUS = 'U' AND gcf.EFFECTIVE_DT <= fgp.GP_TODAYS_BUS_DATE
                GROUP BY
                    gcf.CHARTFIELD_TYP,
                    gcf.CHARTFIELD_CD) "most-recent-records" ON gcf.CHARTFIELD_TYP = "most-recent-records".chartfield_typ AND gcf.CHARTFIELD_CD = "most-recent-records".chartfield_cd AND gcf.EFFECTIVE_DT = "most-recent-records".effective_dt
            WHERE
                    gcf.EVENT_STATUS = 'U'
and gcf.LPG_ID       = p_lpg_id
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
        UPDATE GL_CHARTFIELD gcf
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  gcf.row_sid = idr.row_sid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated gl_chartfield.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE GL_CHARTFIELD gcf
            SET
                EVENT_STATUS = 'X',
                STEP_RUN_SID = p_step_run_sid
            WHERE
                    gcf.EVENT_STATUS = 'U'
and not exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          gcf.row_sid = idr.row_sid
               )
and not exists (
                   select
                          null
                     from
                               stn.broken_feed bf
                          join stn.feed        fd on bf.feed_sid = fd.feed_sid
                    where
                          fd.feed_uuid = gcf.feed_uuid
               )
and not exists (
                  select
                         null
                    from
                              stn.superseded_feed sf
                         join stn.feed            fd on sf.superseded_feed_sid = fd.feed_sid
                   where
                         fd.feed_uuid = gcf.feed_uuid
              );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated event_status to X on discarded records', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_gl_chartfield_pub
        (
            p_step_run_sid IN NUMBER,
            p_total_no_published OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO HOPPER_GL_CHARTFIELD
            (CHARTFIELD_TYP, CHARTFIELD_CD, CHARTFIELD_DESCR, EFFECTIVE_DT, CHARTFIELD_STS, FEED_TYP, EVENT_STATUS, MESSAGE_ID, PROCESS_ID, LPG_ID)
            SELECT
                gcf.CHARTFIELD_TYP AS CHARTFIELD_TYP,
                gcf.CHARTFIELD_CD AS CHARTFIELD_CD,
                gcf.CHARTFIELD_DESCR AS CHARTFIELD_DESCR,
                gcf.EFFECTIVE_DT AS EFFECTIVE_DT,
                gcf.CHARTFIELD_STS AS CHARTFIELD_STS,
                fd.FEED_TYP AS FEED_TYP,
                gcf.EVENT_STATUS AS EVENT_STATUS,
                TO_CHAR(gcf.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                gcf.LPG_ID AS LPG_ID
            FROM
                GL_CHARTFIELD gcf
                INNER JOIN IDENTIFIED_RECORD idr ON gcf.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON gcf.FEED_UUID = fd.FEED_UUID;
        p_total_no_published := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_chartfield_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE GL_CHARTFIELD gcf
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       stn.hopper_gl_chartfield hglc
                  join stn.identified_record    idr  on to_number ( hglc.message_id ) = idr.row_sid
            where
                  idr.row_sid = gcf.ROW_SID
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_gl_chartfield_prc
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
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify GL chartfield records' );
        pr_gl_chartfield_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed hopper records' );
            pr_gl_chartfield_chr(p_step_run_sid, p_lpg_id, v_no_updated_hopper_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cancellation of unprocessed hopper records', 'v_no_updated_hopper_records', NULL, v_no_updated_hopper_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish GL chartfield records' );
            pr_gl_chartfield_pub(p_step_run_sid, v_total_no_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing records', 'v_total_no_published', NULL, v_total_no_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set GL chartfield status = "P"' );
            pr_gl_chartfield_sps(v_no_processed_records);
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
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := v_no_identified_records - v_no_processed_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_GLCF;
/