CREATE OR REPLACE PACKAGE BODY stn.PK_LEL AS
    PROCEDURE pr_legal_ent_link_idf
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
                lel.ROW_SID AS ROW_SID
            FROM
                LEGAL_ENTITY_LINK lel
                INNER JOIN FEED fd ON lel.FEED_UUID = fd.FEED_UUID
            WHERE
                    lel.EVENT_STATUS = 'U'
and lel.LPG_ID       = p_lpg_id
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
        p_no_identified_recs := SQL%ROWCOUNT;
        UPDATE LEGAL_ENTITY_LINK lel
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  lel.row_sid = idr.row_sid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated legal_entity_link.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_legal_ent_link_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_hopper_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE fdr.FR_STAN_RAW_ORG_HIER_STRUC fsrohs
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                fsrohs.EVENT_STATUS <> 'P' AND fsrohs.LPG_ID = p_lpg_id;
        p_no_updated_hopper_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_legal_ent_link_rval
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                TO_CHAR(le.LE_ID) AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                lel.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                lel.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                lel.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                LEGAL_ENTITY_LINK lel
                INNER JOIN IDENTIFIED_RECORD idr ON lel.ROW_SID = idr.ROW_SID
                INNER JOIN LEGAL_ENTITY le ON le.LE_ID = lel.PARENT_LE_ID AND le.FEED_UUID = lel.FEED_UUID
                INNER JOIN FEED fd ON le.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON lel.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN LE_DEFAULT led ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'lel-parent_le_id'
