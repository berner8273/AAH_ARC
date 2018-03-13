create or replace view stn.cession_event_reversal_curr
as
with max_event as
( select
                          trunc( cevnid.accounting_dt , 'MONTH' )   accounting_dt
                        , cevnid.stream_id
                        , cevnid.basis_cd
                        , cevnid.premium_typ
                        , cevnid.event_typ
                        , cevnid.business_typ
                        , max(cevval.source_event_ts)               source_event_ts
                        , max(fd.loaded_ts)                         loaded_ts
                     from 
                               stn.cev_non_intercompany_data cevnid
                          join stn.cev_valid                 cevval    on cevnid.event_seq_id = cevval.event_id
                          join stn.feed                      fd        on cevval.feed_uuid    = fd.feed_uuid
                 group by
                          trunc( cevnid.accounting_dt , 'MONTH' ) --accounting_dt
                        , cevnid.stream_id                        --stream_id
                        , cevnid.basis_cd                         --basis_cd
                        , cevnid.premium_typ                      --premium_typ
                        , cevnid.event_typ                        --event_typ
                        , cevnid.business_typ                     --business_typ
        )                     
select distinct
       'REVERSE_REPOST'                  posting_type
     , cevnid.correlation_uuid
     , cevnid.event_seq_id
     , cevnid.row_sid||'.01'             row_sid
     , cevnid.sub_event
     , cevnid.accounting_dt
     , cevnid.policy_id
     , cevnid.policy_abbr_nm             journal_descr
     , cevnid.stream_id
     , cevnid.basis_cd
     , cevnid.business_typ
     , cevnid.premium_typ
     , cevnid.policy_premium_typ
     , cevnid.policy_accident_yr
     , cevnid.policy_underwriting_yr
     , cevnid.ultimate_parent_le_cd
     , cevnid.execution_typ
     , cevnid.policy_typ
     , cevnid.event_typ
     , cevnid.business_event_typ
     , cevnid.business_unit
     , cevnid.affiliate
     , cevnid.owner_le_cd
     , cevnid.counterparty_le_cd
     , cevnid.ledger_cd
     , cevnid.vie_cd
     , cevnid.is_mark_to_market
     , cevnid.tax_jurisdiction_cd
     , cevnid.transaction_ccy
     , cevnid.transaction_amt * -1       transaction_amt
     , cevnid.functional_ccy
     , cevnid.functional_amt * -1        functional_amt
     , cevnid.reporting_ccy
     , cevnid.reporting_amt * -1         reporting_amt
     , cevnid.lpg_id
     , null                              reversal_indicator
  from
       stn.cev_non_intercompany_data     cevnid
  join stn.cev_valid                     cevval    on cevnid.event_seq_id = cevval.event_id
  join stn.feed                          fd        on cevval.feed_uuid    = fd.feed_uuid
 where (
               trunc( cevnid.accounting_dt , 'MONTH' )
             , cevnid.stream_id
             , cevnid.basis_cd
             , cevnid.premium_typ
             , cevnid.event_typ
             , cevnid.business_typ
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