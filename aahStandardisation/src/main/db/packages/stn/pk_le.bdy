CREATE OR REPLACE PACKAGE BODY stn.PK_LE AS
    PROCEDURE pr_legal_entity_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_total_no_fsrpl_updated OUT NUMBER,
            p_total_no_fsrpb_updated OUT NUMBER,
            p_total_no_fsrie_updated OUT NUMBER,
            p_total_no_fsrohn_updated OUT NUMBER
        )
    AS
    BEGIN
        UPDATE fdr.FR_STAN_RAW_PARTY_LEGAL fsrpl
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                fsrpl.EVENT_STATUS <> 'P' AND fsrpl.LPG_ID = p_lpg_id;
        p_total_no_fsrpl_updated := SQL%ROWCOUNT;
        UPDATE fdr.FR_STAN_RAW_PARTY_BUSINESS fsrpb
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                fsrpb.EVENT_STATUS <> 'P' AND fsrpb.LPG_ID = p_lpg_id;
        p_total_no_fsrpb_updated := SQL%ROWCOUNT;
        UPDATE fdr.FR_STAN_RAW_INT_ENTITY fsrie
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                fsrie.EVENT_STATUS <> 'P' AND fsrie.LPG_ID = p_lpg_id;
        p_total_no_fsrie_updated := SQL%ROWCOUNT;
        UPDATE fdr.FR_STAN_RAW_ORG_HIER_NODE fsrohn
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                fsrohn.EVENT_STATUS <> 'P' AND fsrohn.LPG_ID = p_lpg_id;
        p_total_no_fsrohn_updated := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_legal_entity_idf
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
                le.ROW_SID AS ROW_SID
            FROM
                LEGAL_ENTITY le
                INNER JOIN FEED ON le.FEED_UUID = feed.FEED_UUID
            WHERE
                    le.EVENT_STATUS = 'U'
