CREATE OR REPLACE PACKAGE BODY STN.PK_LEDG AS
    PROCEDURE pr_ledger_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_habl_records OUT NUMBER,
            p_no_updated_hlel_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE HOPPER_ACCOUNTING_BASIS_LEDGER habl
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                habl.EVENT_STATUS <> 'P' AND habl.LPG_ID = p_lpg_id;
        p_no_updated_habl_records := SQL%ROWCOUNT;
        UPDATE HOPPER_LEGAL_ENTITY_LEDGER hlel
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                hlel.EVENT_STATUS <> 'P' AND hlel.LPG_ID = p_lpg_id;
        p_no_updated_hlel_records := SQL%ROWCOUNT;
    END;

    PROCEDURE pr_ledger_idf
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_l_identified_recs OUT NUMBER,
            p_no_abl_identified_recs OUT NUMBER,
            p_no_lel_identified_recs OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO IDENTIFIED_RECORD
            (ROW_SID)
            SELECT
                l.ROW_SID AS ROW_SID
            FROM
                LEDGER l
                INNER JOIN FEED ON l.FEED_UUID = feed.FEED_UUID
            WHERE
                    l.EVENT_STATUS = 'U'
and l.LPG_ID       = p_lpg_id
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
        UPDATE LEDGER l
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  l.row_sid = idr.row_sid
       );
        p_no_l_identified_recs := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated ledger step_run_sid', 'p_no_l_identified_recs', NULL, sql%rowcount, NULL);
        UPDATE ACCOUNTING_BASIS_LEDGER abl
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
             join stn.ledger            l on l.row_sid = idr.row_sid
            where
                  abl.LEDGER_CD = l.ledger_cd
              and abl.feed_uuid = l.feed_uuid
       );
        p_no_abl_identified_recs := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated accounting_basis_ledger step_run_sid', 'p_no_abl_identified_recs', NULL, sql%rowcount, NULL);
        UPDATE LEGAL_ENTITY_LEDGER lel
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
             join stn.ledger            l on l.row_sid = idr.row_sid
            where
                  lel.LEDGER_CD = l.ledger_cd
              and lel.feed_uuid = l.feed_uuid
       );
        p_no_lel_identified_recs := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated legal_entity_ledger step_run_sid', 'p_no_lel_identified_recs', NULL, sql%rowcount, NULL);
    END;

    PROCEDURE pr_ledger_pub
        (
            p_step_run_sid IN NUMBER,
            p_no_posting_schema_updated OUT NUMBER,
            p_no_habl_pub OUT NUMBER,
            p_no_gen_lk_lel_upd OUT NUMBER,
            p_no_hlel_pub OUT NUMBER
        )
    AS
    BEGIN
        MERGE INTO fdr.FR_POSTING_SCHEMA fps
            USING
                (SELECT
                    l.LEDGER_CD AS LEDGER_CD,
                    LEDGER_DEFAULT.LEDGER_GROUP AS LEDGER_GROUP,
                    LEDGER_DEFAULT.ACTIVE_FLAG AS ACTIVE_FLAG
                FROM
                    LEDGER l
                    INNER JOIN IDENTIFIED_RECORD idr ON l.ROW_SID = idr.ROW_SID
                    INNER JOIN LEDGER_DEFAULT ON 1 = 1
                WHERE
                    l.EVENT_STATUS = 'V') stn_ledger
            ON (fps.PS_POSTING_SCHEMA = stn_ledger.LEDGER_CD AND fps.PS_POSTING_SCHEMA_GROUP = stn_ledger.LEDGER_GROUP)
            WHEN NOT MATCHED THEN
                INSERT
                    (PS_POSTING_SCHEMA, PS_POSTING_SCHEMA_GROUP, PS_ACTIVE, PS_INPUT_BY, PS_INPUT_TIME)
                    VALUES
                    (stn_ledger.LEDGER_CD, stn_ledger.LEDGER_GROUP, stn_ledger.ACTIVE_FLAG, USER, CURRENT_DATE);
        p_no_posting_schema_updated := SQL%ROWCOUNT;
        INSERT INTO HOPPER_ACCOUNTING_BASIS_LEDGER
            (LPG_ID, MESSAGE_ID, PROCESS_ID, BASIS_CD, BASIS_LEDGER_STS, LEDGER_CD, FEED_TYP, EFFECTIVE_FROM, EFFECTIVE_TO, BASIS_CD_LEDGER_CD)
            SELECT
                abl.LPG_ID AS LPG_ID,
                TO_CHAR(abl.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                abl.BASIS_CD AS BASIS_CD,
                LEDGER_DEFAULT.ACTIVE_FLAG AS BASIS_LEDGER_STS,
                abl.LEDGER_CD AS LEDGER_CD,
                'ACCOUNTING_BASIS_LEDGER' AS FEED_TYP,
                CURRENT_DATE AS EFFECTIVE_FROM,
                TO_DATE('2099-12-31', 'YYYY-MM-DD HH24:MI:SS') AS EFFECTIVE_TO,
                abl.BASIS_CD || '_' || abl.LEDGER_CD AS BASIS_CD_LEDGER_CD
            FROM
                ACCOUNTING_BASIS_LEDGER abl
                INNER JOIN LEDGER l ON l.LEDGER_CD = abl.LEDGER_CD AND l.FEED_UUID = abl.FEED_UUID
                INNER JOIN IDENTIFIED_RECORD idr ON l.ROW_SID = idr.ROW_SID
                INNER JOIN LEDGER_DEFAULT ON 1 = 1
            WHERE
                    abl.EVENT_STATUS = 'V'
and not exists ( select
                        null
                   from
                        fdr.fr_general_lookup fgl
                  where
                        fgl.lk_lkt_lookup_type_code = 'ACCOUNTING_BASIS_LEDGER'
                    and fgl.lk_lookup_value1       = abl.BASIS_CD
                    and fgl.lk_lookup_value2       = abl.LEDGER_CD
               );
        p_no_habl_pub := SQL%ROWCOUNT;
        MERGE INTO fdr.FR_GENERAL_LOOKUP fgl
            USING
                (SELECT
                    lel.LEDGER_CD AS LEDGER_CD,
                    fpl.PL_GLOBAL_ID AS LE_ID,
                    lel.EFFECTIVE_FROM_DT AS EFFECTIVE_FROM_DT,
                    lel.EFFECTIVE_TO_DT AS EFFECTIVE_TO_DT
                FROM
                    LEGAL_ENTITY_LEDGER lel
                    INNER JOIN LEDGER l ON lel.FEED_UUID = l.FEED_UUID AND lel.LEDGER_CD = l.LEDGER_CD
                    INNER JOIN IDENTIFIED_RECORD idr ON l.ROW_SID = idr.ROW_SID
                    INNER JOIN fdr.FR_PARTY_LEGAL fpl ON fpl.PL_PARTY_LEGAL_CLICODE = lel.LE_CD
                WHERE
                    lel.EVENT_STATUS = 'V') stn_legal_entity_ledger
            ON (fgl.LK_LOOKUP_VALUE1 = stn_legal_entity_ledger.LEDGER_CD AND fgl.LK_LOOKUP_VALUE2 = stn_legal_entity_ledger.LE_ID)
            WHEN MATCHED THEN
                UPDATE SET
                    LK_EFFECTIVE_FROM = stn_legal_entity_ledger.EFFECTIVE_FROM_DT,
                    LK_EFFECTIVE_TO = stn_legal_entity_ledger.EFFECTIVE_TO_DT
        ;
        p_no_gen_lk_lel_upd := SQL%ROWCOUNT;
        INSERT INTO HOPPER_LEGAL_ENTITY_LEDGER
            (LPG_ID, MESSAGE_ID, PROCESS_ID, LE_ID, LEGAL_ENTITY_LEDGER_STS, LEDGER_CD, FEED_TYP, EFFECTIVE_FROM, EFFECTIVE_TO, LEDGER_CD_LE_ID)
            SELECT
                lel.LPG_ID AS LPG_ID,
                TO_CHAR(lel.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                fpl.PL_GLOBAL_ID AS LE_ID,
                LEDGER_DEFAULT.ACTIVE_FLAG AS LEGAL_ENTITY_LEDGER_STS,
                lel.LEDGER_CD AS LEDGER_CD,
                'LEGAL_ENTITY_LEDGER' AS FEED_TYP,
                lel.EFFECTIVE_FROM_DT AS EFFECTIVE_FROM,
                lel.EFFECTIVE_TO_DT AS EFFECTIVE_TO,
                lel.LEDGER_CD || '_' || fpl.PL_GLOBAL_ID AS LEDGER_CD_LE_ID
            FROM
                LEGAL_ENTITY_LEDGER lel
                INNER JOIN LEDGER l ON l.LEDGER_CD = lel.LEDGER_CD AND l.FEED_UUID = lel.FEED_UUID
                INNER JOIN IDENTIFIED_RECORD idr ON l.ROW_SID = idr.ROW_SID
                INNER JOIN fdr.FR_PARTY_LEGAL fpl ON lel.LE_CD = fpl.PL_PARTY_LEGAL_CLICODE
                INNER JOIN LEDGER_DEFAULT ON 1 = 1
            WHERE
                    lel.EVENT_STATUS = 'V'
and not exists ( select
                        null
                   from
                        fdr.fr_general_lookup fgl
                  where
                        fgl.lk_lkt_lookup_type_code = 'LEGAL_ENTITY_LEDGER'
                    and fgl.lk_lookup_value1       = lel.LEDGER_CD
                    and fgl.lk_lookup_value2       = fpl.PL_GLOBAL_ID
               );
        p_no_hlel_pub := SQL%ROWCOUNT;
    END;

    PROCEDURE pr_ledger_rval
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                l.CLDR_CD AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                l.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                l.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                l.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                LEDGER l
                INNER JOIN IDENTIFIED_RECORD idr ON l.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON l.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON l.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ledg-cldr_cd'
and not exists (
                   select
                          null
                     from
                          fdr.fr_calendar ca
                    where
                          ca.ca_calendar_name = l.CLDR_CD
               )
            UNION
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                abl.BASIS_CD AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                abl.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                abl.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                abl.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                ACCOUNTING_BASIS_LEDGER abl
                INNER JOIN LEDGER l ON abl.LEDGER_CD = l.LEDGER_CD AND abl.FEED_UUID = l.FEED_UUID
                INNER JOIN IDENTIFIED_RECORD idr ON l.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON abl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON abl.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'abl-basis_cd'
and abl.BASIS_CAT = 'L'
and not exists (
                   select
                          null
                     from
                          fdr.fr_gaap fga
                    where
                          fga.fga_gaap_id = abl.BASIS_CD
               )
            UNION
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                lel.LE_CD AS error_value,
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
                LEGAL_ENTITY_LEDGER lel
                INNER JOIN LEDGER l ON lel.LEDGER_CD = l.LEDGER_CD AND lel.FEED_UUID = l.FEED_UUID
                INNER JOIN IDENTIFIED_RECORD idr ON l.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON lel.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON lel.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'lel-le_cd'
and not exists (
                   select
                          null
                     from
                          fdr.fr_party_legal pl
                    where
                          pl.pl_party_legal_clicode = lel.LE_CD
               );
    END;

    PROCEDURE pr_ledger_sps
        (
            p_step_run_sid IN NUMBER,
            p_no_l_processed_records OUT NUMBER,
            p_no_abl_processed_records OUT NUMBER,
            p_no_lel_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE LEDGER L1
            SET
                EVENT_STATUS = (SELECT
                    'P'
                FROM
                    LEDGER l
                    INNER JOIN LEDGER_DEFAULT ON 1 = 1
                WHERE
                        l.EVENT_STATUS = 'V'
and exists (
           select
                  null
             from
                 fdr.fr_posting_schema  fps
            where
                 fps.ps_posting_schema       = l.LEDGER_CD
             and fps.ps_posting_schema_group = LEDGER_DEFAULT.LEDGER_GROUP
           ) AND l.ROW_SID = L1.ROW_SID)
            WHERE
                EXISTS (SELECT
                    'P'
                FROM
                    LEDGER l
                    INNER JOIN LEDGER_DEFAULT ON 1 = 1
                WHERE
                        l.EVENT_STATUS = 'V'
and exists (
           select
                  null
             from
                 fdr.fr_posting_schema  fps
            where
                 fps.ps_posting_schema       = l.LEDGER_CD
             and fps.ps_posting_schema_group = LEDGER_DEFAULT.LEDGER_GROUP
           ) AND l.ROW_SID = L1.ROW_SID);
        p_no_l_processed_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of ledger records set to processed', 'p_no_l_processed_records', NULL, sql%rowcount, NULL);
        UPDATE ACCOUNTING_BASIS_LEDGER abl
            SET
                EVENT_STATUS = 'P'
            WHERE
                    abl.EVENT_STATUS = 'V'
and (
     exists (
           select
                  null
             from
                       stn.hopper_accounting_basis_ledger habl
                  join stn.accounting_basis_ledger        abl  on to_number ( habl.message_id ) = abl.ROW_SID
                  join stn.ledger                         l    on (
                                                                   abl.LEDGER_CD = l.ledger_cd
                                                               and abl.FEED_UUID = l.feed_uuid
                                                           )
                  join stn.identified_record       idr  on l.row_sid = idr.row_sid
            where
                  to_number ( habl.message_id ) = abl.ROW_SID
             )
     or
        exists ( select
                        null
                   from
                        fdr.fr_general_lookup fgl
                  where
                        fgl.lk_lkt_lookup_type_code = 'ACCOUNTING_BASIS_LEDGER'
                    and fgl.lk_lookup_value1       = abl.BASIS_CD
                    and fgl.lk_lookup_value2       = abl.LEDGER_CD
               )
     );
        p_no_abl_processed_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of accounting_basis_ledger records set to processed', 'p_no_abl_processed_records', NULL, sql%rowcount, NULL);
        UPDATE LEGAL_ENTITY_LEDGER lel
            SET
                EVENT_STATUS = 'P'
            WHERE
                    lel.EVENT_STATUS = 'V'
and (
    exists (
           select
                  null
             from
                       stn.hopper_legal_entity_ledger     hlel
                  join stn.legal_entity_ledger            lel  on to_number ( hlel.message_id ) = lel.ROW_SID
                  join stn.ledger                         l    on (
                                                                   lel.LEDGER_CD = l.ledger_cd
                                                               and lel.FEED_UUID = l.feed_uuid
                                                           )
                  join stn.identified_record       idr  on l.row_sid = idr.row_sid
            where
                  to_number ( hlel.message_id ) = lel.ROW_SID
            )
     or
        exists ( select
                        null
                   from
                        fdr.fr_general_lookup fgl
                   join fdr.fr_party_legal    fpl    on fgl.lk_lookup_value2 = fpl.pl_global_id
                  where
                        fgl.lk_lkt_lookup_type_code = 'LEGAL_ENTITY_LEDGER'
                    and fgl.lk_lookup_value1       = lel.LEDGER_CD
                    and fgl.lk_lookup_value2       = fpl.PL_GLOBAL_ID
               )
     );
        p_no_lel_processed_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of legal_entity_ledger records set to processed', 'p_no_lel_processed_records', NULL, sql%rowcount, NULL);
    END;

    PROCEDURE pr_ledger_svs
        (
            p_step_run_sid IN NUMBER,
            p_no_validated_ledger_records OUT NUMBER,
            p_no_errored_ledger_records OUT NUMBER,
            p_no_validated_abl_records OUT NUMBER,
            p_no_errored_abl_records OUT NUMBER,
            p_no_validated_lel_records OUT NUMBER,
            p_no_errored_lel_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE LEDGER l
            SET
                EVENT_STATUS = 'E'
            WHERE
                       exists (
                  select
                         null
                    from
                         stn.standardisation_log sl
                   where
                         sl.table_in_error_name = 'ledger'
                     and sl.row_in_error_key_id = l.row_sid
              )
    or exists (
                  select
                         null
                    from
                              stn.accounting_basis_ledger    abl
                         join stn.standardisation_log        sl  on abl.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'accounting_basis_ledger'
                     and abl.ledger_cd          = l.ledger_cd
                     and abl.feed_uuid          = l.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.legal_entity_ledger        lel
                         join stn.standardisation_log        sl  on lel.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'legal_entity_ledger'
                     and lel.ledger_cd          = l.ledger_cd
                     and lel.feed_uuid          = l.feed_uuid
              );
        p_no_errored_ledger_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of ledger records set to error', 'p_no_errored_ledger_records', NULL, sql%rowcount, NULL);
        UPDATE ACCOUNTING_BASIS_LEDGER abl
            SET
                EVENT_STATUS = 'E'
            WHERE
                       exists (
                  select
                         null
                    from
                         stn.standardisation_log sl
                   where
                         sl.table_in_error_name = 'accounting_basis_ledger'
                     and sl.row_in_error_key_id = abl.row_sid
              )
    or exists (
                  select
                         null
                    from
                              stn.ledger                     l
                         join stn.standardisation_log        sl  on l.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'ledger'
                     and l.ledger_cd            = abl.ledger_cd
                     and l.feed_uuid            = abl.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.legal_entity_ledger        lel
                         join stn.standardisation_log        sl  on lel.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'legal_entity_ledger'
                     and lel.ledger_cd          = abl.ledger_cd
                     and lel.feed_uuid          = abl.feed_uuid
              );
        p_no_errored_abl_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of accounting_basis_ledger records set to error', 'p_no_errored_abl_records', NULL, sql%rowcount, NULL);
        UPDATE LEGAL_ENTITY_LEDGER lel
            SET
                EVENT_STATUS = 'E'
            WHERE
                       exists (
                  select
                         null
                    from
                         stn.standardisation_log sl
                   where
                         sl.table_in_error_name = 'legal_entity_ledger'
                     and sl.row_in_error_key_id = lel.row_sid
              )
    or exists (
                  select
                         null
                    from
                              stn.ledger                     l
                         join stn.standardisation_log        sl  on l.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'ledger'
                     and l.ledger_cd            = lel.ledger_cd
                     and l.feed_uuid            = lel.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.accounting_basis_ledger    abl
                         join stn.standardisation_log        sl  on abl.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'accounting_basis_ledger'
                     and abl.ledger_cd          = lel.ledger_cd
                     and abl.feed_uuid          = lel.feed_uuid
              );
        p_no_errored_lel_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of legal_entity_ledger records set to error', 'p_no_errored_lel_records', NULL, sql%rowcount, NULL);
        UPDATE LEDGER l
            SET
                EVENT_STATUS = 'V'
            WHERE
                    l.EVENT_STATUS = 'U';
        p_no_validated_ledger_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of ledger records set to valid', 'p_no_validated_ledger_records', NULL, p_no_validated_ledger_records, NULL);
        UPDATE ACCOUNTING_BASIS_LEDGER abl
            SET
                EVENT_STATUS = 'V'
            WHERE
                    abl.EVENT_STATUS = 'U';
        p_no_validated_abl_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of accounting_basis_ledger records set to valid', 'p_no_validated_abl_records', NULL, sql%rowcount, NULL);
        UPDATE LEGAL_ENTITY_LEDGER lel
            SET
                EVENT_STATUS = 'V'
            WHERE
                    lel.EVENT_STATUS = 'U';
        p_no_validated_lel_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of legal_entity_ledger records set to valid', 'p_no_validated_lel_records', NULL, sql%rowcount, NULL);
    END;

    PROCEDURE pr_ledger_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_l_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_abl_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_lel_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_habl_updated_records NUMBER(38, 9) DEFAULT 0;
        v_no_hlel_updated_records NUMBER(38, 9) DEFAULT 0;
        v_no_l_errored_records NUMBER(38, 9) DEFAULT 0;
        v_no_abl_errored_records NUMBER(38, 9) DEFAULT 0;
        v_no_lel_errored_records NUMBER(38, 9) DEFAULT 0;
        v_no_l_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_abl_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_lel_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_l_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_abl_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_lel_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_l_published NUMBER(38, 9) DEFAULT 0;
        v_no_abl_published NUMBER(38, 9) DEFAULT 0;
        v_no_gen_lk_lel_updated NUMBER(38, 9) DEFAULT 0;
        v_no_lel_published NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
        s_exception_name VARCHAR2(80);
        s_proc_name VARCHAR2(80) := 'stn.pk_ledg.pr_ledger_prc';
        gv_ecode     NUMBER := -20001;
        gv_emsg VARCHAR(10000);

    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify ledger records' );
        pr_ledger_idf(p_step_run_sid, p_lpg_id, v_no_l_identified_records, v_no_abl_identified_records, v_no_lel_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified ledger standardisation records', 'v_no_identified_records', NULL, v_no_l_identified_records + v_no_abl_identified_records + v_no_lel_identified_records, NULL);
        IF v_no_l_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed ledger hopper records' );
            pr_ledger_chr(p_step_run_sid, p_lpg_id, v_no_habl_updated_records, v_no_hlel_updated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed hopper acct basis ledger records', 'v_no_habl_updated_records', NULL, v_no_habl_updated_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Cancelled unprocessed hopper legal entity ledger records', 'v_no_hlel_updated_records', NULL, v_no_hlel_updated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate ledger records' );
            pr_ledger_rval;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations for ledger', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set ledger status = "V"' );
            pr_ledger_svs(p_step_run_sid, v_no_l_validated_records, v_no_l_errored_records, v_no_abl_validated_records, v_no_abl_errored_records, v_no_lel_validated_records, v_no_lel_errored_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status for ledger', 'v_no_validated_records', NULL, v_no_l_validated_records + v_no_abl_validated_records + v_no_lel_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish ledger records' );
            pr_ledger_pub(p_step_run_sid, v_no_l_published, v_no_abl_published, v_no_gen_lk_lel_updated, v_no_lel_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing fdr.fr_posting_schema records', 'v_no_l_published', NULL, v_no_l_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing hopper_accounting_basis_ledger records', 'v_no_abl_published', NULL, v_no_abl_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed updating general lookup legal_entity_ledger records', 'v_no_gen_lk_lel_updated', NULL, v_no_gen_lk_lel_updated, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing hopper_legal_entity_ledger records', 'v_no_lel_published', NULL, v_no_lel_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish ledger standardise log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set ledger status = "P"' );
            pr_ledger_sps(p_step_run_sid, v_no_l_processed_records, v_no_abl_processed_records, v_no_lel_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status for ledger records', 'v_no_processed_records', NULL, v_no_l_processed_records + v_no_abl_processed_records + v_no_lel_processed_records, NULL);
            IF v_no_l_validated_records <> v_no_l_processed_records THEN
                s_exception_name:='v_no_ud_validated_records <> v_no_ud_processed_records';
                raise pub_val_mismatch;
            END IF;
            IF v_no_abl_validated_records <> v_no_abl_processed_records THEN
                s_exception_name:='v_no_ug_validated_records <> v_no_ug_processed_records';
                raise pub_val_mismatch;
            END IF;
            IF v_no_lel_validated_records <> v_no_lel_processed_records THEN
                s_exception_name:='v_no_lel_validated_records <> v_no_lel_processed_records';
                raise pub_val_mismatch;
            END IF;

            p_no_processed_records := v_no_l_processed_records
                                    + v_no_abl_processed_records
                                    + v_no_lel_processed_records;
            p_no_failed_records    := v_no_l_identified_records
                                    + v_no_abl_identified_records
                                    + v_no_lel_identified_records
                                    - v_no_l_processed_records
                                    - v_no_abl_processed_records
                                    - v_no_lel_processed_records;
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
END PK_LEDG;
/