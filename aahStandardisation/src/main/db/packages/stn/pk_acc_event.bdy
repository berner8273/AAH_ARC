CREATE OR REPLACE PACKAGE BODY stn.PK_ACC_EVENT AS
    PROCEDURE pr_acc_event_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_hae_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE HOPPER_ACCOUNTING_EVENT hae
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                hae.EVENT_STATUS <> 'P' AND hae.LPG_ID = p_lpg_id;
        p_no_updated_hae_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_acc_event_idf
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_ae_identified_recs OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO IDENTIFIED_RECORD
            (ROW_SID)
            SELECT
                ae.ROW_SID AS ROW_SID
            FROM
                ACCOUNTING_EVENT ae
                INNER JOIN FEED ON ae.FEED_UUID = feed.FEED_UUID
            WHERE
                    ae.EVENT_STATUS = 'U'
and ae.LPG_ID       = p_lpg_id
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
        UPDATE ACCOUNTING_EVENT ae
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  ae.row_sid = idr.row_sid
       );
        p_no_ae_identified_recs := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated acc event step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_acc_event_pub
        (
            p_step_run_sid IN NUMBER,
            p_no_acc_event_updated OUT NUMBER,
            p_no_hae_pub OUT NUMBER
        )
    AS
    BEGIN
        MERGE INTO fdr.FR_ACC_EVENT_TYPE faet
            USING
                (SELECT
                    ae.EVENT_TYP AS EVENT_TYP,
                    ae.EVENT_TYP_DESCR AS EVENT_TYP_DESCR,
                    aed.ACTIVE_FLAG AS ACTIVE_FLAG,
                    aed.SYSTEM_INSTANCE AS SYSTEM_INSTANCE
                FROM
                    ACCOUNTING_EVENT ae
                    INNER JOIN IDENTIFIED_RECORD idr ON ae.ROW_SID = idr.ROW_SID
                    INNER JOIN ACCOUNTING_EVENT_DEFAULT aed ON 1 = 1
                WHERE
                    ae.EVENT_STATUS = 'V') stn_accounting_event
            ON (faet.AET_ACC_EVENT_TYPE_ID = stn_accounting_event.EVENT_TYP)
            WHEN MATCHED THEN
                UPDATE SET
                    AET_ACC_EVENT_TYPE_NAME = stn_accounting_event.EVENT_TYP_DESCR
            WHEN NOT MATCHED THEN
                INSERT
                    (AET_ACC_EVENT_TYPE_ID, AET_ACC_EVENT_TYPE_NAME, AET_ACTIVE, AET_INPUT_BY, AET_INPUT_TIME, AET_SI_SYS_INST_ID)
                    VALUES
                    (stn_accounting_event.EVENT_TYP, stn_accounting_event.EVENT_TYP_DESCR, stn_accounting_event.ACTIVE_FLAG, USER, CURRENT_DATE, stn_accounting_event.SYSTEM_INSTANCE);
        p_no_acc_event_updated := SQL%ROWCOUNT;
        INSERT INTO event_type
            (event_typ)
            SELECT
                ae.EVENT_TYP AS event_typ
            FROM
                ACCOUNTING_EVENT ae
                INNER JOIN IDENTIFIED_RECORD idr ON ae.ROW_SID = idr.ROW_SID
            WHERE
                    ae.EVENT_STATUS = 'V'
              and not exists (
                                 select
                                        null
                                   from
                                        stn.event_type et
                                  where
                                        et.event_typ = ae.EVENT_TYP
                             );
        INSERT INTO HOPPER_ACCOUNTING_EVENT
            (LPG_ID, MESSAGE_ID, PROCESS_ID, FEED_TYP, EFFECTIVE_FROM, EFFECTIVE_TO, EVENT_TYP, EVENT_TYP_DESCR, BUSINESS_EVENT_TYP, BUSINESS_EVENT_TYP_DESCR, EVENT_SUBGRP, EVENT_SUBGRP_DESCR, EVENT_GRP, EVENT_GRP_DESCR, EVENT_CLASS, EVENT_CLASS_DESCR, EVENT_TYP_STS)
            SELECT
                ae.LPG_ID AS LPG_ID,
                TO_CHAR(ae.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                'ACCOUNTING_EVENT' AS FEED_TYP,
                CURRENT_DATE AS EFFECTIVE_FROM,
                TO_DATE('2099-12-31', 'YYYY-MM-DD HH24:MI:SS') AS EFFECTIVE_TO,
                ae.EVENT_TYP AS EVENT_TYP,
                ae.EVENT_TYP_DESCR AS EVENT_TYP_DESCR,
                ae.BUSINESS_EVENT_TYP AS BUSINESS_EVENT_TYP,
                ae.BUSINESS_EVENT_TYP_DESCR AS BUSINESS_EVENT_TYP_DESCR,
                ae.EVENT_SUBGRP AS EVENT_SUBGRP,
                ae.EVENT_SUBGRP_DESCR AS EVENT_SUBGRP_DESCR,
                ae.EVENT_GRP AS EVENT_GRP,
                ae.EVENT_GRP_DESCR AS EVENT_GRP_DESCR,
                ae.EVENT_CLASS AS EVENT_CLASS,
                ae.EVENT_CLASS_DESCR AS EVENT_CLASS_DESCR,
                aed.ACTIVE_FLAG AS EVENT_TYP_STS
            FROM
                ACCOUNTING_EVENT ae
                INNER JOIN IDENTIFIED_RECORD idr ON ae.ROW_SID = idr.ROW_SID
                INNER JOIN ACCOUNTING_EVENT_DEFAULT aed ON 1 = 1
            WHERE
                ae.EVENT_STATUS = 'V';
        p_no_hae_pub := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_acc_event_sps
        (
            p_no_ae_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE ACCOUNTING_EVENT ae
            SET
                EVENT_STATUS = 'P'
            WHERE
                    ae.EVENT_STATUS = 'V'
and exists (
           select
                  null
             from
                 fdr.fr_acc_event_type  faet
            where
                 faet.aet_acc_event_type_id = ae.EVENT_TYP
           )
and exists (
           select
                  null
             from
                 stn.hopper_accounting_event  hae
            where
                 hae.event_typ = ae.EVENT_TYP
           );
        p_no_ae_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_acc_event_svs
        (
            p_step_run_sid IN NUMBER,
            p_no_validated_ae_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE ACCOUNTING_EVENT ae
            SET
                EVENT_STATUS = 'V'
            WHERE
                    ae.EVENT_STATUS = 'U';
        p_no_validated_ae_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of acc event records set to valid', 'p_no_validated_ae_records', NULL, p_no_validated_ae_records, NULL);
    END;
    
    PROCEDURE pr_acc_event_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_ae_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_hae_updated_records NUMBER(38, 9) DEFAULT 0;
        v_no_ae_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_acc_event_updated NUMBER(38, 9) DEFAULT 0;
        v_no_hae_published_records NUMBER(38, 9) DEFAULT 0;
        v_no_ae_processed_records NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify acc event records' );
        pr_acc_event_idf(p_step_run_sid, p_lpg_id, v_no_ae_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified acc event standardisation records', 'v_no_ae_identified_records', NULL, v_no_ae_identified_records, NULL);
        IF v_no_ae_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed acc event hopper records' );
            pr_acc_event_chr(p_step_run_sid, p_lpg_id, v_no_hae_updated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed hopper acc event records', 'v_no_hae_updated_records', NULL, v_no_hae_updated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set acc event status = "V"' );
            pr_acc_event_svs(p_step_run_sid, v_no_ae_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status for acc event', 'v_no_ae_validated_records', NULL, v_no_ae_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish acc event records' );
            pr_acc_event_pub(p_step_run_sid, v_no_acc_event_updated, v_no_hae_published_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing fdr.fr_acc_event_type records', 'v_no_acc_event_updated', NULL, v_no_acc_event_updated, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing hopper_accounting_event records', 'v_no_hae_published_records', NULL, v_no_hae_published_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish acc event standardise log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set acc event status = "P"' );
            pr_acc_event_sps(v_no_ae_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status for acc event records', 'v_no_ae_processed_records', NULL, v_no_ae_processed_records, NULL);
            IF v_no_ae_validated_records <> v_no_ae_processed_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_ud_validated_records <> v_no_ud_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_ae_processed_records;
            p_no_failed_records    := v_no_ae_identified_records
                                    - v_no_ae_processed_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_ACC_EVENT;
/