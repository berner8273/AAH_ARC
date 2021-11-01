create or replace view stn.cession_event_reversal_curr
as
with max_event as
          ( select
                   correlation_uuid
                 , event_seq_id
            from ( select
                          cep.correlation_uuid
                        , cep.event_seq_id
                        , rank() over (partition by trunc( cep.accounting_dt , 'MONTH' )
                                                  , cep.stream_id
                                                  , cep.basis_cd
                                                  , cep.premium_typ
                                                  , cep.event_typ
                                                  , cep.business_typ
                                           order by fd.loaded_ts desc
                                                  , cevval.source_event_ts ) max_rank
                     from
                               stn.cession_event_posting     cep
                          join stn.cev_valid                 cevval    on cep.event_seq_id     = cevval.event_id
                                                                      and cep.correlation_uuid = cevval.correlation_uuid
                          join stn.feed                      fd        on cevval.feed_uuid     = fd.feed_uuid
                 )
           where
                 max_rank = 1
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
     , cep.bu_lookup
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
     , cep.account_cd                 account_cd
  from
       stn.cession_event_posting     cep
  join stn.cev_valid                 cevval    on cep.event_seq_id     = cevval.event_id
                                              and cep.correlation_uuid = cevval.correlation_uuid
 where ( cep.correlation_uuid
       , cep.event_seq_id )
         not in
                 (
                   select
                          correlation_uuid
                        , event_seq_id
                     from
                          max_event
                 )
   and cevval.event_status = 'V'
   and cep.event_typ not in (select event_typ from stn.event_hierarchy_reference where event_class = 'CASH_TXN')
;