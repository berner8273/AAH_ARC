CREATE OR REPLACE PACKAGE BODY stn.PK_EH AS
    PROCEDURE pr_event_hier_idf
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
                eh.ROW_SID AS ROW_SID
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN FEED ON eh.FEED_UUID = feed.FEED_UUID
            WHERE
                    eh.EVENT_STATUS = 'U'
and eh.LPG_ID       = p_lpg_id
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
        UPDATE EVENT_HIERARCHY eh
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  eh.row_sid = idr.row_sid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated event_hierarchy.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_event_hier_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_heh_records OUT NUMBER,
            p_no_updated_hes_records OUT NUMBER,
            p_no_updated_heg_records OUT NUMBER,
            p_no_updated_hecl_records OUT NUMBER,
            p_no_updated_hecat_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE HOPPER_EVENT_HIERARCHY heh
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                heh.EVENT_STATUS <> 'P' AND heh.LPG_ID = p_lpg_id;
        p_no_updated_heh_records := SQL%ROWCOUNT;
        UPDATE HOPPER_EVENT_SUBGROUP hes
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                hes.EVENT_STATUS <> 'P' AND hes.LPG_ID = p_lpg_id;
        p_no_updated_hes_records := SQL%ROWCOUNT;
        UPDATE HOPPER_EVENT_GROUP heg
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                heg.EVENT_STATUS <> 'P' AND heg.LPG_ID = p_lpg_id;
        p_no_updated_heg_records := SQL%ROWCOUNT;
        UPDATE HOPPER_EVENT_CLASS hecl
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                hecl.EVENT_STATUS <> 'P' AND hecl.LPG_ID = p_lpg_id;
        p_no_updated_hecl_records := SQL%ROWCOUNT;
        UPDATE HOPPER_EVENT_CATEGORY hecat
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                hecat.EVENT_STATUS <> 'P' AND hecat.LPG_ID = p_lpg_id;
        p_no_updated_hecat_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_event_hier_sval
        (
            p_step_run_sid IN NUMBER,
            p_total_no_faet_published OUT NUMBER,
            p_total_no_et_published OUT NUMBER,
            p_total_no_hopper_published OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                eh.EVENT_CATEGORY_DESCR AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                eh.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                eh.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                eh.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON eh.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON eh.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN (SELECT
                    eh.EVENT_CATEGORY_CD AS EVENT_CATEGORY_CD
                FROM
                    EVENT_HIERARCHY eh
                    INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                GROUP BY
                    eh.EVENT_CATEGORY_CD
                HAVING
                    COUNT(DISTINCT eh.EVENT_CATEGORY_DESCR) > 1) duplicate_category ON eh.EVENT_CATEGORY_CD = duplicate_category.EVENT_CATEGORY_CD
            WHERE
                    vdl.VALIDATION_CD = 'event-hier-category'
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                eh.EVENT_CLASS_DESCR AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                eh.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                eh.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                eh.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON eh.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON eh.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN (SELECT
                    eh.EVENT_CLASS AS event_class
                FROM
                    EVENT_HIERARCHY eh
                    INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                GROUP BY
                    eh.EVENT_CLASS
                HAVING
                    COUNT(DISTINCT eh.EVENT_CLASS_DESCR) > 1) duplicate_class ON eh.EVENT_CLASS = duplicate_class.event_class
            WHERE
                    vdl.VALIDATION_CD = 'event-hier-class'
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                eh.EVENT_CLASS_DESCR AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                eh.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                eh.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                eh.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON eh.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON eh.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN (SELECT
                    eh.EVENT_CLASS AS event_class
                FROM
                    EVENT_HIERARCHY eh
                    INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                GROUP BY
                    eh.EVENT_CLASS
                HAVING
                    COUNT(DISTINCT eh.EVENT_CLASS_PERIOD_FREQ) > 1) multiple_class_period_freq ON eh.EVENT_CLASS = multiple_class_period_freq.event_class
            WHERE
                    vdl.VALIDATION_CD = 'event-hier-class-period-freq'
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                eh.EVENT_GRP_DESCR AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                eh.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                eh.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                eh.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON eh.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON eh.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN (SELECT
                    eh.EVENT_GRP AS event_grp
                FROM
                    EVENT_HIERARCHY eh
                    INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                GROUP BY
                    eh.EVENT_GRP
                HAVING
                    COUNT(DISTINCT eh.EVENT_GRP_DESCR) > 1) duplicate_group ON eh.EVENT_GRP = duplicate_group.event_grp
            WHERE
                    vdl.VALIDATION_CD = 'event-hier-group'
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                eh.EVENT_SUBGRP_DESCR AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                eh.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                eh.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                eh.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON eh.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON eh.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                INNER JOIN (SELECT
                    eh.EVENT_SUBGRP AS EVENT_SUBGRP
                FROM
                    EVENT_HIERARCHY eh
                    INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                GROUP BY
                    eh.EVENT_SUBGRP
                HAVING
                    COUNT(DISTINCT eh.EVENT_SUBGRP_DESCR) > 1) duplicate_subgroup ON eh.EVENT_SUBGRP = duplicate_subgroup.EVENT_SUBGRP
            WHERE
                    vdl.VALIDATION_CD = 'event-hier-subgroup';
    END;
    
    PROCEDURE pr_event_hier_svs
        (
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE EVENT_HIERARCHY eh
            SET
                EVENT_STATUS = 'E'
            WHERE
                exists (
           select
                  null
             from
                  stn.standardisation_log sl
            where
                  sl.row_in_error_key_id = eh.ROW_SID
       );
        UPDATE EVENT_HIERARCHY eh
            SET
                EVENT_STATUS = 'V'
            WHERE
                    not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = eh.ROW_SID
               )
and     exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          eh.ROW_SID = idr.row_sid
               );
        p_no_validated_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_event_hier_pub
        (
            p_step_run_sid IN NUMBER,
            p_total_no_faet_published OUT NUMBER,
            p_total_no_et_published OUT NUMBER,
            p_total_no_hopper_published OUT NUMBER
        )
    AS
    BEGIN
        MERGE INTO fdr.FR_ACC_EVENT_TYPE faet
            USING
                (SELECT
                    eh.EVENT_TYP AS EVENT_TYP,
                    eh.EVENT_TYP_DESCR AS EVENT_TYP_DESCR,
                    ehd.ACTIVE_FLAG AS ACTIVE_FLAG,
                    ehd.SYSTEM_INSTANCE AS SYSTEM_INSTANCE
                FROM
                    EVENT_HIERARCHY eh
                    INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                    INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
                WHERE
                    eh.EVENT_STATUS = 'V') stn_event_hierarchy
            ON (faet.AET_ACC_EVENT_TYPE_ID = stn_event_hierarchy.EVENT_TYP)
            WHEN MATCHED THEN
                UPDATE SET
                    AET_ACC_EVENT_TYPE_NAME = stn_event_hierarchy.EVENT_TYP_DESCR
            WHEN NOT MATCHED THEN
                INSERT
                    (AET_ACC_EVENT_TYPE_ID, AET_ACC_EVENT_TYPE_NAME, AET_ACTIVE, AET_INPUT_BY, AET_INPUT_TIME, AET_SI_SYS_INST_ID)
                    VALUES
                    (stn_event_hierarchy.EVENT_TYP, stn_event_hierarchy.EVENT_TYP_DESCR, stn_event_hierarchy.ACTIVE_FLAG, USER, CURRENT_DATE, stn_event_hierarchy.SYSTEM_INSTANCE);
        p_total_no_faet_published := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Merged records into fdr.fr_acc_event_type', 'p_total_no_faet_published', NULL, p_total_no_faet_published, NULL);
        INSERT INTO event_type
            (event_typ)
            SELECT
                eh.EVENT_TYP AS event_typ
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
            WHERE
                    eh.EVENT_STATUS = 'V'
