select
       rate_dt
     , from_ccy
     , to_ccy
     , rate_typ
     , rate
     , feed_uuid
     , event_status
  from
       stn.fx_rate