and not exists (
                   select
                          null
                     from
                          fdr.fr_org_network fon
                    where
                          fon.on_org_node_client_code = le.LE_CD
                      and fon.on_active               = 'A'
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                TO_CHAR(le.LE_ID) AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                lel.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                lel.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                lel.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                LEGAL_ENTITY_LINK lel
                INNER JOIN IDENTIFIED_RECORD idr ON lel.ROW_SID = idr.ROW_SID
                INNER JOIN LEGAL_ENTITY le ON le.LE_ID = lel.CHILD_LE_ID AND le.FEED_UUID = lel.FEED_UUID
                INNER JOIN FEED fd ON le.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON lel.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN LE_DEFAULT led ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'lel-child_le_id'
and not exists (
                   select
                          null
                     from
                          fdr.fr_org_network fon
                    where
                          fon.on_org_node_client_code = le.LE_CD
                      and fon.on_active               = 'A'
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                TO_CHAR(le.LE_ID) AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                lel.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                lel.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                lel.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                LEGAL_ENTITY_LINK lel
                INNER JOIN IDENTIFIED_RECORD idr ON lel.ROW_SID = idr.ROW_SID
                INNER JOIN LEGAL_ENTITY le ON le.LE_ID = lel.PARENT_LE_ID AND le.FEED_UUID = lel.FEED_UUID
                INNER JOIN FEED fd ON le.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON lel.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN LE_DEFAULT led ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    lel.legal_entity_link_typ = 'SLR_LINK'
and vdl.VALIDATION_CD         = 'lel-parent_slr_link_le_id'
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
                          to_number ( fpl.pl_global_id ) = lel.PARENT_LE_ID
                      and fpll.pll_sil_sys_inst_clicode  = led.SYSTEM_INSTANCE
                      and fpt.pt_party_type_name         = 'Ledger Entity'
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                TO_CHAR(le.LE_ID) AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                lel.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                lel.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                lel.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                LEGAL_ENTITY_LINK lel
                INNER JOIN IDENTIFIED_RECORD idr ON lel.ROW_SID = idr.ROW_SID
                INNER JOIN LEGAL_ENTITY le ON le.LE_ID = lel.CHILD_LE_ID AND le.FEED_UUID = lel.FEED_UUID
                INNER JOIN FEED fd ON le.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON lel.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN LE_DEFAULT led ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    lel.legal_entity_link_typ = 'SLR_LINK'
and vdl.VALIDATION_CD         = 'lel-child_slr_link_le_id'
and exists (
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
                      to_number ( fpl.pl_global_id ) = lel.CHILD_LE_ID
                  and fpll.pll_sil_sys_inst_clicode  = led.SYSTEM_INSTANCE
                  and fpt.pt_party_type_name         = 'Ledger Entity'
           );
    END;
    
    PROCEDURE pr_legal_ent_link_svs
        (
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE LEGAL_ENTITY_LINK lel
            SET
                EVENT_STATUS = 'E'
            WHERE
                exists (
           select
                  null
             from
                  stn.standardisation_log sl
            where
                  sl.row_in_error_key_id = lel.ROW_SID
       );
        UPDATE LEGAL_ENTITY_LINK lel
            SET
                EVENT_STATUS = 'V'
            WHERE
                    not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = lel.ROW_SID
               )
and     exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          lel.ROW_SID = idr.row_sid
               );
        p_no_validated_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_legal_ent_link_pub
        (
            p_step_run_sid IN NUMBER,
            p_total_no_published OUT NUMBER,
            p_no_cancel_records_published OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO fdr.FR_STAN_RAW_ORG_HIER_STRUC
            (LPG_ID, MESSAGE_ID, PROCESS_ID, SRHS_ONS_CHILD_ORG_NODE_CODE, SRHS_ONS_PARENT_ORG_NODE_CODE, SRHS_ONS_ORG_HIER_TYPE_CODE, SRHS_ACTIVE)
            SELECT
                LPG_ID,
                MESSAGE_ID,
                TO_CHAR(p_step_run_sid),
                CHILD_LE_CD,
                PARENT_LE_CD,
                LINK_TYP,
                ACTIVE_FLAG
            FROM
                (SELECT
                    lel.LPG_ID AS LPG_ID,
                    TO_CHAR(lel.ROW_SID) AS MESSAGE_ID,
                    child_legal_entity.LE_CD AS CHILD_LE_CD,
                    parent_legal_entity.LE_CD AS PARENT_LE_CD,
                    lel.LEGAL_ENTITY_LINK_TYP AS LINK_TYP,
                    LE_DEFAULT.ACTIVE_FLAG AS ACTIVE_FLAG
                FROM
                    LEGAL_ENTITY_LINK lel
                    INNER JOIN IDENTIFIED_RECORD idr ON lel.ROW_SID = idr.ROW_SID
                    INNER JOIN LEGAL_ENTITY parent_legal_entity ON lel.PARENT_LE_ID = parent_legal_entity.LE_ID AND lel.FEED_UUID = parent_legal_entity.FEED_UUID
                    INNER JOIN LEGAL_ENTITY child_legal_entity ON lel.CHILD_LE_ID = child_legal_entity.LE_ID AND lel.FEED_UUID = child_legal_entity.FEED_UUID
                    INNER JOIN LE_DEFAULT ON 1 = 1
                WHERE
                    lel.EVENT_STATUS = 'V'
                UNION
                SELECT
                    lel.LPG_ID AS LPG_ID,
                    TO_CHAR(lel.ROW_SID) || '.1' AS MESSAGE_ID,
                    le.LE_CD AS CHILD_LE_CD,
                    'DEFAULT' AS PARENT_LE_CD,
                    lel.LEGAL_ENTITY_LINK_TYP AS LINK_TYP,
                    LE_DEFAULT.ACTIVE_FLAG AS ACTIVE_FLAG
                FROM
                    LEGAL_ENTITY_LINK lel
                    INNER JOIN IDENTIFIED_RECORD idr ON lel.ROW_SID = idr.ROW_SID
                    INNER JOIN LEGAL_ENTITY le ON lel.PARENT_LE_ID = le.LE_ID AND lel.FEED_UUID = le.FEED_UUID
                    INNER JOIN LE_DEFAULT ON 1 = 1
                WHERE
                    lel.EVENT_STATUS = 'V'
and not exists
           (
             select 
                    null
               from 
                    stn.legal_entity_link lelc
              where
                    le.LE_ID = lelc.child_le_id
                and lel.LEGAL_ENTITY_LINK_TYP = lelc.LEGAL_ENTITY_LINK_TYP
                and lel.FEED_UUID             = lelc.feed_uuid
           )
and exists (
             select 
                    null
               from 
                    stn.legal_entity_link lelp
              where
                    le.LE_ID = lelp.parent_le_id
                and lel.LEGAL_ENTITY_LINK_TYP = lelp.LEGAL_ENTITY_LINK_TYP
                and lel.FEED_UUID             = lelp.feed_uuid
           )
) SQ_Union;
        p_total_no_published := SQL%ROWCOUNT;
        /*
         * Each feed of legal entity/legal entity link record is supposed to represent to full legal entity hierarchy.
         * If a link record exists in the FDR which has not been supplied in the feed being processed, then this is
         * interpreted as meaning that this link between legal entities is no longer valid. This SQL inactivates the
         * link.
         */
        insert
          into
               fdr.fr_stan_raw_org_hier_struc
            (
                lpg_id
            ,   process_id
            ,   srhs_active
            ,   srhs_ons_parent_org_node_code
            ,   srhs_ons_child_org_node_code
            ,   srhs_ons_org_hier_type_code
            )
        select
               1                            lpg_id
             , to_char ( p_step_run_sid )   process_id
             , 'I'                          srhs_active
             , fonp.on_org_node_client_code srhs_ons_parent_org_node_code
             , fonc.on_org_node_client_code srhs_ons_child_org_node_code
             , foht.oht_org_hier_type_name  srhs_ons_org_hier_type_code
          from
                    fdr.fr_org_node_structure fons
               join fdr.fr_org_network        fonp on fons.ons_on_parent_org_node_id = fonp.on_org_node_id
               join fdr.fr_org_network        fonc on fons.ons_on_child_org_node_id  = fonc.on_org_node_id
               join fdr.fr_org_hierarchy_type foht on fons.ons_oht_org_hier_type_id  = foht.oht_org_hier_type_id
         where
               fons.ons_active               = 'A'
           and fonp.on_org_node_client_code != 'DEFAULT'
           and fonc.on_org_node_client_code != 'DEFAULT'
           and not exists (
                              select
                                     null
                                from
                                          stn.legal_entity_link lel
                                     join stn.identified_record idr on lel.row_sid      = idr.row_sid
                                     join stn.legal_entity      lep on lel.parent_le_id = lep.le_id
                                     join stn.legal_entity      lec on lel.child_le_id  = lec.le_id
                               where
                                     fonp.on_org_node_client_code = lep.le_cd
                                 and fonc.on_org_node_client_code = lec.le_cd
                                 and foht.oht_org_hier_type_name  = lel.legal_entity_link_typ
                          );
        p_no_cancel_records_published := sql%rowcount;
        /*
         * Each feed of legal entity/legal entity link record is supposed to represent to full legal entity hierarchy.
         * If a link record exists in the FDR which has not been supplied in the feed being processed, then this is
         * interpreted as meaning that this link between legal entities is no longer valid. This SQL inactivates the
         * link.
         */
        insert
          into
               fdr.fr_stan_raw_org_hier_struc
            (
                lpg_id
            ,   process_id
            ,   srhs_active
            ,   srhs_ons_parent_org_node_code
            ,   srhs_ons_child_org_node_code
            ,   srhs_ons_org_hier_type_code
            )
        select
               1                              lpg_id
             , to_char ( p_step_run_sid )     process_id
             , 'I'                            srhs_active
             , parent_le_cd                   srhs_ons_parent_org_node_code
             , child_le_cd                    srhs_ons_child_org_node_code
             , link_typ                       srhs_ons_org_hier_type_code
        from (
        select
               fonp.on_org_node_client_code parent_le_cd
             , fonc.on_org_node_client_code child_le_cd
             , foht.oht_org_hier_type_name  link_typ
          from
                    fdr.fr_org_node_structure fons
               join fdr.fr_org_network        fonp on fons.ons_on_parent_org_node_id = fonp.on_org_node_id
               join fdr.fr_org_network        fonc on fons.ons_on_child_org_node_id  = fonc.on_org_node_id
               join fdr.fr_org_hierarchy_type foht on fons.ons_oht_org_hier_type_id  = foht.oht_org_hier_type_id
         where
               fons.ons_active               = 'A'
           and fonp.on_org_node_client_code  = 'DEFAULT'
           and foht.OHT_ORG_HIER_TYPE_NAME  != 'DEFAULT'
         minus
        SELECT
            'DEFAULT' AS PARENT_LE_CD,
            le.LE_CD AS CHILD_LE_CD,
            lel.LEGAL_ENTITY_LINK_TYP AS LINK_TYP
        FROM
            stn.LEGAL_ENTITY_LINK lel
            INNER JOIN stn.IDENTIFIED_RECORD idr ON lel.ROW_SID = idr.ROW_SID
            INNER JOIN stn.LEGAL_ENTITY le ON lel.PARENT_LE_ID = le.LE_ID AND lel.FEED_UUID = le.FEED_UUID
            INNER JOIN stn.LE_DEFAULT LE_DEFAULT ON 1 = 1
        WHERE
            lel.EVENT_STATUS = 'V'
        and not exists
                   (
                     select
                            null
                       from
                            stn.legal_entity_link lelc
                      where
                            le.LE_ID = lelc.child_le_id
                        and lel.LEGAL_ENTITY_LINK_TYP = lelc.LEGAL_ENTITY_LINK_TYP
                        and lel.feed_uuid             = lelc.feed_uuid
                   )
        and exists (
                     select
                            null
                       from
                            stn.legal_entity_link lelp
                      where
                            le.LE_ID = lelp.parent_le_id
                        and lel.LEGAL_ENTITY_LINK_TYP = lelp.LEGAL_ENTITY_LINK_TYP
                        and lel.feed_uuid             = lelp.feed_uuid
                   )
            )
        ;
        --p_no_cancel_records_published := sql%rowcount;
    END;
    
    PROCEDURE pr_legal_ent_link_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE LEGAL_ENTITY_LINK lel
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       fdr.fr_stan_raw_org_hier_struc fsrohs
                  join stn.identified_record          idr    on to_number ( fsrohs.message_id ) = idr.row_sid
            where
                  idr.row_sid = lel.ROW_SID
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_legal_ent_link_prc
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
        v_no_cancel_records_published NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify legal entity link records' );
        pr_legal_ent_link_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed hopper records' );
            pr_legal_ent_link_chr(p_step_run_sid, p_lpg_id, v_no_updated_hopper_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed legal entity link hopper records', 'v_no_updated_hopper_records', NULL, v_no_updated_hopper_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate legal entity link records' );
            pr_legal_ent_link_rval;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set legal entity link status = "V"' );
            pr_legal_ent_link_svs(v_no_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status', 'v_no_validated_records', NULL, v_no_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish legal entity link records' );
            pr_legal_ent_link_pub(p_step_run_sid, v_total_no_published, v_no_cancel_records_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing org struc hopper records', 'v_total_no_published', NULL, v_total_no_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing org struc cancel hopper records', 'v_no_cancel_records_published', NULL, v_no_cancel_records_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish legal entity link log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set legal entity link status = "P"' );
            pr_legal_ent_link_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_processed_records', NULL, v_no_processed_records, NULL);
            IF v_no_processed_records <> v_no_validated_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_processed_records <> v_no_validated_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := v_no_identified_records - v_no_processed_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_LEL;
/