DROP VIEW STN.CESSION_EVENT_REVERSAL_CURR;

/* Formatted on 10/02/2024 1:57:07 PM (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW STN.CESSION_EVENT_REVERSAL_CURR
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
   BU_LOOKUP,
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
   JL_DESCRIPTION,
   ACCOUNT_CD
)
   BEQUEATH DEFINER
AS
   WITH max_event
        AS (SELECT correlation_uuid, event_seq_id
              FROM (SELECT cep.correlation_uuid,
                           cep.event_seq_id,
                           RANK ()
                           OVER (
                              PARTITION BY TRUNC (cep.accounting_dt, 'MONTH'),
                                           cep.stream_id,
                                           cep.basis_cd,
                                           cep.premium_typ,
                                           cep.event_typ,
                                           cep.business_typ
                              ORDER BY
                                 fd.loaded_ts DESC, cevval.source_event_ts)
                              max_rank
                      FROM stn.cession_event_posting cep
                           JOIN stn.cev_valid cevval
                              ON     cep.event_seq_id = cevval.event_id
                                 AND cep.correlation_uuid =
                                        cevval.correlation_uuid
                           JOIN stn.feed fd
                              ON cevval.feed_uuid = fd.feed_uuid)
             WHERE max_rank = 1)
   SELECT DISTINCT 'REVERSE_REPOST' posting_type,
                   cep.correlation_uuid,
                   cep.event_seq_id,
                   cep.row_sid || '.01' row_sid,
                   cep.sub_event,
                   cep.accounting_dt,
                   cep.policy_id,
                   cep.policy_abbr_nm journal_descr,
                   cep.stream_id,
                   cep.basis_cd,
                   cep.business_typ,
                   cep.premium_typ,
                   cep.policy_premium_typ,
                   cep.policy_accident_yr,
                   cep.policy_underwriting_yr,
                   cep.ultimate_parent_le_cd,
                   cep.execution_typ,
                   cep.policy_typ,
                   cep.event_typ,
                   cep.business_event_typ,
                   cep.business_unit,
                   cep.bu_lookup,
                   cep.affiliate,
                   cep.owner_le_cd,
                   cep.counterparty_le_cd,
                   cep.ledger_cd,
                   cep.vie_cd,
                   cep.is_mark_to_market,
                   cep.tax_jurisdiction_cd,
                   cep.chartfield_cd,
                   cep.transaction_ccy,
                   cep.transaction_amt * -1 transaction_amt,
                   cep.functional_ccy,
                   cep.functional_amt * -1 functional_amt,
                   cep.reporting_ccy,
                   cep.reporting_amt * -1 reporting_amt,
                   cep.lpg_id,
                   NULL reversal_indicator,
                   cep.jl_description,
                   cep.account_cd account_cd
     FROM stn.cession_event_posting cep
          JOIN stn.cev_valid cevval
             ON     cep.event_seq_id = cevval.event_id
                AND cep.correlation_uuid = cevval.correlation_uuid
    WHERE     (cep.correlation_uuid, cep.event_seq_id) NOT IN (SELECT correlation_uuid,
                                                                      event_seq_id
                                                                 FROM max_event)
          AND cevval.event_status = 'V'
          AND cep.event_typ NOT IN (SELECT event_typ
                                      FROM stn.event_hierarchy_reference
                                     WHERE event_class = 'CASH_TXN');


GRANT SELECT ON STN.CESSION_EVENT_REVERSAL_CURR TO AAH_READ_ONLY;
