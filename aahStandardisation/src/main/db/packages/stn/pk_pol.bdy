CREATE OR REPLACE PACKAGE BODY stn.PK_POL AS
    PROCEDURE pr_policy_istat
    AS
    BEGIN
        dbms_stats.gather_table_stats ( ownname => user , tabname => 'INSURANCE_POLICY'            , cascade => true );
        dbms_stats.gather_table_stats ( ownname => user , tabname => 'CESSION'                     , cascade => true );
        dbms_stats.gather_table_stats ( ownname => user , tabname => 'CESSION_LINK'                , cascade => true );
        dbms_stats.gather_table_stats ( ownname => user , tabname => 'INSURANCE_POLICY_FX_RATE'    , cascade => true );
        dbms_stats.gather_table_stats ( ownname => user , tabname => 'INSURANCE_POLICY_TAX_JURISD' , cascade => true );
    END;
    
    PROCEDURE pr_policy_idf
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
                pol.ROW_SID AS ROW_SID
            FROM
                INSURANCE_POLICY pol
                INNER JOIN FEED fd ON pol.FEED_UUID = fd.FEED_UUID
                INNER JOIN (SELECT
                    SubQuery.POLICY_ID AS POLICY_ID,
                    SubQuery.EFFECTIVE_DT AS EFFECTIVE_DT,
                    SubQuery.LOADED_TS AS LOADED_TS
                FROM
                    (SELECT
                        pol.POLICY_ID AS POLICY_ID,
                        fd.LOADED_TS AS LOADED_TS,
                        fd.EFFECTIVE_DT AS EFFECTIVE_DT,
                        MAX(fd.EFFECTIVE_DT) OVER (PARTITION BY pol.POLICY_ID) AS MAX_EFFECTIVE_DT,
                        MAX(fd.LOADED_TS) OVER (PARTITION BY pol.POLICY_ID, fd.EFFECTIVE_DT) AS MAX_LOADED_TS
                    FROM
                        INSURANCE_POLICY pol
                        INNER JOIN FEED fd ON pol.FEED_UUID = fd.FEED_UUID
                    WHERE
                        pol.EVENT_STATUS = 'U' AND pol.LPG_ID = p_lpg_id) SubQuery
                WHERE
                    SubQuery.EFFECTIVE_DT = SubQuery.MAX_EFFECTIVE_DT AND SubQuery.LOADED_TS = SubQuery.MAX_LOADED_TS) pol_max_eff_dt ON pol.POLICY_ID = pol_max_eff_dt.POLICY_ID AND fd.EFFECTIVE_DT = pol_max_eff_dt.EFFECTIVE_DT AND fd.LOADED_TS = pol_max_eff_dt.LOADED_TS
            WHERE
                    pol.EVENT_STATUS = 'U'
and pol.LPG_ID       = p_lpg_id
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
        dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'IDENTIFIED_RECORD' , cascade => true );
        UPDATE INSURANCE_POLICY pol
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  pol.row_sid = idr.row_sid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated insurance_policy.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE CESSION cs
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                       stn.insurance_policy         pol
                  join stn.identified_record idr on pol.row_sid = idr.row_sid
            where
                  pol.policy_id = cs.policy_id
              and pol.feed_uuid = cs.feed_uuid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated cession.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE CESSION_LINK csl
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                    exists (
               select
                      null
                 from
                           stn.insurance_policy  pol
                      join stn.identified_record idr on pol.row_sid = idr.row_sid
                      join stn.cession           cs  on (
                                                                pol.policy_id = cs.policy_id
                                                            and pol.feed_uuid = cs.feed_uuid
                                                        )
                where
                      cs.stream_id = csl.parent_stream_id
                  and cs.feed_uuid = csl.feed_uuid
           )
and exists (
               select
                      null
                 from
                           stn.insurance_policy  pol
                      join stn.identified_record idr on pol.row_sid = idr.row_sid
                      join stn.cession           cs  on (
                                                                pol.policy_id = cs.policy_id
                                                            and pol.feed_uuid = cs.feed_uuid
                                                        )
                where
                      cs.stream_id = csl.child_stream_id
                  and cs.feed_uuid = csl.feed_uuid
           );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated cession_link.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE INSURANCE_POLICY_FX_RATE polfxr
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                       stn.insurance_policy  pol
                  join stn.identified_record idr on pol.row_sid = idr.row_sid
            where
                  pol.policy_id = polfxr.policy_id
              and pol.feed_uuid = polfxr.feed_uuid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated insurance_policy_fx_rate.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE INSURANCE_POLICY_TAX_JURISD poltjd
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                       stn.insurance_policy  pol
                  join stn.identified_record idr on pol.row_sid = idr.row_sid
            where
                  pol.policy_id = poltjd.policy_id
              and pol.feed_uuid = poltjd.feed_uuid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated insurance_policy_tax_jurisdiction.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE INSURANCE_POLICY pol
            SET
                STEP_RUN_SID = p_step_run_sid,
                EVENT_STATUS = 'X'
            WHERE
                    pol.EVENT_STATUS = 'U'
and not exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          pol.row_sid = idr.row_sid
               )
