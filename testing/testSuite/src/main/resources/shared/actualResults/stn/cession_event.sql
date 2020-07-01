select
       feed_uuid
     , event_status
     , correlation_uuid
     , event_id
     , accounting_dt
     , stream_id
     , basis_cd
     , premium_typ
     , business_typ
     , event_typ
     , business_event_typ
     , trunc(source_event_ts)
     , transaction_ccy
     , transaction_amt
     , functional_ccy
     , functional_amt
     , reporting_ccy
     , reporting_amt
  from
       stn.cession_event