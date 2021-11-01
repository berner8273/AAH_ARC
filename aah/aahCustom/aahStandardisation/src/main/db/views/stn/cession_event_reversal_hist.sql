/* Formatted on 10/8/2019 3:59:25 PM (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW STN.CESSION_EVENT_REVERSAL_HIST
(
   POSTING_TYPE,
   CORRELATION_UUID,
   EVENT_SEQ_ID,
   ROW_SID,
   SUB_EVENT,
   ACCOUNTING_DT,
   POLICY_ID,
   JOURNAL_DESCR,
   STREAM_ID,
   BASIS_CD,
   BUSINESS_TYP,
   PREMIUM_TYP,
   POLICY_PREMIUM_TYP,
   POLICY_ACCIDENT_YR,
   POLICY_UNDERWRITING_YR,
   ULTIMATE_PARENT_LE_CD,
   EXECUTION_TYP,
   POLICY_TYP,
   EVENT_TYP,
   BUSINESS_EVENT_TYP,
   BUSINESS_UNIT,
   AFFILIATE,
   OWNER_LE_CD,
   COUNTERPARTY_LE_CD,
   LEDGER_CD,
   VIE_CD,
   IS_MARK_TO_MARKET,
   TAX_JURISDICTION_CD,
   CHARTFIELD_CD,
   TRANSACTION_CCY,
   TRANSACTION_AMT,
   FUNCTIONAL_CCY,
   FUNCTIONAL_AMT,
   REPORTING_CCY,
   REPORTING_AMT,
   LPG_ID,
   REVERSAL_INDICATOR,
   ORIGINAL_POSTING_DT,
   BU_LOOKUP,
   VIE_BU_LOOKUP,
   ACCOUNT_CD
)
   BEQUEATH DEFINER
AS
   SELECT /*+ PARALLEL (4) */ DISTINCT 'REVERSE_REPOST' posting_type,
                   fsrae.srae_client_spare_id14 correlation_uuid,
                   fsrae.srae_client_spare_id12 event_seq_id,
                   fsrae.srae_acc_event_id || '.01' row_sid,
                   fsrae.srae_sub_event_id sub_event,
                   MAX (cep.accounting_dt) OVER () AS accounting_dt,
                   fsrae.srae_dimension_7 policy_id,
                   fsrae.srae_dimension_15 journal_descr,
                   fsrae.srae_dimension_8 stream_id,
                   fsrae.srae_client_spare_id15 basis_cd,
                   fsrae.srae_dimension_12 business_typ,
                   fsrae.srae_dimension_14 premium_typ,
                   'NVS' policy_premium_typ,
                   fsrae.srae_dimension_5 policy_accident_yr,
                   fsrae.srae_dimension_6 policy_underwriting_yr,
                   fsrae.srae_client_spare_id3 ultimate_parent_le_cd,
                   fsrae.srae_dimension_11 execution_typ,
                   fsrae.srae_client_spare_id13 policy_typ,
                   fsrae.srae_acc_event_type event_typ,
                   fsrae.srae_client_spare_id11 business_event_typ,
                   fsrae.srae_gl_entity business_unit,
                   fsrae.srae_dimension_4 affiliate,
                   fsrae.srae_dimension_13 owner_le_cd,
                   fsrae.srae_dimension_3 counterparty_le_cd,
                   fsrae.srae_dimension_10 ledger_cd,
                   fsrae.srae_client_spare_id10 vie_cd,
                   fsrae.srae_client_spare_id9 is_mark_to_market,
                   fsrae.srae_dimension_9 tax_jurisdiction_cd,
                   fsrae.srae_dimension_1 chartfield_cd,
                   fsrae.srae_iso_currency_code transaction_ccy,
                   fsrae.srae_client_amount1 * -1 transaction_amt,
                   fsrae.srae_client_spare_id5 functional_ccy,
                   fsrae.srae_client_spare_id6 * -1 functional_amt,
                   fsrae.srae_client_spare_id7 reporting_ccy,
                   fsrae.srae_client_spare_id8 * -1 reporting_amt,
                   fsrae.lpg_id lpg_id,
                   fsrae.srae_client_spare_id16 reversal_indicator,
                   fsrae.srae_posting_date original_posting_dt,
                   fsrae.srae_client_spare_id17 bu_lookup,
                   fsrae.srae_client_spare_id18 vie_bu_lookup,
                   fsrae.srae_client_spare_id2 account_cd
     FROM fdr.fr_stan_raw_acc_event fsrae
          INNER JOIN slr.slr_jrnl_lines sjl
             ON fsrae.srae_acc_event_id = sjl.jl_source_jrnl_id
          INNER JOIN stn.cession_event_posting cep
             ON     fsrae.srae_acc_event_type = cep.event_typ
                AND fsrae.srae_dimension_8 = cep.stream_id
    WHERE     NVL (
                 CASE
                    WHEN fsrae.srae_dimension_14 = 'M' THEN 'I'
                    ELSE fsrae.srae_dimension_14
                 END,
                 'NVS') =
                 NVL (
                    CASE
                       WHEN cep.premium_typ = 'M' THEN 'I'
                       ELSE cep.premium_typ
                    END,
                    'NVS')
          AND TRUNC (fsrae.srae_accevent_date, 'MONTH') =
                 TRUNC (cep.accounting_dt, 'MONTH')
          AND fsrae.srae_client_spare_id16 <> 'VIE_HISTORICAL'
          AND fsrae.event_status = 'P'
          AND fsrae.srae_acc_event_typ not in (select event_typ from stn.event_hierarchy_reference where event_class = 'CASH_TXN')
          AND fsrae.srae_client_spare_id14 NOT IN ( SELECT DISTINCT faei2.srae_client_spare_id14
                                                     FROM fdr.fr_stan_raw_acc_event faei2                                                         
                                                    WHERE faei2.srae_client_spare_id16 =
                                                             'REVERSE_REPOST' );