and not exists (
                   select
                          null
                     from
                          stn.event_type et
                    where
                          et.event_typ = eh.EVENT_TYP
               );
        p_total_no_et_published := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Merged records into stn.event_type', 'p_total_no_et_published', NULL, p_total_no_et_published, NULL);
        INSERT INTO HOPPER_EVENT_HIERARCHY
            (LPG_ID, MESSAGE_ID, PROCESS_ID, FEED_TYP, EFFECTIVE_FROM, EFFECTIVE_TO, EVENT_TYP, EVENT_SUBGRP, EVENT_GRP, EVENT_CLASS, EVENT_CATEGORY, IS_CASH_EVENT, IS_CORE_EARNING_EVENT, EVENT_TYP_STS)
            SELECT
                eh.LPG_ID AS LPG_ID,
                TO_CHAR(eh.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                'EVENT_HIERARCHY' AS FEED_TYP,
                CURRENT_DATE AS EFFECTIVE_FROM,
                TO_DATE('2099-12-31', 'YYYY-MM-DD HH24:MI:SS') AS EFFECTIVE_TO,
                eh.EVENT_TYP AS EVENT_TYP,
                eh.EVENT_SUBGRP AS EVENT_SUBGRP,
                eh.EVENT_GRP AS EVENT_GRP,
                eh.EVENT_CLASS AS EVENT_CLASS,
                eh.EVENT_CATEGORY_CD AS EVENT_CATEGORY,
                eh.IS_CASH_EVENT AS IS_CASH_EVENT,
                eh.IS_CORE_EARNING_EVENT AS IS_CORE_EARNING_EVENT,
                ehd.ACTIVE_FLAG AS EVENT_TYP_STS
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
            WHERE
                eh.EVENT_STATUS = 'V';
        p_total_no_hopper_published := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Merged records into stn.hopper_event_hierarchy', 'p_total_no_hopper_published', NULL, p_total_no_hopper_published, NULL);
        INSERT INTO HOPPER_EVENT_CATEGORY
            (FEED_TYP, EVENT_CATEGORY, EVENT_CATEGORY_DESCR, EFFECTIVE_FROM, EFFECTIVE_TO, EVENT_CATEGORY_STS, PROCESS_ID, LPG_ID)
            SELECT DISTINCT
                'EVENT_CATEGORY' AS FEED_TYP,
                eh.EVENT_CATEGORY_CD AS EVENT_CATEGORY,
                eh.EVENT_CATEGORY_DESCR AS EVENT_CATEGORY_DESCR,
                CURRENT_DATE AS EFFECTIVE_FROM,
                TO_DATE('2099-12-31', 'YYYY-MM-DD HH24:MI:SS') AS EFFECTIVE_TO,
                ehd.ACTIVE_FLAG AS EVENT_CATEGORY_STS,
                TO_CHAR(eh.STEP_RUN_SID) AS PROCESS_ID,
                eh.LPG_ID AS LPG_ID
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
            WHERE
                eh.EVENT_STATUS = 'V';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Merged records into stn.hopper_event_category', 'sql%rowcount', NULL, sql%rowcount, NULL);
        INSERT INTO HOPPER_EVENT_CLASS
            (FEED_TYP, EVENT_CLASS, EVENT_CLASS_DESCR, EVENT_CLASS_PERIOD_FREQ, EFFECTIVE_FROM, EFFECTIVE_TO, EVENT_CLASS_STS, PROCESS_ID, LPG_ID)
            SELECT DISTINCT
                'EVENT_CLASS' AS FEED_TYP,
                eh.EVENT_CLASS AS EVENT_CLASS,
                eh.EVENT_CLASS_DESCR AS EVENT_CLASS_DESCR,
                eh.EVENT_CLASS_PERIOD_FREQ AS EVENT_CLASS_PERIOD_FREQ,
                CURRENT_DATE AS EFFECTIVE_FROM,
                TO_DATE('2099-12-31', 'YYYY-MM-DD HH24:MI:SS') AS EFFECTIVE_TO,
                ehd.ACTIVE_FLAG AS EVENT_CLASS_STS,
                TO_CHAR(eh.STEP_RUN_SID) AS PROCESS_ID,
                eh.LPG_ID AS LPG_ID
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
            WHERE
                eh.EVENT_STATUS = 'V';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Merged records into stn.hopper_event_class', 'sql%rowcount', NULL, sql%rowcount, NULL);
        INSERT INTO HOPPER_EVENT_GROUP
            (FEED_TYP, EVENT_GRP, EVENT_GRP_DESCR, EFFECTIVE_FROM, EFFECTIVE_TO, EVENT_GRP_STS, PROCESS_ID, LPG_ID)
            SELECT DISTINCT
                'EVENT_GROUP' AS FEED_TYP,
                eh.EVENT_GRP AS EVENT_GRP,
                eh.EVENT_GRP_DESCR AS EVENT_GRP_DESCR,
                CURRENT_DATE AS EFFECTIVE_FROM,
                TO_DATE('2099-12-31', 'YYYY-MM-DD HH24:MI:SS') AS EFFECTIVE_TO,
                ehd.ACTIVE_FLAG AS EVENT_GRP_STS,
                TO_CHAR(eh.STEP_RUN_SID) AS PROCESS_ID,
                eh.LPG_ID AS LPG_ID
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
            WHERE
                eh.EVENT_STATUS = 'V';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Merged records into stn.hopper_event_group', 'sql%rowcount', NULL, sql%rowcount, NULL);
        INSERT INTO HOPPER_EVENT_SUBGROUP
            (FEED_TYP, EVENT_SUBGRP, EVENT_SUBGRP_DESCR, EFFECTIVE_FROM, EFFECTIVE_TO, EVENT_SUBGRP_STS, PROCESS_ID, LPG_ID)
            SELECT DISTINCT
                'EVENT_SUBGROUP' AS FEED_TYP,
                eh.EVENT_SUBGRP AS EVENT_SUBGRP,
                eh.EVENT_SUBGRP_DESCR AS EVENT_SUBGRP_DESCR,
                CURRENT_DATE AS EFFECTIVE_FROM,
                TO_DATE('2099-12-31', 'YYYY-MM-DD HH24:MI:SS') AS EFFECTIVE_TO,
                ehd.ACTIVE_FLAG AS EVENT_SUBGRP_STS,
                TO_CHAR(eh.STEP_RUN_SID) AS PROCESS_ID,
                eh.LPG_ID AS LPG_ID
            FROM
                EVENT_HIERARCHY eh
                INNER JOIN IDENTIFIED_RECORD idr ON eh.ROW_SID = idr.ROW_SID
                INNER JOIN EVENT_HIERARCHY_DEFAULT ehd ON 1 = 1
            WHERE
                eh.EVENT_STATUS = 'V';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Merged records into stn.hopper_event_subgroup', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_event_hier_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE EVENT_HIERARCHY eh
            SET
                EVENT_STATUS = 'P'
            WHERE
                    eh.EVENT_STATUS = 'V'
and exists (
               select
                      null
                 from
                     fdr.fr_acc_event_type  faet
                where
                     faet.aet_acc_event_type_id = eh.EVENT_TYP
           )
and exists (
               select
                      null
                 from
                      stn.hopper_event_hierarchy heh
                where
                      to_number ( heh.message_id ) = eh.ROW_SID
           )
and exists (
               select
                      null
                 from
                      stn.identified_record idr
                where
                      idr.row_sid = eh.ROW_SID
           );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_event_hier_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_updated_heh_records NUMBER(38, 9) DEFAULT 0;
        v_no_updated_hes_records NUMBER(38, 9) DEFAULT 0;
        v_no_updated_heg_records NUMBER(38, 9) DEFAULT 0;
        v_no_updated_hecl_records NUMBER(38, 9) DEFAULT 0;
        v_no_updated_hecat_records NUMBER(38, 9) DEFAULT 0;
        v_total_no_faet_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_et_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_hopper_published NUMBER(38, 9) DEFAULT 0;
        v_no_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_validated_records NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify event hier records' );
        pr_event_hier_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified event_hierarchy records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed event hier hopper records' );
            pr_event_hier_chr(p_step_run_sid, p_lpg_id, v_no_updated_heh_records, v_no_updated_hes_records, v_no_updated_heg_records, v_no_updated_hecl_records, v_no_updated_hecat_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed hopper event_hierarchy records', 'v_no_updated_heh_records', NULL, v_no_updated_heh_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed hopper event subgroup records', 'v_no_updated_hes_records', NULL, v_no_updated_hes_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed hopper event_group records', 'v_no_updated_heg_records', NULL, v_no_updated_heg_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed hopper event class records', 'v_no_updated_hecl_records', NULL, v_no_updated_hecl_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed hopper event category records', 'v_no_updated_hecat_records', NULL, v_no_updated_hecat_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Validate event hier records' );
            pr_event_hier_sval(p_step_run_sid, v_total_no_faet_published, v_total_no_et_published, v_total_no_hopper_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed set level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set event status = "V"' );
            pr_event_hier_svs(v_no_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status', 'v_no_validated_records', NULL, v_no_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish event hier records' );
            pr_event_hier_pub(p_step_run_sid, v_total_no_faet_published, v_total_no_et_published, v_total_no_hopper_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing fdr.fr_acc_event_type records', 'v_total_no_faet_published', NULL, v_total_no_faet_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing event_type records', 'v_total_no_et_published', NULL, v_total_no_et_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing hopper_event_hierarchy records', 'v_total_no_hopper_published', NULL, v_total_no_hopper_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish event hier log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set event hier status = "P"' );
            pr_event_hier_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status for acc event records', 'v_no_processed_records', NULL, v_no_processed_records, NULL);
            IF v_no_validated_records <> v_total_no_faet_published THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_identified_records != v_total_no_faet_published', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            IF v_no_validated_records <> v_total_no_hopper_published THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_identified_records != v_total_no_hopper_published', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            IF v_no_validated_records <> v_no_processed_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_identified_records != v_no_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := 0;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_EH;
/