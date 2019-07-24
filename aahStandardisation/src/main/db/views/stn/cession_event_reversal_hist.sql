
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STN"."CESSION_EVENT_REVERSAL_HIST" ("POSTING_TYPE", "CORRELATION_UUID", "EVENT_SEQ_ID", "ROW_SID", "SUB_EVENT", "ACCOUNTING_DT", "POLICY_ID", "JOURNAL_DESCR", "STREAM_ID", "BASIS_CD", "BUSINESS_TYP", "PREMIUM_TYP", "POLICY_PREMIUM_TYP", "POLICY_ACCIDENT_YR", "POLICY_UNDERWRITING_YR", "ULTIMATE_PARENT_LE_CD", "EXECUTION_TYP", "POLICY_TYP", "EVENT_TYP", "BUSINESS_EVENT_TYP", "BUSINESS_UNIT", "AFFILIATE", "OWNER_LE_CD", "COUNTERPARTY_LE_CD", "LEDGER_CD", "VIE_CD", "IS_MARK_TO_MARKET", "TAX_JURISDICTION_CD", "CHARTFIELD_CD", "TRANSACTION_CCY", "TRANSACTION_AMT", "FUNCTIONAL_CCY", "FUNCTIONAL_AMT", "REPORTING_CCY", "REPORTING_AMT", "LPG_ID", "REVERSAL_INDICATOR", "ORIGINAL_POSTING_DT", "BU_LOOKUP", "VIE_BU_LOOKUP") AS 
  select distinct
       'REVERSE_REPOST'                  posting_type
     , fsrae.srae_client_spare_id14      correlation_uuid
     , fsrae.srae_client_spare_id12      event_seq_id
     , fsrae.srae_acc_event_id||'.01'    row_sid
     , fsrae.srae_sub_event_id           sub_event
     , (
        select distinct max(cep.accounting_dt)
          from stn.cession_event_posting        cep
         where fsrae.srae_acc_event_type                   = cep.event_typ
           and fsrae.srae_dimension_8                      = cep.stream_id
           and nvl(case when fsrae.srae_dimension_14 = 'M' then 'I' else fsrae.srae_dimension_14 end, 'NVS') = nvl(case when cep.premium_typ = 'M' then 'I' else cep.premium_typ end,'NVS')
           and trunc( fsrae.srae_accevent_date , 'MONTH' ) = trunc( cep.accounting_dt , 'MONTH' )
        )                                accounting_dt
     , fsrae.srae_dimension_7            policy_id
     , fsrae.srae_dimension_15           journal_descr
     , fsrae.srae_dimension_8            stream_id
     , fsrae.srae_client_spare_id15      basis_cd
     , fsrae.srae_dimension_12           business_typ
     , fsrae.srae_dimension_14           premium_typ
     , 'NVS'                             policy_premium_typ
     , fsrae.srae_dimension_5            policy_accident_yr
     , fsrae.srae_dimension_6            policy_underwriting_yr
     , fsrae.srae_client_spare_id3       ultimate_parent_le_cd
     , fsrae.srae_dimension_11           execution_typ
     , fsrae.srae_client_spare_id13      policy_typ
     , fsrae.srae_acc_event_type         event_typ
     , fsrae.srae_client_spare_id11      business_event_typ
     , fsrae.srae_gl_entity              business_unit
     , fsrae.srae_dimension_4            affiliate
     , fsrae.srae_dimension_13           owner_le_cd
     , fsrae.srae_dimension_3            counterparty_le_cd
     , fsrae.srae_dimension_10           ledger_cd
     , fsrae.srae_client_spare_id10      vie_cd
     , fsrae.srae_client_spare_id9       is_mark_to_market
     , fsrae.srae_dimension_9            tax_jurisdiction_cd
     , fsrae.srae_dimension_1            chartfield_cd
     , fsrae.srae_iso_currency_code      transaction_ccy
     , fsrae.srae_client_amount1 * -1    transaction_amt
     , fsrae.srae_client_spare_id5       functional_ccy
     , fsrae.srae_client_spare_id6 * -1  functional_amt
     , fsrae.srae_client_spare_id7       reporting_ccy
     , fsrae.srae_client_spare_id8 * -1  reporting_amt
     , fsrae.lpg_id                      lpg_id
     , fsrae.srae_client_spare_id16      reversal_indicator
     , fsrae.srae_posting_date           original_posting_dt
     , fsrae.srae_client_spare_id17      bu_lookup
     , fsrae.srae_client_spare_id18      vie_bu_lookup
  from
       fdr.fr_stan_raw_acc_event fsrae
 where exists (
                select null
                  from stn.cession_event_posting    cep2
                 where fsrae.srae_acc_event_type                   = cep2.event_typ
                   and fsrae.srae_dimension_8                      = cep2.stream_id
                   and nvl(case when fsrae.srae_dimension_14 = 'M' then 'I' else fsrae.srae_dimension_14 end, 'NVS') = nvl(case when cep2.premium_typ = 'M' then 'I' else cep2.premium_typ end,'NVS')
                   and trunc( fsrae.srae_accevent_date , 'MONTH' ) = trunc( cep2.accounting_dt , 'MONTH' )
              )
   and fsrae.srae_client_spare_id14 not in ( select faei2.ae_client_spare_id14
                                               from fdr.fr_accounting_event_imp faei2
                                               join slr.slr_jrnl_lines          sjl2
                                                 on faei2.ae_acc_event_id      = sjl2.jl_source_jrnl_id
                                              where faei2.ae_client_spare_id16 = 'REVERSE_REPOST'
                                           )
   and fsrae.srae_client_spare_id16 <> 'VIE_HISTORICAL'
   and fsrae.event_status = 'P'
   and exists (
                select null
                  from fdr.fr_accounting_event_imp faei
                 where fsrae.srae_acc_event_id = faei.ae_acc_event_id
              )
   and exists (
                select null
                  from slr.slr_jrnl_lines sjl
                 where fsrae.srae_acc_event_id = sjl.jl_source_jrnl_id
              );