CREATE OR REPLACE PACKAGE BODY stn.PK_FXR AS
    PROCEDURE pr_fx_rate_idf
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
                fxr.ROW_SID AS ROW_SID
            FROM
                FX_RATE fxr
                INNER JOIN FEED ON fxr.FEED_UUID = feed.FEED_UUID
            WHERE
                    fxr.EVENT_STATUS = 'U'
and fxr.LPG_ID       = p_lpg_id
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
        UPDATE FX_RATE fxr
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  fxr.row_sid = idr.row_sid
       );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated fx_rate.step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_fx_rate_chr
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_updated_hopper_records OUT NUMBER
        )
    AS
    BEGIN
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
                           stn.fx_rate           fxr
                      join stn.identified_record idr on fxr.row_sid = idr.row_sid
                where
                      fxr.rate_typ = fsrfr.srf_fr_rty_rate_type_id
                  and fxr.rate_dt  = fsrfr.srf_fr_fxrate_date
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
                  and p.process_name  = 'fx_rate-standardise'
           );
        p_no_updated_hopper_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_fx_rate_sval
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER
        )
    AS
        v_no_broken_feeds NUMBER(38, 9);
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                fd.EFFECTIVE_DT AS ERROR_VALUE,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                p_lpg_id AS LPG_ID,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                fd.FEED_SID AS ROW_IN_ERROR_KEY_ID,
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                p_step_run_sid AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                FEED fd
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'fxr-rate_dt'
and     exists (
                   select
                          null
                     from
                               stn.fx_rate           fxr
                          join stn.identified_record idr on fxr.row_sid = idr.row_sid
                    where
                          fxr.feed_uuid  = fd.FEED_UUID
                      and fxr.rate_dt   != fd.EFFECTIVE_DT
               )
and not exists (
                   select
                          null
                     from
                          stn.broken_feed bf
                    where
                          bf.feed_sid = fd.FEED_SID
               );
        v_no_broken_feeds := SQL%ROWCOUNT;
        IF v_no_broken_feeds > 0 THEN
            UPDATE FX_RATE fxr
                SET
                    EVENT_STATUS = 'X',
                    STEP_RUN_SID = p_step_run_sid
                WHERE
                            exists (
                   select
                          null
                     from
                               standardisation_log sl
                          join stn.feed            fd on sl.feed_sid = fd.feed_sid
                    where
                          fd.feed_uuid     = fxr.FEED_UUID
                      and sl.rule_identity = 'fxr-rate_dt'
               )
and not exists (
                   select
                          null
                     from
                               stn.broken_feed bf
                          join stn.feed        fd on bf.feed_sid = fd.feed_sid
                    where
                          fd.feed_uuid = fxr.FEED_UUID
               );
            INSERT INTO BROKEN_FEED
                (FEED_SID, STEP_RUN_SID)
                SELECT
                    fd.FEED_SID AS FEED_SID,
                    p_step_run_sid AS STEP_RUN_SID
                FROM
                    FEED fd
                WHERE
                            exists (
                   select
                          null
                     from
                          standardisation_log sl
                    where
                          sl.feed_sid      = fd.FEED_SID
                      and sl.rule_identity = 'fxr-rate_dt'
               )