and not exists (
                   select
                          null
                     from
                               stn.broken_feed bf
                          join stn.feed        fd on bf.feed_sid = fd.feed_sid
                    where
                          fd.feed_uuid = pol.feed_uuid
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated insurance_policy.step_run_sid [discard]', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE CESSION cs
            SET
                STEP_RUN_SID = p_step_run_sid,
                EVENT_STATUS = 'X'
            WHERE
                    cs.EVENT_STATUS = 'U'
and exists (
               select
                      null
                 from
                      stn.insurance_policy pol
                where
                      pol.event_status = 'X'
                  and pol.step_run_sid = p_step_run_sid
                  and pol.policy_id    = cs.policy_id
                  and pol.feed_uuid    = cs.feed_uuid
           );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated cession.step_run_sid [discard]', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE CESSION_LINK csl
            SET
                STEP_RUN_SID = p_step_run_sid,
                EVENT_STATUS = 'X'
            WHERE
                    csl.EVENT_STATUS = 'U'
and exists (
               select
                      null
                 from
                           stn.insurance_policy pol
                      join stn.cession          cs  on (
                                                               pol.policy_id = cs.policy_id
                                                           and pol.feed_uuid = cs.feed_uuid
                                                       )
                where
                      pol.event_status = 'X'
                  and pol.step_run_sid = p_step_run_sid
                  and cs.stream_id     = csl.parent_stream_id
                  and cs.feed_uuid     = csl.feed_uuid
           )
and exists (
               select
                      null
                 from
                           stn.insurance_policy pol
                      join stn.cession          cs  on (
                                                               pol.policy_id = cs.policy_id
                                                           and pol.feed_uuid = cs.feed_uuid
                                                       )
                where
                      pol.event_status = 'X'
                  and pol.step_run_sid = p_step_run_sid
                  and cs.stream_id     = csl.child_stream_id
                  and cs.feed_uuid     = csl.feed_uuid
           );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated cession_link.step_run_sid [discard]', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE INSURANCE_POLICY_FX_RATE polfxr
            SET
                STEP_RUN_SID = p_step_run_sid,
                EVENT_STATUS = 'X'
            WHERE
                    polfxr.EVENT_STATUS = 'U'
and exists (
               select
                      null
                 from
                      stn.insurance_policy pol
                where
                      pol.event_status = 'X'
                  and pol.step_run_sid = p_step_run_sid
                  and pol.policy_id    = polfxr.policy_id
                  and pol.feed_uuid    = polfxr.feed_uuid
           );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated insurance_policy_fx_rate.step_run_sid [discard]', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE INSURANCE_POLICY_TAX_JURISD poltjd
            SET
                STEP_RUN_SID = p_step_run_sid,
                EVENT_STATUS = 'X'
            WHERE
                    poltjd.EVENT_STATUS = 'U'
and exists (
               select
                      null
                 from
                      stn.insurance_policy pol
                where
                      pol.event_status = 'X'
                  and pol.step_run_sid = p_step_run_sid
                  and pol.policy_id    = poltjd.policy_id
                  and pol.feed_uuid    = poltjd.feed_uuid
           );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated insurance_policy_tax_jurisdiction.step_run_sid [discard]', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_policy_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_hpol_records OUT NUMBER,
            p_no_updated_fsrfr_records OUT NUMBER,
            p_no_updated_hpoltj_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE HOPPER_INSURANCE_POLICY hpol
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                    hpol.EVENT_STATUS != 'P'
and hpol.LPG_ID        = p_lpg_id
and exists (
               select
                      null
                 from
                           stn.insurance_policy  pol
                      join stn.cession           cs  on (
                                                                pol.policy_id = cs.policy_id
                                                            and pol.feed_uuid = cs.feed_uuid
                                                        )
                      join stn.identified_record idr on pol.row_sid   = idr.row_sid
                where
                      cs.stream_id    = hpol.stream_id
                  and cs.event_status = 'U'
           );
        p_no_updated_hpol_records := SQL%ROWCOUNT;
        UPDATE fdr.FR_STAN_RAW_FX_RATE fsrfr
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                    fsrfr.EVENT_STATUS != 'P'
and fsrfr.LPG_ID        = p_lpg_id
and exists (
               select
                      null
                 from
                           stn.insurance_policy  pol
                      join stn.insurance_policy_fx_rate  ipfr  on (
                                                                          pol.policy_id = ipfr.policy_id
                                                                      and pol.feed_uuid = ipfr.feed_uuid
                                                                  )
                      join stn.identified_record idr on pol.row_sid   = idr.row_sid
                where
                      ipfr.row_sid      = fsrfr.message_id
                  and ipfr.event_status = 'U'
           )
and exists (
               select
                      null
                 from
                           stn.step_run sr
                      join stn.step     s  on sr.step_id   = s.step_id
                      join stn.process  p  on s.process_id = p.process_id
                where
                      sr.step_run_sid = to_number ( fsrfr.PROCESS_ID )
                  and p.process_name  = 'insurance_policy-standardise'
           );
        p_no_updated_fsrfr_records := SQL%ROWCOUNT;
        UPDATE HOPPER_INSURANCE_POLICY_TJ hpoltj
            SET
                EVENT_STATUS = 'X',
                PROCESS_ID = TO_CHAR(p_step_run_sid)
            WHERE
                    hpoltj.EVENT_STATUS != 'P'
and hpoltj.LPG_ID        = p_lpg_id
and exists (
               select
                      null
                 from
                           stn.insurance_policy  pol
                      join stn.insurance_policy_tax_jurisd  iptj  on (
                                                                          pol.policy_id = iptj.policy_id
                                                                      and pol.feed_uuid = iptj.feed_uuid
                                                                     )
                      join stn.identified_record idr on pol.row_sid   = idr.row_sid
                where
                      iptj.row_sid      = hpoltj.message_id
                  and iptj.event_status = 'U'
           )
and exists (
               select
                      null
                 from
                           stn.step_run sr
                      join stn.step     s  on sr.step_id   = s.step_id
                      join stn.process  p  on s.process_id = p.process_id
                where
                      sr.step_run_sid = to_number ( hpoltj.PROCESS_ID )
                  and p.process_name  = 'insurance_policy-standardise'
           );
        p_no_updated_hpoltj_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_policy_rval
        (
            p_step_run_sid IN NUMBER
        )
    AS
    BEGIN
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : pol-transaction_ccy', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                pol.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                pol.TRANSACTION_CCY AS ERROR_VALUE,
                pol.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                pol.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                INSURANCE_POLICY pol
                INNER JOIN IDENTIFIED_RECORD idr ON pol.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON pol.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON pol.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'pol-transaction_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = pol.TRANSACTION_CCY
                      and fcl.cul_sil_sys_inst_clicode = pold.SYSTEM_INSTANCE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : pol-transaction_ccy', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : pol-underwriting_le_id', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                pol.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(pol.UNDERWRITING_LE_ID) AS ERROR_VALUE,
                pol.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                pol.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                INSURANCE_POLICY pol
                INNER JOIN IDENTIFIED_RECORD idr ON pol.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON pol.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON pol.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'pol-underwriting_le_id'
and not exists (
                   select
                          null
                     from
                               fdr.fr_party_legal_lookup fpll
                          join fdr.fr_party_legal        fpl  on (
                                                                         fpll.pll_lookup_key           = fpl.pl_party_legal_clicode
                                                                     and fpll.pll_sil_sys_inst_clicode = fpl.pl_si_sys_inst_id
                                                                 )
                    where
                          to_number ( fpl.pl_global_id ) = pol.UNDERWRITING_LE_ID
                      and fpll.pll_sil_sys_inst_clicode  = pold.SYSTEM_INSTANCE
                      and fpl.pl_global_id is not null
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : pol-underwriting_le_id', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : polfxr-to_ccy', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                polfxr.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                polfxr.TO_CCY AS ERROR_VALUE,
                polfxr.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                polfxr.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                INSURANCE_POLICY_FX_RATE polfxr
                INNER JOIN FEED fd ON polfxr.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON polfxr.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'polfxr-to_ccy'
and     exists (
                   select
                          null
                     from
                               stn.insurance_policy  pol
                          join stn.identified_record idr on pol.row_sid = idr.row_sid
                    where
                          pol.policy_id = polfxr.policy_id
                      and pol.feed_uuid = polfxr.FEED_UUID
               )
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = polfxr.TO_CCY
                      and fcl.cul_sil_sys_inst_clicode = pold.SYSTEM_INSTANCE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation :  polfxr-to_ccy', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : polfxr-from_ccy', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                polfxr.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                polfxr.FROM_CCY AS ERROR_VALUE,
                polfxr.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                polfxr.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                INSURANCE_POLICY_FX_RATE polfxr
                INNER JOIN FEED fd ON polfxr.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON polfxr.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'polfxr-from_ccy'
and     exists (
                   select
                          null
                     from
                               stn.insurance_policy  pol
                          join stn.identified_record idr on pol.row_sid = idr.row_sid
                    where
                          pol.policy_id = polfxr.policy_id
                      and pol.feed_uuid = polfxr.FEED_UUID
               )
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = polfxr.FROM_CCY
                      and fcl.cul_sil_sys_inst_clicode = pold.SYSTEM_INSTANCE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation :  polfxr-from_ccy', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : cs-le_id', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                cs.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(cs.LE_ID) AS ERROR_VALUE,
                cs.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                cs.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION cs
                INNER JOIN FEED fd ON cs.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cs.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'cs-le_id'
and     exists (
                   select
                          null
                     from
                               stn.insurance_policy  pol
                          join stn.identified_record idr on pol.row_sid = idr.row_sid
                    where
                          pol.policy_id = cs.policy_id
                      and pol.feed_uuid = cs.FEED_UUID
               )
and not exists (
                   select
                          null
                     from
                               fdr.fr_party_legal_lookup fpll
                          join fdr.fr_party_legal        fpl  on (
                                                                         fpll.pll_lookup_key           = fpl.pl_party_legal_clicode
                                                                     and fpll.pll_sil_sys_inst_clicode = fpl.pl_si_sys_inst_id
                                                                 )
                    where
                          to_number ( fpl.pl_global_id ) = cs.LE_ID
                      and fpll.pll_sil_sys_inst_clicode  = pold.SYSTEM_INSTANCE
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation :  cs-le_id', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : cs-vie_acct_dt', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                cs.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                'vie_acct_dt cannot be null' AS ERROR_VALUE,
                cs.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                cs.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION cs
                INNER JOIN FEED fd ON cs.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cs.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'cs-vie_acct_dt'
and (
        cs.VIE_STATUS   in ( 'CONSO' , 'DECONSO' )
    and cs.VIE_ACCT_DT  is null
    )
and  exists (
                select
                       null
                  from
                            stn.insurance_policy  pol
                       join stn.identified_record idr on pol.row_sid = idr.row_sid
                 where
                       pol.policy_id = cs.policy_id
                   and pol.feed_uuid = cs.FEED_UUID
            )
;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation :  cs-vie_acct_dt', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : cs-vie_eff_dt', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                cs.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                'vie_effective_dt cannot be null' AS ERROR_VALUE,
                cs.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                cs.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION cs
                INNER JOIN FEED fd ON cs.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cs.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'cs-vie_eff_dt'
and (
        cs.VIE_STATUS   in ( 'CONSO' , 'DECONSO' )
    and cs.VIE_EFFECTIVE_DT  is null
    )
and  exists (
                select
                       null
                  from
                            stn.insurance_policy  pol
                       join stn.identified_record idr on pol.row_sid = idr.row_sid
                 where
                       pol.policy_id = cs.policy_id
                   and pol.feed_uuid = cs.FEED_UUID
            )
;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation :  cs-vie_eff_dt', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : cl-stream_policies', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                cl.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                'Child stream''s policy ID = ''' || TO_CHAR(pcs.POLICY_ID) || ''' ; Parent stream''s policy ID = ''' || TO_CHAR(ccs.POLICY_ID) || '''' AS ERROR_VALUE,
                cl.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                cl.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_LINK cl
                INNER JOIN CESSION pcs ON cl.PARENT_STREAM_ID = pcs.STREAM_ID AND cl.FEED_UUID = pcs.FEED_UUID
                INNER JOIN CESSION ccs ON cl.PARENT_STREAM_ID = ccs.STREAM_ID AND cl.FEED_UUID = ccs.FEED_UUID
                INNER JOIN FEED fd ON cl.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cl.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD  = 'cl-stream_policies'
and pcs.POLICY_ID     != ccs.POLICY_ID
and (
           exists (
                      select
                             null
                        from
                                  stn.insurance_policy  pol
                             join stn.identified_record idr on pol.row_sid = idr.row_sid
                       where
                             pcs.POLICY_ID = pol.policy_id
                         and pcs.FEED_UUID = pol.feed_uuid
                  )
        or exists (
                      select
                             null
                        from
                                  stn.insurance_policy  pol
                             join stn.identified_record idr on pol.row_sid = idr.row_sid
                       where
                             ccs.POLICY_ID = pol.policy_id
                         and ccs.FEED_UUID = pol.feed_uuid
                  )
    );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation :  cl-stream_policies', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : cs-le_id-slr_link', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                cs.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(cs.LE_ID) AS ERROR_VALUE,
                cs.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                cs.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION cs
                INNER JOIN FEED fd ON cs.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cs.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'cs-le_id-slr_link'
and     exists (
                   select
                          null
                     from
                               stn.insurance_policy  pol
                          join stn.identified_record idr on pol.row_sid = idr.row_sid
                    where
                          pol.policy_id = cs.policy_id
                      and pol.feed_uuid = cs.FEED_UUID
               )
and not exists (
                   select
                          null
                     from
                          stn.cession_hierarchy ch
                    where
                          ch.feed_uuid       = cs.FEED_UUID
                      and ch.child_stream_id = cs.stream_id
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation :  cs-le_id-slr_link', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_policy_svs
        (
            p_step_run_sid IN NUMBER,
            p_no_validated_cession_records OUT NUMBER,
            p_no_errored_cession_records OUT NUMBER,
            p_no_validated_fx_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE INSURANCE_POLICY pol
            SET
                EVENT_STATUS = 'E'
            WHERE
                       exists (
                  select
                         null
                    from
                         stn.standardisation_log sl
                   where
                         sl.table_in_error_name = 'insurance_policy'
                     and sl.row_in_error_key_id = pol.row_sid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession                    cs
                         join stn.standardisation_log        sl  on cs.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'cession'
                     and cs.policy_id           = pol.policy_id
                     and cs.feed_uuid           = pol.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.insurance_policy_fx_rate polfxr
                         join stn.standardisation_log      sl     on polfxr.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'insurance_policy_fx_rate'
                     and polfxr.policy_id       = pol.policy_id
                     and polfxr.feed_uuid       = pol.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession_link        cl
                         join stn.standardisation_log sl on cl.row_sid = sl.row_in_error_key_id
                         join stn.cession             cs on (
                                                                    cl.parent_stream_id = cs.stream_id
                                                                and cl.feed_uuid        = cs.feed_uuid
                                                            )
                   where
                         sl.table_in_error_name = 'cession_link'
                     and cs.policy_id           = pol.policy_id
                     and cs.feed_uuid           = pol.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession_link        cl
                         join stn.standardisation_log sl on cl.row_sid = sl.row_in_error_key_id
                         join stn.cession             cs on (
                                                                    cl.child_stream_id = cs.stream_id
                                                                and cl.feed_uuid       = cs.feed_uuid
                                                            )
                   where
                         sl.table_in_error_name = 'cession_link'
                     and cs.policy_id           = pol.policy_id
                     and cs.feed_uuid           = pol.feed_uuid
              );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of insurance_policy records set to error', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE INSURANCE_POLICY_FX_RATE polfxr
            SET
                EVENT_STATUS = 'E'
            WHERE
                       exists (
                  select
                         null
                    from
                              stn.insurance_policy_fx_rate   polfxri
                         join stn.standardisation_log        sl      on polfxri.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'insurance_policy_fx_rate'
                     and polfxri.policy_id      = polfxr.policy_id
                     and polfxri.feed_uuid      = polfxr.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.insurance_policy    pol
                         join stn.standardisation_log sl  on pol.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'insurance_policy'
                     and pol.policy_id          = polfxr.policy_id
                     and pol.feed_uuid          = polfxr.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession             cs
                         join stn.standardisation_log sl on cs.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'cession'
                     and cs.policy_id           = polfxr.policy_id
                     and cs.feed_uuid           = polfxr.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession_link        cl
                         join stn.standardisation_log sl on cl.row_sid = sl.row_in_error_key_id
                         join stn.cession             cs on (
                                                                    cl.parent_stream_id = cs.stream_id
                                                                and cl.feed_uuid        = cs.feed_uuid
                                                            )
                   where
                         sl.table_in_error_name = 'cession_link'
                     and cs.policy_id           = polfxr.policy_id
                     and cs.feed_uuid           = polfxr.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession_link        cl
                         join stn.standardisation_log sl on cl.row_sid = sl.row_in_error_key_id
                         join stn.cession             cs on (
                                                                    cl.child_stream_id = cs.stream_id
                                                                and cl.feed_uuid       = cs.feed_uuid
                                                            )
                   where
                         sl.table_in_error_name = 'cession_link'
                     and cs.policy_id           = polfxr.policy_id
                     and cs.feed_uuid           = polfxr.feed_uuid
              );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of insurance_policy_fx_rate records set to error', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE INSURANCE_POLICY_TAX_JURISD poltjd
            SET
                EVENT_STATUS = 'E'
            WHERE
                       exists (
                  select
                         null
                    from
                              stn.insurance_policy_fx_rate ipfr
                         join stn.standardisation_log      sl   on ipfr.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'insurance_policy_fx_rate'
                     and ipfr.policy_id         = poltjd.policy_id
                     and ipfr.feed_uuid         = poltjd.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.insurance_policy    pol
                         join stn.standardisation_log sl  on pol.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'insurance_policy'
                     and pol.policy_id          = poltjd.policy_id
                     and pol.feed_uuid          = poltjd.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession             cs
                         join stn.standardisation_log sl on cs.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'cession'
                     and cs.policy_id           = poltjd.policy_id
                     and cs.feed_uuid           = poltjd.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession_link        cl
                         join stn.standardisation_log sl on cl.row_sid = sl.row_in_error_key_id
                         join stn.cession             cs on (
                                                                    cl.parent_stream_id = cs.stream_id
                                                                and cl.feed_uuid        = cs.feed_uuid
                                                            )
                   where
                         sl.table_in_error_name = 'cession_link'
                     and cs.policy_id           = poltjd.policy_id
                     and cs.feed_uuid           = poltjd.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession_link        cl
                         join stn.standardisation_log sl on cl.row_sid = sl.row_in_error_key_id
                         join stn.cession             cs on (
                                                                    cl.child_stream_id = cs.stream_id
                                                                and cl.feed_uuid       = cs.feed_uuid
                                                            )
                   where
                         sl.table_in_error_name = 'cession_link'
                     and cs.policy_id           = poltjd.policy_id
                     and cs.feed_uuid           = poltjd.feed_uuid
              );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of insurance_policy_tax_jurisdiction records set to error', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE CESSION cs
            SET
                EVENT_STATUS = 'E'
            WHERE
                       exists (
                  select
                         null
                    from
                              stn.cession             csi
                         join stn.standardisation_log sl   on csi.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'cession'
                     and csi.policy_id          = cs.policy_id
                     and csi.feed_uuid          = cs.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.insurance_policy    pol
                         join stn.standardisation_log sl  on pol.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'insurance_policy'
                     and pol.policy_id          = cs.policy_id
                     and pol.feed_uuid          = cs.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.insurance_policy_fx_rate ipfr
                         join stn.standardisation_log      sl   on ipfr.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'insurance_policy_fx_rate'
                     and ipfr.policy_id         = cs.policy_id
                     and ipfr.feed_uuid         = cs.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession_link        cl
                         join stn.standardisation_log sl  on cl.row_sid = sl.row_in_error_key_id
                         join stn.cession             csi on (
                                                                     cl.parent_stream_id = csi.stream_id
                                                                 and cl.feed_uuid        = csi.feed_uuid
                                                             )
                   where
                         sl.table_in_error_name = 'cession_link'
                     and csi.policy_id          = cs.policy_id
                     and csi.feed_uuid          = cs.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.cession_link        cl
                         join stn.standardisation_log sl  on cl.row_sid = sl.row_in_error_key_id
                         join stn.cession             csi on (
                                                                     cl.child_stream_id = csi.stream_id
                                                                 and cl.feed_uuid       = csi.feed_uuid
                                                             )
                   where
                         sl.table_in_error_name = 'cession_link'
                     and csi.policy_id          = cs.policy_id
                     and csi.feed_uuid          = cs.feed_uuid
              );
        p_no_errored_cession_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of cession records set to error', 'p_no_errored_cession_records', NULL, p_no_errored_cession_records, NULL);
        UPDATE CESSION_LINK cl
            SET
                EVENT_STATUS = 'E'
            WHERE
                       exists (
                  select
                         null
                    from
                              stn.insurance_policy    pol
                         join stn.standardisation_log sl  on pol.row_sid = sl.row_in_error_key_id
                         join stn.cession             cs  on (
                                                                     pol.policy_id = cs.policy_id
                                                                 and pol.feed_uuid = cs.feed_uuid
                                                             )
                  where
                         sl.table_in_error_name = 'insurance_policy'
                     and cs.stream_id           = cl.parent_stream_id
                     and cs.feed_uuid           = cl.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.insurance_policy    pol
                         join stn.standardisation_log sl  on pol.row_sid = sl.row_in_error_key_id
                         join stn.cession             cs  on (
                                                                     pol.policy_id = cs.policy_id
                                                                 and pol.feed_uuid = cs.feed_uuid
                                                             )
                  where
                         sl.table_in_error_name = 'insurance_policy'
                     and cs.stream_id           = cl.child_stream_id
                     and cs.feed_uuid           = cl.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.insurance_policy    pol
                         join stn.cession             cs  on (
                                                                     pol.policy_id = cs.policy_id
                                                                 and pol.feed_uuid = cs.feed_uuid
                                                             )
                         join stn.standardisation_log sl  on cs.row_sid = sl.row_in_error_key_id
                  where
                         sl.table_in_error_name = 'cession'
                     and cs.stream_id           = cl.parent_stream_id
                     and cs.feed_uuid           = cl.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.insurance_policy    pol
                         join stn.cession             cs  on (
                                                                     pol.policy_id = cs.policy_id
                                                                 and pol.feed_uuid = cs.feed_uuid
                                                             )
                         join stn.standardisation_log sl  on cs.row_sid = sl.row_in_error_key_id
                  where
                         sl.table_in_error_name = 'cession'
                     and cs.stream_id           = cl.child_stream_id
                     and cs.feed_uuid           = cl.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.insurance_policy         pol
                         join stn.cession                  cs     on (
                                                                             pol.policy_id = cs.policy_id
                                                                         and pol.feed_uuid = cs.feed_uuid
                                                                     )
                         join stn.insurance_policy_fx_rate polfxr on (
                                                                             pol.policy_id = polfxr.policy_id
                                                                         and pol.feed_uuid = polfxr.feed_uuid
                                                                     )
                         join stn.standardisation_log      sl     on polfxr.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'insurance_policy_fx_rate'
                     and cs.stream_id           = cl.parent_stream_id
                     and cs.feed_uuid           = cl.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                              stn.insurance_policy         pol
                         join stn.cession                  cs     on (
                                                                             pol.policy_id = cs.policy_id
                                                                         and pol.feed_uuid = cs.feed_uuid
                                                                     )
                         join stn.insurance_policy_fx_rate polfxr on (
                                                                             pol.policy_id = polfxr.policy_id
                                                                         and pol.feed_uuid = polfxr.feed_uuid
                                                                     )
                         join stn.standardisation_log      sl     on polfxr.row_sid = sl.row_in_error_key_id
                   where
                         sl.table_in_error_name = 'insurance_policy_fx_rate'
                     and cs.stream_id           = cl.child_stream_id
                     and cs.feed_uuid           = cl.feed_uuid
              )
    or exists (
                  select
                         null
                    from
                         stn.cession_hierarchy ch1
                   where
                         ch1.parent_stream_id = cl.parent_stream_id
                     and ch1.child_stream_id  = cl.child_stream_id
                     and ch1.feed_uuid        = cl.feed_uuid
                     and exists (
                                    select
                                           null
                                      from
                                                stn.cession_link        cli
                                           join stn.standardisation_log sl   on cli.row_sid = sl.row_in_error_key_id
                                           join stn.cession_hierarchy   ch2  on (
                                                                                        cli.parent_stream_id = ch2.parent_stream_id
                                                                                    and cli.child_stream_id  = ch2.child_stream_id
                                                                                    and cli.feed_uuid        = ch2.feed_uuid
                                                                                )
                                     where
                                           sl.table_in_error_name        = 'cession_link'
                                       and ch1.ultimate_parent_stream_id = ch2.ultimate_parent_stream_id
                                       and ch1.feed_uuid                 = ch2.feed_uuid
                                ) 
              );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of cession link records set to error', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE INSURANCE_POLICY pol
            SET
                EVENT_STATUS = 'V'
            WHERE
                    pol.EVENT_STATUS = 'U';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of policy records set to passed validation', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE INSURANCE_POLICY_FX_RATE polfxr
            SET
                EVENT_STATUS = 'V'
            WHERE
                    polfxr.EVENT_STATUS = 'U';
        p_no_validated_fx_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of policy fx rate records set to passed validation', 'p_no_validated_fx_records', NULL, p_no_validated_fx_records, NULL);
        UPDATE INSURANCE_POLICY_TAX_JURISD poltjd
            SET
                EVENT_STATUS = 'V'
            WHERE
                    poltjd.EVENT_STATUS = 'U';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of policy tax jurisdiction records set to passed validation', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE CESSION cs
            SET
                EVENT_STATUS = 'V'
            WHERE
                    cs.EVENT_STATUS = 'U';
        p_no_validated_cession_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of cession records set to passed validation', 'p_no_validated_cession_records', NULL, p_no_validated_cession_records, NULL);
        UPDATE CESSION_LINK cl
            SET
                EVENT_STATUS = 'V'
            WHERE
                    cl.EVENT_STATUS = 'U';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of cession link records set to passed validation', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_policy_pub
        (
            p_step_run_sid IN NUMBER,
            p_total_no_fsrip_published OUT NUMBER,
            p_total_no_fsriptj_published OUT NUMBER,
            p_total_no_pol_tj_updated OUT NUMBER,
            p_total_no_fsrfr_published OUT NUMBER,
            p_total_no_frt_published OUT NUMBER,
            p_total_no_pol_fx_rate_deleted OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO HOPPER_INSURANCE_POLICY
            (POLICY_ID, POLICY_NM, POLICY_ABBR_NM, ORIGINAL_POLICY_ID, UNDERWRITING_LE_CD, EXTERNAL_LE_CD, CLOSE_DT, EXPECTED_MATURITY_DT, POLICY_UNDERWRITING_YR, POLICY_ACCIDENT_YR, POLICY_TYP, POLICY_PREMIUM_TYP, IS_CREDIT_DEFAULT_SWAP, IS_MARK_TO_MARKET, EXECUTION_TYP, TRANSACTION_CCY, IS_UNCOLLECTIBLE, EARNINGS_CALC_METHOD, STREAM_ID, ULTIMATE_PARENT_STREAM_ID, PARENT_STREAM_ID, LE_CD, CESSION_TYP, GROSS_PAR_PCT, NET_PAR_PCT, GROSS_PREMIUM_PCT, CEDING_COMMISSION_PCT, NET_PREMIUM_PCT, START_DT, EFFECTIVE_DT, STOP_DT, TERMINATION_DT, LOSS_POS, VIE_STATUS, VIE_EFFECTIVE_DT, VIE_ACCT_DT, ACCIDENT_YR, UNDERWRITING_YR, PORTFOLIO_CD, BUY_OR_SELL, POLICY_HOLDER_LE_CD, SYSTEM_CD, POLICY_HOLDER_ADDRESS, INSTRUMENT_TYPE, EVENT_CODE, MESSAGE_ID, PROCESS_ID, FINANCIAL_INSTRUMENT_ID, POLICY_NAME_STREAM_ID, POLICY_VERSION)
            SELECT
                pol.POLICY_ID AS POLICY_ID,
                pol.POLICY_NM AS POLICY_NM,
                pol.POLICY_ABBR_NM AS POLICY_ABBR_NM,
                pol.ORIGINAL_POLICY_ID AS ORIGINAL_POLICY_ID,
                underwriting_le.PL_PARTY_LEGAL_CLICODE AS UNDERWRITING_LE_CD,
                external_le.PL_PARTY_LEGAL_CLICODE AS EXTERNAL_LE_CD,
                pol.CLOSE_DT AS CLOSE_DT,
                pol.EXPECTED_MATURITY_DT AS EXPECTED_MATURITY_DT,
                pol.POLICY_UNDERWRITING_YR AS POLICY_UNDERWRITING_YR,
                TO_CHAR(pol.POLICY_ACCIDENT_YR) AS POLICY_ACCIDENT_YR,
                pol.POLICY_TYP AS POLICY_TYP,
                pol.POLICY_PREMIUM_TYP AS POLICY_PREMIUM_TYP,
                pol.IS_CREDIT_DEFAULT_SWAP AS IS_CREDIT_DEFAULT_SWAP,
                pol.IS_MARK_TO_MARKET AS IS_MARK_TO_MARKET,
                pol.EXECUTION_TYP AS EXECUTION_TYP,
                pol.TRANSACTION_CCY AS TRANSACTION_CCY,
                pol.IS_UNCOLLECTIBLE AS IS_UNCOLLECTIBLE,
                pol.EARNINGS_CALC_METHOD AS EARNINGS_CALC_METHOD,
                TO_CHAR(cs.STREAM_ID) AS STREAM_ID,
                TO_CHAR(ch.ultimate_parent_stream_id) AS ULTIMATE_PARENT_STREAM_ID,
                TO_CHAR((CASE
                    WHEN ch.parent_stream_id = cs.STREAM_ID THEN NULL
                    ELSE ch.parent_stream_id
                END)) AS PARENT_STREAM_ID,
                ch.ledger_entity_le_cd AS LE_CD,
                cs.CESSION_TYP AS CESSION_TYP,
                cs.GROSS_PAR_PCT AS GROSS_PAR_PCT,
                cs.NET_PAR_PCT AS NET_PAR_PCT,
                cs.GROSS_PREMIUM_PCT AS GROSS_PREMIUM_PCT,
                cs.CEDING_COMMISSION_PCT AS CEDING_COMMISSION_PCT,
                cs.NET_PREMIUM_PCT AS NET_PREMIUM_PCT,
                cs.START_DT AS START_DT,
                cs.EFFECTIVE_DT AS EFFECTIVE_DT,
                cs.STOP_DT AS STOP_DT,
                cs.TERMINATION_DT AS TERMINATION_DT,
                cs.LOSS_POS AS LOSS_POS,
                cs.VIE_STATUS AS VIE_STATUS,
                cs.VIE_EFFECTIVE_DT AS VIE_EFFECTIVE_DT,
                cs.VIE_ACCT_DT AS VIE_ACCT_DT,
                cs.ACCIDENT_YR AS ACCIDENT_YR,
                cs.UNDERWRITING_YR AS UNDERWRITING_YR,
                ch.ledger_entity_le_cd AS PORTFOLIO_CD,
                pold.BUY_OR_SELL AS BUY_OR_SELL,
                cession_le.PL_PARTY_LEGAL_CLICODE AS POLICY_HOLDER_LE_CD,
                pold.SYSTEM_INSTANCE AS SYSTEM_CD,
                pold.POLICY_HOLDER_ADDRESS AS POLICY_HOLDER_ADDRESS,
                pold.INSTRUMENT_TYPE AS INSTRUMENT_TYPE,
                pold.EVENT_CODE AS EVENT_CODE,
                TO_CHAR(cs.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                TO_CHAR(cs.STREAM_ID) AS FINANCIAL_INSTRUMENT_ID,
                pol.POLICY_ABBR_NM || ' - ' || TO_CHAR(cs.STREAM_ID) AS POLICY_NAME_STREAM_ID,
                NVL(pdtvn.t_fdr_ver_no, 0) + 1 AS POLICY_VERSION
            FROM
                INSURANCE_POLICY pol
                INNER JOIN IDENTIFIED_RECORD idr ON pol.ROW_SID = idr.ROW_SID
                INNER JOIN CESSION cs ON pol.POLICY_ID = cs.POLICY_ID AND pol.FEED_UUID = cs.FEED_UUID
                INNER JOIN cession_hierarchy ch ON cs.STREAM_ID = ch.child_stream_id AND cs.FEED_UUID = ch.feed_uuid
                INNER JOIN fdr.FR_PARTY_LEGAL underwriting_le ON pol.UNDERWRITING_LE_ID = to_number ( underwriting_le.PL_GLOBAL_ID )
                LEFT OUTER JOIN fdr.FR_PARTY_LEGAL external_le ON     pol.EXTERNAL_LE_ID    = to_number ( external_le.PL_GLOBAL_ID )
and external_le.pl_active = 'A'
                INNER JOIN fdr.FR_PARTY_LEGAL cession_le ON cs.LE_ID = to_number ( cession_le.PL_GLOBAL_ID )
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                LEFT OUTER JOIN (SELECT
                    fiie.iie_cover_signing_party AS policy_id,
                    to_number ( ft.t_source_tran_no ) AS stream_id,
                    MAX(ft.t_fdr_ver_no) AS t_fdr_ver_no
                FROM
                    fdr.fr_trade ft
                    INNER JOIN fdr.fr_instr_insure_extend fiie ON ft.t_i_instrument_id = fiie.iie_instrument_id
                GROUP BY
                    fiie.iie_cover_signing_party,
                    to_number ( ft.t_source_tran_no )) pdtvn ON pol.POLICY_ID = pdtvn.policy_id AND cs.STREAM_ID = pdtvn.stream_id
            WHERE
                pol.EVENT_STATUS = 'V' AND cs.EVENT_STATUS = 'V' AND underwriting_le.PL_ACTIVE = 'A' AND cession_le.PL_ACTIVE = 'A';
        p_total_no_fsrip_published := SQL%ROWCOUNT;
        INSERT INTO HOPPER_INSURANCE_POLICY_TJ
            (POLICY_TAX, POLICY_ID_TAX_CD, POLICY_ID, TAX_JURISDICTION_CD, TAX_JURISDICTION_PCT, TAX_JURISDICTION_STS, MESSAGE_ID, PROCESS_ID, LPG_ID, VALID_FROM)
            SELECT
                pold.POLICY_TAX AS POLICY_TAX,
                poltjd.POLICY_ID || '_' || poltjd.TAX_JURISDICTION_CD AS POLICY_ID_TAX_CD,
                poltjd.POLICY_ID AS POLICY_ID,
                poltjd.TAX_JURISDICTION_CD AS TAX_JURISDICTION_CD,
                TO_CHAR(poltjd.TAX_JURISDICTION_PCT) AS TAX_JURISDICTION_PCT,
                'A' AS TAX_JURISDICTION_STS,
                TO_CHAR(poltjd.ROW_SID) AS MESSAGE_ID,
                TO_CHAR(poltjd.STEP_RUN_SID) AS PROCESS_ID,
                poltjd.LPG_ID AS LPG_ID,
                fd.EFFECTIVE_DT AS VALID_FROM
            FROM
                INSURANCE_POLICY_TAX_JURISD poltjd
                INNER JOIN POL_DEFAULT pold ON 1 = 1
                INNER JOIN FEED fd ON poltjd.FEED_UUID = fd.FEED_UUID
            WHERE
                poltjd.EVENT_STATUS = 'V';
        p_total_no_fsriptj_published := SQL%ROWCOUNT;
        UPDATE fdr.FR_GENERAL_CODES
            SET
                GC_ACTIVE = 'I',
                GC_VALID_TO = CURRENT_DATE - 1
            WHERE
                    FR_GENERAL_CODES.GC_GCT_CODE_TYPE_ID = 'POLICY_TAX'
and exists
   (
     select
           null
     from 
           stn.insurance_policy_tax_jurisd iptj
     where 
            iptj.policy_id            = FR_GENERAL_CODES.GC_CLIENT_TEXT1
        and iptj.event_status         = 'V'
   )
and not exists
   (
     select
           null
     from 
           stn.insurance_policy_tax_jurisd iptj
     where 
            iptj.policy_id            = FR_GENERAL_CODES.GC_CLIENT_TEXT1
        and iptj.tax_jurisdiction_cd  = FR_GENERAL_CODES.GC_CLIENT_TEXT2
        and iptj.event_status         = 'V'
   );
        p_total_no_pol_tj_updated := SQL%ROWCOUNT;
        INSERT INTO fdr.FR_RATE_TYPE
            (RTY_RATE_TYPE_ID, RTY_RATE_TYPE_DESCRIPTION, RTY_ACTIVE, RTY_INPUT_BY, RTY_AUTH_BY, RTY_AUTH_STATUS, RTY_INPUT_TIME, RTY_VALID_FROM, RTY_VALID_TO)
            SELECT
                pold.RATE_TYPE_PREFIX || polfxr.POLICY_ID AS RTY_RATE_TYPE_ID,
                pold.RATE_TYPE_PREFIX || polfxr.POLICY_ID AS RTY_RATE_TYPE_DESCRIPTION,
                'A' AS RTY_ACTIVE,
                USER AS RTY_INPUT_BY,
                USER AS RTY_AUTH_BY,
                'A' AS RTY_AUTH_STATUS,
                sysdate AS RTY_INPUT_TIME,
                sysdate AS RTY_VALID_FROM,
                sysdate + interval '99' year AS RTY_VALID_TO
            FROM
                INSURANCE_POLICY_FX_RATE polfxr
                INNER JOIN POL_DEFAULT pold ON 1 = 1
            WHERE
                    polfxr.EVENT_STATUS = 'V'
and     exists (
                   select
                          null
                     from
                               stn.insurance_policy  pol
                          join stn.identified_record idr on pol.row_sid = idr.row_sid
                    where
                          pol.policy_id = polfxr.POLICY_ID
                      and pol.feed_uuid = polfxr.FEED_UUID
               )
and not exists (
                   select
                          null
                     from
                          fdr.fr_rate_type frt
                    where
                          frt.rty_rate_type_id = pold.RATE_TYPE_PREFIX || polfxr.POLICY_ID
               )
            GROUP BY
                polfxr.POLICY_ID,
                pold.RATE_TYPE_PREFIX;
        p_total_no_frt_published := SQL%ROWCOUNT;
        INSERT INTO fdr.FR_STAN_RAW_FX_RATE
            (SRF_FR_FXRATE_DATE, SRF_FR_FXRATE_DATE_FWD, SRF_FR_CU_CURRENCY_NUMER_CODE, SRF_FR_CU_CURRENCY_DENOM_CODE, LPG_ID, SRF_FR_RTY_RATE_TYPE_ID, MESSAGE_ID, SRF_FR_SI_SYS_INST_CODE, SRF_FR_PL_PARTY_LEGAL_CODE, SRF_FR_FX_RATE, PROCESS_ID)
            SELECT
                pol.CLOSE_DT AS SRF_FR_FXRATE_DATE,
                pol.CLOSE_DT AS SRF_FR_FXRATE_DATE_FWD,
                polfxr.FROM_CCY AS SRF_FR_CU_CURRENCY_NUMER_CODE,
                polfxr.TO_CCY AS SRF_FR_CU_CURRENCY_DENOM_CODE,
                polfxr.LPG_ID AS LPG_ID,
                pold.RATE_TYPE_PREFIX || polfxr.POLICY_ID AS SRF_FR_RTY_RATE_TYPE_ID,
                TO_CHAR(polfxr.ROW_SID) AS MESSAGE_ID,
                pold.SYSTEM_INSTANCE AS SRF_FR_SI_SYS_INST_CODE,
                pold.PARTY_LEGAL AS SRF_FR_PL_PARTY_LEGAL_CODE,
                polfxr.RATE AS SRF_FR_FX_RATE,
                TO_CHAR(polfxr.STEP_RUN_SID) AS PROCESS_ID
            FROM
                INSURANCE_POLICY_FX_RATE polfxr
                INNER JOIN INSURANCE_POLICY pol ON polfxr.POLICY_ID = pol.POLICY_ID AND polfxr.FEED_UUID = pol.FEED_UUID
                INNER JOIN POL_DEFAULT pold ON 1 = 1
            WHERE
                polfxr.EVENT_STATUS = 'V';
        p_total_no_fsrfr_published := SQL%ROWCOUNT;
        DELETE FROM
            fdr.FR_FX_RATE FR_FX_RATE
        WHERE
                    FR_FX_RATE.FR_RTY_RATE_TYPE_ID like '/POL/%'
and exists
   (
     select
           null
      from
           stn.insurance_policy_fx_rate ipfr
      join stn.insurance_policy ip
           on ip.policy_id    = ipfr.policy_id
          and ip.step_run_sid = ipfr.step_run_sid
     where 
            '/POL/' || ipfr.policy_id  = FR_FX_RATE.FR_RTY_RATE_TYPE_ID
        and ipfr.event_status          = 'V'
   )
and not exists
   (
     select
           null
      from
           stn.insurance_policy_fx_rate ipfr
      join stn.insurance_policy ip
           on ip.policy_id    = ipfr.policy_id
          and ip.step_run_sid = ipfr.step_run_sid
     where 
            ip.CLOSE_DT                = FR_FX_RATE.FR_FXRATE_DATE
        and ipfr.from_ccy              = FR_FX_RATE.FR_CU_CURRENCY_NUMER_ID
        and ipfr.to_ccy                = FR_FX_RATE.FR_CU_CURRENCY_DENOM_ID
        and '/POL/' || ipfr.policy_id  = FR_FX_RATE.FR_RTY_RATE_TYPE_ID
        and ipfr.event_status          = 'V'
   );
        p_total_no_pol_fx_rate_deleted := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_policy_sps
        (
            p_no_fsrip_processed_records OUT NUMBER,
            p_no_fsriptj_processed_records OUT NUMBER,
            p_no_fsrfr_processed_records OUT NUMBER,
            p_no_ip_processed_records OUT NUMBER,
            p_no_cl_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE CESSION cs
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       stn.hopper_insurance_policy hip
                  join stn.cession                 csil on to_number ( hip.message_id ) = csil.row_sid
                  join stn.insurance_policy        pol  on (
                                                                   csil.policy_id = pol.policy_id
                                                               and csil.feed_uuid = pol.feed_uuid
                                                           )
                  join stn.identified_record       idr  on pol.row_sid = idr.row_sid
            where
                  to_number ( hip.message_id ) = cs.ROW_SID
       );
        p_no_fsrip_processed_records := SQL%ROWCOUNT;
        UPDATE INSURANCE_POLICY_TAX_JURISD poltjd
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       stn.hopper_insurance_policy_tj hiptj
                  join stn.step_run                   sr    on to_number ( hiptj.process_id ) = sr.step_run_sid
                  join stn.step                       s     on sr.step_id                     = s.step_id
                  join stn.process                    p     on s.process_id                   = p.process_id
            where
                  p.process_name                 = 'insurance_policy-standardise'
              and to_number ( hiptj.message_id ) = poltjd.ROW_SID
              and poltjd.EVENT_STATUS            = 'V'
              and hiptj.event_status             = 'U'
       );
        p_no_fsriptj_processed_records := SQL%ROWCOUNT;
        UPDATE INSURANCE_POLICY pol
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                  stn.cession cs
            where
                  cs.policy_id    = pol.policy_id
              and cs.feed_uuid    = pol.feed_uuid
              and cs.event_status = 'P'
       );
        p_no_ip_processed_records := SQL%ROWCOUNT;
        UPDATE INSURANCE_POLICY_FX_RATE polfxr
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       fdr.fr_stan_raw_fx_rate fsrfr
                  join stn.step_run            sr    on to_number ( fsrfr.process_id ) = sr.step_run_sid
                  join stn.step                s     on sr.step_id                     = s.step_id
                  join stn.process             p     on s.process_id                   = p.process_id
            where
                  p.process_name                 = 'insurance_policy-standardise'
              and to_number ( fsrfr.message_id ) = polfxr.ROW_SID
              and polfxr.EVENT_STATUS            = 'V'
              and fsrfr.event_status             = 'U'
       );
        p_no_fsrfr_processed_records := SQL%ROWCOUNT;
        UPDATE CESSION_LINK cl
            SET
                EVENT_STATUS = 'P'
            WHERE
                    exists (
               select
                      null
                 from
                      stn.cession cs
                where
                      cs.stream_id    = cl.parent_stream_id
                  and cs.feed_uuid    = cl.feed_uuid
                  and cs.event_status = 'P'
           )
and exists (
               select
                      null
                 from
                      stn.cession cs
                where
                      cs.stream_id    = cl.child_stream_id
                  and cs.feed_uuid    = cl.feed_uuid
                  and cs.event_status = 'P'
           );
        p_no_cl_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_policy_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_updated_hpol_records NUMBER(38, 9) DEFAULT 0;
        v_no_updated_fsrfr_records NUMBER(38, 9) DEFAULT 0;
        v_no_updated_hpoltj_records NUMBER(38, 9) DEFAULT 0;
        v_no_validated_cession_records NUMBER(38, 9) DEFAULT 0;
        v_no_errored_cession_records NUMBER(38, 9) DEFAULT 0;
        v_no_validated_fx_records NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrip_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsriptj_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_pol_tj_updated NUMBER(38, 9) DEFAULT 0;
        v_total_no_frt_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_fsrfr_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_pol_fx_rate_deleted NUMBER(38, 9) DEFAULT 0;
        v_no_fsrip_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_fsriptj_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_fsrfr_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_ip_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_cl_processed_records NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        pr_policy_istat;
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify policy records' );
        pr_policy_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            stn.pk_cession_hier.pr_gen_cession_hierarchy;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed hopper records' );
            pr_policy_chr(p_step_run_sid, p_lpg_id, v_no_updated_hpol_records, v_no_updated_fsrfr_records, v_no_updated_hpoltj_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cancellation of unprocessed policy hopper records', 'v_no_updated_hpol_records', NULL, v_no_updated_hpol_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cancellation of unprocessed FX rate hopper records', 'v_no_updated_fsrfr_records', NULL, v_no_updated_fsrfr_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cancellation of unprocessed tax jurisdiction hopper records', 'v_no_updated_hpoltj_records', NULL, v_no_updated_hpoltj_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate policy records' );
            pr_policy_rval(p_step_run_sid);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set policy status = "V"' );
            pr_policy_svs(p_step_run_sid, v_no_validated_cession_records, v_no_errored_cession_records, v_no_validated_fx_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting the Validated status', 'v_no_validated_cession_records', NULL, v_no_validated_cession_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting the Validated status', 'v_no_errored_cession_records', NULL, v_no_errored_cession_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting the Validated status', 'v_no_validated_fx_records', NULL, v_no_validated_fx_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish policy records' );
            pr_policy_pub(p_step_run_sid, v_total_no_fsrip_published, v_total_no_fsriptj_published, v_total_no_pol_tj_updated, v_total_no_fsrfr_published, v_total_no_frt_published, v_total_no_pol_fx_rate_deleted);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing insurance policy hopper records', 'v_total_no_fsrip_published', NULL, v_total_no_fsrip_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing insurance policy tax jurisd records', 'v_total_no_fsriptj_published', NULL, v_total_no_fsriptj_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed updating inactive insurance policy tax jurisd records', 'v_total_no_pol_tj_updated', NULL, v_total_no_pol_tj_updated, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing fx rate type records', 'v_total_no_frt_published', NULL, v_total_no_frt_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed deleting prior insurance policy fx rate records', 'v_total_no_pol_fx_rate_deleted', NULL, v_total_no_pol_fx_rate_deleted, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing fx rate hopper records', 'v_total_no_fsrfr_published', NULL, v_total_no_fsrfr_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set legal entity status = "P"' );
            pr_policy_sps(v_no_fsrip_processed_records, v_no_fsriptj_processed_records, v_no_fsrfr_processed_records, v_no_ip_processed_records, v_no_cl_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_fsrip_processed_records', NULL, v_no_fsrip_processed_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_fsriptj_processed_records', NULL, v_no_fsriptj_processed_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_fsrfr_processed_records', NULL, v_no_fsrfr_processed_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_ip_processed_records', NULL, v_no_ip_processed_records, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_cl_processed_records', NULL, v_no_cl_processed_records, NULL);
            IF v_no_validated_cession_records <> v_total_no_fsrip_published THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_validated_cession_records != v_total_no_fsrip_published', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            IF v_no_validated_fx_records <> v_total_no_fsrfr_published THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_validated_fx_records != v_total_no_fsrfr_published', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 2' );
                raise pub_val_mismatch;
            END IF;
            IF v_total_no_fsrfr_published <> v_no_fsrfr_processed_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_total_no_fsrfr_published != v_no_fsrfr_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 3' );
                raise pub_val_mismatch;
            END IF;
            IF v_total_no_fsrip_published <> v_no_fsrip_processed_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_total_no_fsrip_published != v_no_fsrip_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 4' );
                raise pub_val_mismatch;
            END IF;
            IF v_total_no_fsriptj_published <> v_no_fsriptj_processed_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_total_no_fsriptj_published != v_no_fsriptj_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 5' );
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_total_no_fsrip_published;
            p_no_failed_records    := v_no_errored_cession_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_POL;
/