create or replace view stn.cession_event_reversal_curr
as
with max_event as
( select
                          trunc( cep.accounting_dt , 'MONTH' )   accounting_dt
                        , cep.stream_id
                        , cep.basis_cd
                        , cep.premium_typ
                        , cep.event_typ
                        , cep.business_typ
                        , max(cevval.source_event_ts)               source_event_ts
                        , max(fd.loaded_ts)                         loaded_ts
                     from 
                               stn.cession_event_posting     cep
                          join stn.cev_valid                 cevval    on cep.event_seq_id = cevval.event_id
                          join stn.feed                      fd        on cevval.feed_uuid = fd.feed_uuid
                 group by
                          trunc( cep.accounting_dt , 'MONTH' ) --accounting_dt
                        , cep.stream_id                        --stream_id
                        , cep.basis_cd                         --basis_cd
                        , cep.premium_typ                      --premium_typ
                        , cep.event_typ                        --event_typ
                        , cep.business_typ                     --business_typ
        )                     
select distinct
       'REVERSE_REPOST'               posting_type
     , cep.correlation_uuid
     , cep.event_seq_id
     , cep.row_sid||'.01'             row_sid
     , cep.sub_event
     , cep.accounting_dt
     , cep.policy_id
     , cep.policy_abbr_nm             journal_descr
     , cep.stream_id
     , cep.basis_cd
     , cep.business_typ
     , cep.premium_typ
     , cep.policy_premium_typ
     , cep.policy_accident_yr
     , cep.policy_underwriting_yr
     , cep.ultimate_parent_le_cd
     , cep.execution_typ
     , cep.policy_typ
     , cep.event_typ
     , cep.business_event_typ
     , cep.business_unit
     , cep.affiliate
     , cep.owner_le_cd
     , cep.counterparty_le_cd
     , cep.ledger_cd
     , cep.vie_cd
     , cep.is_mark_to_market
     , cep.tax_jurisdiction_cd
     , cep.chartfield_cd
     , cep.transaction_ccy
     , cep.transaction_amt * -1       transaction_amt
     , cep.functional_ccy
     , cep.functional_amt * -1        functional_amt
     , cep.reporting_ccy
     , cep.reporting_amt * -1         reporting_amt
     , cep.lpg_id
     , null                           reversal_indicator
  from
       stn.cession_event_posting         cep
  join stn.cev_valid                     cevval    on cep.event_seq_id = cevval.event_id
  join stn.feed                          fd        on cevval.feed_uuid = fd.feed_uuid
 where (
               trunc( cep.accounting_dt , 'MONTH' )
             , cep.stream_id
             , cep.basis_cd
             , cep.premium_typ
             , cep.event_typ
             , cep.business_typ
             , cevval.source_event_ts
             , fd.loaded_ts
               )
                not in
                 (
                   select
                          accounting_dt
                        , stream_id
                        , basis_cd
                        , premium_typ
                        , event_typ
                        , business_typ
                        , source_event_ts
                        , loaded_ts
                     from 
                               max_event
                 )
        and cevval.event_status = 'V'
;