and not exists (
                   select
                          null
                     from
                          stn.broken_feed bf
                    where
                          bf.feed_sid = fd.FEED_SID
               );
            DELETE FROM
                IDENTIFIED_RECORD idr
            WHERE
                exists (
           select
                  null
             from
                       stn.fx_rate     fxr
                  join stn.feed        fd  on fxr.feed_uuid = fd.feed_uuid
                  join stn.broken_feed bf  on fd.feed_sid   = bf.feed_sid
            where
                  fxr.row_sid = idr.ROW_SID
       );
        END IF;
    END;
    
    PROCEDURE pr_fx_rate_rval
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                fxr.TO_CCY AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                fxr.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                fxr.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                fxr.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                FX_RATE fxr
                INNER JOIN IDENTIFIED_RECORD idr ON fxr.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON fxr.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON fxr.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN FXR_DEFAULT fxrd ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'fxr-from_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = fxr.FROM_CCY
                      and fcl.cul_sil_sys_inst_clicode = fxrd.SYSTEM_INSTANCE
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                fxr.TO_CCY AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                fxr.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                fxr.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                fxr.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                FX_RATE fxr
                INNER JOIN IDENTIFIED_RECORD idr ON fxr.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON fxr.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON fxr.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN FXR_DEFAULT fxrd ON 1 = 1
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'fxr-to_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = fxr.TO_CCY
                      and fcl.cul_sil_sys_inst_clicode = fxrd.SYSTEM_INSTANCE
               );
    END;
    
    PROCEDURE pr_fx_rate_svs
        (
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE FX_RATE fxr
            SET
                EVENT_STATUS = 'E'
            WHERE
                exists (
           select
                  null
             from
                  stn.standardisation_log sl
            where
                  sl.row_in_error_key_id = fxr.ROW_SID
       );
        UPDATE FX_RATE fxr
            SET
                EVENT_STATUS = 'V'
            WHERE
                    not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = fxr.ROW_SID
               )