and le.LPG_ID       = p_lpg_id
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
        UPDATE LEGAL_ENTITY le
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  le.row_sid = idr.row_sid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated legal_entity.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_legal_entity_pub
        (
            p_step_run_sid IN NUMBER,
            p_total_no_fsrpl_published OUT NUMBER,
            p_total_no_fsrpb_published OUT NUMBER,
            p_total_no_fsrie_published OUT NUMBER,
            p_total_no_fsrohn_published OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO fdr.FR_STAN_RAW_PARTY_LEGAL
            (LPG_ID, MESSAGE_ID, PROCESS_ID, SRL_PL_GLOBAL_ID, SRL_PL_PARTY_LEGAL_CLICODE, SRL_PL_FULL_LEGAL_NAME, SRL_PL_CU_LOCAL_CURRENCY_ID, SRL_PL_PT_PARTY_TYPE_CODE, SRL_PL_ACTIVE, SRL_PL_INT_EXT_FLAG, SRL_PL_CU_BASE_CURRENCY_CODE, SRL_PL_CLIENT_TEXT2, SRL_PL_CLIENT_TEXT3, SRL_PL_CLIENT_TEXT4, SRL_PL_CLIENT_TEXT5, SRL_PL_CLIENT_TEXT6)
            SELECT
                le.LPG_ID AS LPG_ID,
                TO_CHAR(le.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                TO_CHAR(le.LE_ID) AS SRL_PL_GLOBAL_ID,
                le.LE_CD AS SRL_PL_PARTY_LEGAL_CLICODE,
                le.LE_DESCR AS SRL_PL_FULL_LEGAL_NAME,
                le.FUNCTIONAL_CCY AS SRL_PL_CU_LOCAL_CURRENCY_ID,
                (CASE
                    WHEN le.IS_LEDGER_ENTITY = 'Y' THEN FR_PARTY_TYPE_LEDGER_ENTITY.PT_PARTY_TYPE_CLIENT_CODE
                    ELSE FR_PARTY_TYPE_ELSE.PT_PARTY_TYPE_CLIENT_CODE
                END) AS SRL_PL_PT_PARTY_TYPE_CODE,
                LE_DEFAULT.ACTIVE_FLAG AS SRL_PL_ACTIVE,
                LE_DEFAULT.INTERNAL_EXTERNAL_IND AS SRL_PL_INT_EXT_FLAG,
                LE_DEFAULT.BASE_CCY AS SRL_PL_CU_BASE_CURRENCY_CODE,
                (CASE
                    WHEN le.IS_LEDGER_ENTITY = 'Y' THEN TO_CHAR(LE_DEFAULT.NO_GRACE_DAYS)
                    ELSE NULL
                END) AS SRL_PL_CLIENT_TEXT2,
                (CASE
                    WHEN le.IS_LEDGER_ENTITY = 'Y' THEN TO_CHAR(LE_DEFAULT.SLR_LPG_ID)
                    ELSE NULL
                END) AS SRL_PL_CLIENT_TEXT3,
                (CASE
                    WHEN le.IS_LEDGER_ENTITY = 'Y' THEN LE_DEFAULT.EPG_ID
                    ELSE NULL
                END) AS SRL_PL_CLIENT_TEXT4,
                le.IS_INTERCO_ELIM_ENTITY AS SRL_PL_CLIENT_TEXT5,
                le.IS_VIE_CONSOL_ENTITY AS SRL_PL_CLIENT_TEXT6
            FROM
                LEGAL_ENTITY le
                INNER JOIN IDENTIFIED_RECORD idr ON le.ROW_SID = idr.ROW_SID
                INNER JOIN LE_DEFAULT ON 1 = 1
                INNER JOIN fdr.FR_PARTY_TYPE FR_PARTY_TYPE_LEDGER_ENTITY ON 1 = 1
                INNER JOIN fdr.FR_PARTY_TYPE FR_PARTY_TYPE_ELSE ON UPPER(le.LEGAL_ENTITY_TYP) = UPPER(FR_PARTY_TYPE_ELSE.PT_PARTY_TYPE_NAME)
            WHERE
                FR_PARTY_TYPE_LEDGER_ENTITY.PT_PARTY_TYPE_NAME = 'Ledger Entity' AND le.EVENT_STATUS = 'V';
        p_total_no_fsrpl_published := SQL%ROWCOUNT;
        INSERT INTO fdr.FR_STAN_RAW_PARTY_BUSINESS
            (LPG_ID, MESSAGE_ID, PROCESS_ID, SRPB_PBU_PT_PARTY_TYPE_CODE, SRPB_PBU_PARTY_LEGAL_CODE, SRPB_PBU_NAME, SRPB_PBU_PARTY_BUS_CLIENT_CODE, SRPB_ONE, SRPB_PBU_ACTIVE, SRPB_PBU_GLOBAL_SA_ID)
            SELECT
                le.LPG_ID AS LPG_ID,
                TO_CHAR(le.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                (CASE
                    WHEN le.IS_LEDGER_ENTITY = 'Y' THEN FR_PARTY_TYPE_LEDGER_ENTITY.PT_PARTY_TYPE_CLIENT_CODE
                    ELSE FR_PARTY_TYPE_ELSE.PT_PARTY_TYPE_CLIENT_CODE
                END) AS SRPB_PBU_PT_PARTY_TYPE_CODE,
                le.LE_CD AS SRPB_PBU_PARTY_LEGAL_CODE,
                le.LE_DESCR AS SRPB_PBU_NAME,
                le.LE_CD AS SRPB_PBU_PARTY_BUS_CLIENT_CODE,
                le.LPG_ID AS SRPB_ONE,
                LE_DEFAULT.ACTIVE_FLAG AS SRPB_PBU_ACTIVE,
                le.LEGAL_ENTITY_TYP AS SRPB_PBU_GLOBAL_SA_ID
            FROM
                LEGAL_ENTITY le
                INNER JOIN IDENTIFIED_RECORD idr ON le.ROW_SID = idr.ROW_SID
                INNER JOIN LE_DEFAULT ON 1 = 1
                INNER JOIN fdr.FR_PARTY_TYPE FR_PARTY_TYPE_LEDGER_ENTITY ON 1 = 1
                INNER JOIN fdr.FR_PARTY_TYPE FR_PARTY_TYPE_ELSE ON UPPER(le.LEGAL_ENTITY_TYP) = UPPER(FR_PARTY_TYPE_ELSE.PT_PARTY_TYPE_NAME)
            WHERE
                FR_PARTY_TYPE_LEDGER_ENTITY.PT_PARTY_TYPE_NAME = 'Ledger Entity' AND le.EVENT_STATUS = 'V';
        p_total_no_fsrpb_published := SQL%ROWCOUNT;
        INSERT INTO fdr.FR_STAN_RAW_INT_ENTITY
            (LPG_ID, MESSAGE_ID, PROCESS_ID, SRIP_IPE_ENTITY_REPORT_NAME, SRIP_IPE_PL_PARTY_LEGAL_CODE, SRIP_IPE_ENTITY_CLIENT_CODE, SRIP_IPE_ENTITY_TYPE_ID, SRIP_IPE_CU_BASE_CURRENCY_ID, SRIP_SI_SOURCE_SYSTEM, SRIP_IPE_ACTIVE, SRIP_INTERNAL_ENTITY_ID)
            SELECT
                le.LPG_ID AS LPG_ID,
                TO_CHAR(le.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                le.LE_DESCR AS SRIP_IPE_ENTITY_REPORT_NAME,
                le.LE_CD AS SRIP_IPE_PL_PARTY_LEGAL_CODE,
                le.LE_CD AS SRIP_IPE_ENTITY_CLIENT_CODE,
                fipet.IPET_INTERNAL_PROC_ENT_TYPE_ID AS SRIP_IPE_ENTITY_TYPE_ID,
                LE_DEFAULT.BASE_CCY AS SRIP_IPE_CU_BASE_CURRENCY_ID,
                LE_DEFAULT.SYSTEM_INSTANCE AS SRIP_SI_SOURCE_SYSTEM,
                LE_DEFAULT.ACTIVE_FLAG AS SRIP_IPE_ACTIVE,
                le.LE_CD AS SRIP_INTERNAL_ENTITY_ID
            FROM
                LEGAL_ENTITY le
                INNER JOIN IDENTIFIED_RECORD idr ON le.ROW_SID = idr.ROW_SID
                INNER JOIN LE_DEFAULT ON 1 = 1
                INNER JOIN fdr.FR_INTERNAL_PROC_ENTITY_TYPE fipet ON 1 = 1
            WHERE
                le.IS_LEDGER_ENTITY = 'Y' AND fipet.IPET_INTERNAL_PROC_ENTITY_CODE = 'OPERATING UNIT' AND le.EVENT_STATUS = 'V';
        p_total_no_fsrie_published := SQL%ROWCOUNT;
        INSERT INTO fdr.FR_STAN_RAW_ORG_HIER_NODE
            (LPG_ID, MESSAGE_ID, PROCESS_ID, SRHN_ACTIVE, SRHN_ON_ORG_NODE_CODE, SRHN_ON_PL_PARTY_LEGAL_CODE, SRHN_SI_SYS_INST_CODE, SRHN_ONT_ORG_NODE_TYPE_CODE)
            SELECT
                le.LPG_ID AS LPG_ID,
                TO_CHAR(le.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                LE_DEFAULT.ACTIVE_FLAG AS SRHN_ACTIVE,
                le.LE_CD AS SRHN_ON_ORG_NODE_CODE,
                le.LE_CD AS SRHN_ON_PL_PARTY_LEGAL_CODE,
                LE_DEFAULT.SYSTEM_INSTANCE AS SRHN_SI_SYS_INST_CODE,
                LE_DEFAULT.ORG_NODE_TYPE AS SRHN_ONT_ORG_NODE_TYPE_CODE
            FROM
                LEGAL_ENTITY le
                INNER JOIN IDENTIFIED_RECORD idr ON le.ROW_SID = idr.ROW_SID
                INNER JOIN LE_DEFAULT ON 1 = 1
            WHERE
                le.EVENT_STATUS = 'V';
        p_total_no_fsrohn_published := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_legal_entity_rval
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
                    le.ROW_SID AS row_in_error_key_id,
                    le.FUNCTIONAL_CCY AS error_value,
                    le.LPG_ID AS LPG_ID,
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
                    le.STEP_RUN_SID AS STEP_RUN_SID,
                    vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                    fd.FEED_SID AS FEED_SID
                FROM
                    LEGAL_ENTITY le
                    INNER JOIN IDENTIFIED_RECORD idr ON le.ROW_SID = idr.ROW_SID
                    INNER JOIN FEED fd ON le.FEED_UUID = fd.FEED_UUID
                    INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON le.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                    INNER JOIN LE_DEFAULT led ON 1 = 1
                    INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                    INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                WHERE
                        vdl.VALIDATION_CD = 'le-functional_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = le.FUNCTIONAL_CCY
                      and fcl.cul_sil_sys_inst_clicode = led.SYSTEM_INSTANCE
               )) SubQuery;
    END;
    
    PROCEDURE pr_legal_entity_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE LEGAL_ENTITY le
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       fdr.fr_stan_raw_party_legal fsrpl
                  join stn.identified_record   idr   on to_number ( fsrpl.message_id ) = idr.row_sid
            where
                  idr.row_sid = le.ROW_SID
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_legal_entity_svs
        (
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE LEGAL_ENTITY le
            SET
                EVENT_STATUS = 'E'
            WHERE
                exists (
           select
                  null
             from
                  stn.standardisation_log sl
            where
                  sl.row_in_error_key_id = le.ROW_SID
       );
        UPDATE LEGAL_ENTITY le
            SET
                EVENT_STATUS = 'V'
            WHERE
                    not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = le.ROW_SID
               )
and     exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          le.ROW_SID = idr.row_sid
               );
        p_no_validated_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_legal_entity_prc
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
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify legal entity records' );
        pr_legal_entity_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed hopper records' );
            pr_legal_entity_chr(p_step_run_sid, p_lpg_id, v_total_no_fsrpl_published, v_total_no_fsrpb_published, v_total_no_fsrie_updated, v_total_no_fsrohn_updated);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed party legal hopper records', 'v_total_no_fsrpl_updated', NULL, v_total_no_fsrpl_updated, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed party business hopper records', 'v_total_no_fsrpb_updated', NULL, v_total_no_fsrpb_updated, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed internal entity hopper records', 'v_total_no_fsrie_updated', NULL, v_total_no_fsrie_updated, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed org node records', 'v_total_no_fsrohn_updated', NULL, v_total_no_fsrohn_updated, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate legal entity records' );
            pr_legal_entity_rval;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set legal entity status = "V"' );
            pr_legal_entity_svs(v_no_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status', 'v_no_validated_records', NULL, v_no_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish legal entity records' );
            pr_legal_entity_pub(p_step_run_sid, v_total_no_fsrpl_published, v_total_no_fsrpb_published, v_total_no_fsrie_published, v_total_no_fsrohn_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing party_legal hopper records', 'v_total_no_fsrpl_published', NULL, v_total_no_fsrpl_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing party_business hopper records', 'v_total_no_fsrpb_published', NULL, v_total_no_fsrpb_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing internal entity hopper records', 'v_total_no_fsrie_published', NULL, v_total_no_fsrie_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing org node hier records', 'v_total_no_fsrohn_published', NULL, v_total_no_fsrohn_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish legal entity log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set legal entity status = "P"' );
            pr_legal_entity_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_processed_records', NULL, v_no_processed_records, NULL);
            IF v_total_no_fsrpl_published <> v_total_no_fsrpb_published THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_total_no_fsrpl_published <> v_total_no_fsrpb_published', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            IF v_total_no_fsrpl_published <> v_total_no_fsrohn_published THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_total_no_fsrpl_published <> v_total_no_fsrohn_published', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 2' );
                raise pub_val_mismatch;
            END IF;
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
END PK_LE;
/