and     exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          fxr.ROW_SID = idr.row_sid
               );
        p_no_validated_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_fx_rate_pub
        (
            p_step_run_sid IN NUMBER,
            p_total_no_published OUT NUMBER,
            p_total_no_1_1_published OUT NUMBER,
            p_total_no_inverse_published OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO fdr.FR_STAN_RAW_FX_RATE
            (SRF_FR_FXRATE_DATE, SRF_FR_FXRATE_DATE_FWD, SRF_FR_CU_CURRENCY_NUMER_CODE, SRF_FR_CU_CURRENCY_DENOM_CODE, LPG_ID, SRF_FR_RTY_RATE_TYPE_ID, MESSAGE_ID, SRF_FR_SI_SYS_INST_CODE, SRF_FR_PL_PARTY_LEGAL_CODE, SRF_FR_FX_RATE, PROCESS_ID)
            SELECT
                fxr.RATE_DT AS SRF_FR_FXRATE_DATE,
                fxr.RATE_DT AS SRF_FR_FXRATE_DATE_FWD,
                fxr.FROM_CCY AS SRF_FR_CU_CURRENCY_NUMER_CODE,
                fxr.TO_CCY AS SRF_FR_CU_CURRENCY_DENOM_CODE,
                fxr.LPG_ID AS LPG_ID,
                fxr.RATE_TYP AS SRF_FR_RTY_RATE_TYPE_ID,
                TO_CHAR(fxr.ROW_SID) AS MESSAGE_ID,
                fxrd.SYSTEM_INSTANCE AS SRF_FR_SI_SYS_INST_CODE,
                fxrd.PARTY_LEGAL AS SRF_FR_PL_PARTY_LEGAL_CODE,
                fxr.RATE AS SRF_FR_FX_RATE,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID
            FROM
                FX_RATE fxr
                INNER JOIN IDENTIFIED_RECORD idr ON fxr.ROW_SID = idr.ROW_SID
                INNER JOIN FXR_DEFAULT fxrd ON 1 = 1
            WHERE
                fxr.EVENT_STATUS = 'V';
        p_total_no_published := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Published FX rates supplied to AAH', 'p_total_no_published', NULL, p_total_no_published, NULL);
        INSERT INTO fdr.FR_STAN_RAW_FX_RATE
            (SRF_FR_FXRATE_DATE, SRF_FR_FXRATE_DATE_FWD, SRF_FR_CU_CURRENCY_NUMER_CODE, SRF_FR_CU_CURRENCY_DENOM_CODE, LPG_ID, SRF_FR_RTY_RATE_TYPE_ID, SRF_FR_SI_SYS_INST_CODE, SRF_FR_PL_PARTY_LEGAL_CODE, SRF_FR_FX_RATE, PROCESS_ID)
            SELECT
                fxr.RATE_DT AS SRF_FR_FXRATE_DATE,
                fxr.RATE_DT AS SRF_FR_FXRATE_DATE_FWD,
                fxr.TO_CCY AS SRF_FR_CU_CURRENCY_NUMER_CODE,
                fxr.FROM_CCY AS SRF_FR_CU_CURRENCY_DENOM_CODE,
                fxr.LPG_ID AS LPG_ID,
                fxr.RATE_TYP AS SRF_FR_RTY_RATE_TYPE_ID,
                fxrd.SYSTEM_INSTANCE AS SRF_FR_SI_SYS_INST_CODE,
                fxrd.PARTY_LEGAL AS SRF_FR_PL_PARTY_LEGAL_CODE,
                1 / fxr.RATE AS SRF_FR_FX_RATE,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID
            FROM
                FX_RATE fxr
                INNER JOIN IDENTIFIED_RECORD idr ON fxr.ROW_SID = idr.ROW_SID
                INNER JOIN FXR_DEFAULT fxrd ON 1 = 1
            WHERE
                    fxr.EVENT_STATUS = 'V'
and not exists (
                   select 
                          null
                     from
                          stn.fx_rate fxr_il
                    where
                          fxr_il.feed_uuid = fxr.FEED_UUID
                      and fxr_il.rate_dt   = fxr.RATE_DT
                      and fxr_il.from_ccy  = fxr.TO_CCY
                      and fxr_il.to_ccy    = fxr.FROM_CCY
                      and fxr_il.rate_typ  = fxr.RATE_TYP
               );
        p_total_no_inverse_published := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Created and published inverse FX rates', 'p_total_no_inverse_published', NULL, p_total_no_inverse_published, NULL);
        insert
          into
               fdr.fr_stan_raw_fx_rate
             (
                 srf_fr_fxrate_date
             ,   srf_fr_fxrate_date_fwd
             ,   srf_fr_cu_currency_numer_code
             ,   srf_fr_cu_currency_denom_code
             ,   lpg_id
             ,   srf_fr_rty_rate_type_id
             ,   srf_fr_si_sys_inst_code
             ,   srf_fr_pl_party_legal_code
             ,   srf_fr_fx_rate
             ,   process_id
             )
        select
                 fx_dt_set.rate_dt            srf_fr_fxrate_date
             ,   fx_dt_set.rate_dt            srf_fr_fxrate_date_fwd
             ,   fcl.cul_currency_lookup_code srf_fr_cu_currency_numer_code
             ,   fcl.cul_currency_lookup_code srf_fr_cu_currency_denom_code
             ,   1                            lpg_id
             ,   frt.rty_rate_type_id         srf_fr_rty_rate_type_id
             ,   fxrd.system_instance         srf_fr_si_sys_inst_code
             ,   fxrd.party_legal             srf_fr_pl_party_legal_code
             ,   1                            srf_fr_fx_rate
             ,   TO_CHAR ( p_step_run_sid )   process_id
          from (
                             select
                                    fx_dt.effective_dt + rownum - 1 rate_dt
                               from (
                                        select
                                               min ( fd.effective_dt ) effective_dt
                                          from
                                               stn.feed fd
                                         where
                                               exists (
                                                          select
                                                                 null
                                                            from
                                                                      stn.fx_rate           fxr
                                                                 join stn.identified_record idr on fxr.row_sid = idr.row_sid
                                                           where
                                                                 fxr.feed_uuid = fd.feed_uuid
                                                      )
                                    ) fx_dt
                   connect by level <= ( select no_1_1_days from fxr_default )
               )
                                                 fx_dt_set
               cross join fdr.fr_currency_lookup fcl
               cross join fdr.fr_rate_type       frt
               cross join stn.fxr_default        fxrd
         where
               fx_dt_set.rate_dt is not null
           and fcl.cul_currency_lookup_code not in ( 'NUL' )
           and frt.rty_rate_type_id in ( 'SPOT' , 'MAVG' )
           and not exists (
                              select
                                     null
                                from
                                     fdr.fr_fx_rate ffxr
                               where
                                     ffxr.fr_fxrate_date          = fx_dt_set.rate_dt
                                 and ffxr.fr_cu_currency_numer_id = fcl.cul_currency_lookup_code
                                 and ffxr.fr_cu_currency_denom_id = fcl.cul_currency_lookup_code
                          )
           and not exists (
                              select
                                     null
                                from
                                          fdr.fr_stan_raw_fx_rate fsrfr
                                     join stn.step_run            sr    on to_number ( fsrfr.process_id ) = sr.step_run_sid
                                     join stn.step                s     on sr.step_id                     = s.step_id
                                     join stn.process             p     on s.process_id                   = p.process_id
                               where
                                     fsrfr.event_status                  = 'P'
                                 and fsrfr.srf_fr_fxrate_date            = fx_dt_set.rate_dt
                                 and fsrfr.srf_fr_cu_currency_numer_code = fcl.cul_currency_lookup_code
                                 and fsrfr.srf_fr_cu_currency_numer_code = fsrfr.srf_fr_cu_currency_denom_code
                                 and p.process_name                      = 'fx_rate-standardise'
                          );
        p_total_no_1_1_published := sql%rowcount;
        p_total_no_published     := p_total_no_published + p_total_no_1_1_published + p_total_no_inverse_published;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Created and published 1:1 FX rates', 'p_total_no_1_1_published', NULL, p_total_no_1_1_published, NULL);
    END;
    
    PROCEDURE pr_fx_rate_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE FX_RATE fxr
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                       fdr.fr_stan_raw_fx_rate fsrfr
                  join stn.identified_record   idr   on to_number ( fsrfr.message_id ) = idr.row_sid
                  join stn.step_run            sr    on to_number ( fsrfr.process_id ) = sr.step_run_sid
                  join stn.step                s     on sr.step_id                     = s.step_id
                  join stn.process             p     on s.process_id                   = p.process_id
            where
                  idr.row_sid    = fxr.ROW_SID
              and p.process_name = 'fx_rate-standardise'
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_fx_rate_prc
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
        v_total_no_1_1_published NUMBER(38, 9) DEFAULT 0;
        v_total_no_inverse_published NUMBER(38, 9) DEFAULT 0;
        v_no_updated_hopper_records NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify FX rate records' );
        pr_fx_rate_idf(p_step_run_sid, p_lpg_id, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed hopper records' );
            pr_fx_rate_chr(p_step_run_sid, p_lpg_id, v_no_updated_hopper_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cancellation of unprocessed hopper records', 'v_no_updated_hopper_records', NULL, v_no_updated_hopper_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set level validate FX Rate records' );
            pr_fx_rate_sval(p_step_run_sid, p_lpg_id);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed set level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate FX Rate records' );
            pr_fx_rate_rval;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set FX rate status = "V"' );
            pr_fx_rate_svs(v_no_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status', 'v_no_validated_records', NULL, v_no_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish FX rate records' );
            pr_fx_rate_pub(p_step_run_sid, v_total_no_published, v_total_no_1_1_published, v_total_no_inverse_published);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing records', 'v_total_no_published', NULL, v_total_no_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing records', 'v_total_no_1_1_published', NULL, v_total_no_1_1_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing records', 'v_total_no_inverse_published', NULL, v_total_no_inverse_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish FX rate log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set FX rate status = "P"' );
            pr_fx_rate_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_processed_records', NULL, v_no_processed_records, NULL);
            IF v_no_processed_records <> v_no_validated_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_processed_records <> v_no_validated_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            IF v_no_processed_records <> (v_total_no_published - v_total_no_1_1_published - v_total_no_inverse_published) THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_processed_records != ( v_total_no_published - v_total_no_1_1_published - v_total_no_inverse_published )', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 2' );
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := v_no_identified_records - v_no_processed_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_FXR;
/