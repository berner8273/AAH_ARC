select
       policy_id
     , stream_id
     , le_id
     , cession_typ
     , gross_par_pct
     , net_par_pct
     , gross_premium_pct
     , ceding_commission_pct
     , net_premium_pct
     , start_dt
     , effective_dt
     , stop_dt
     , termination_dt
     , loss_pos
     , vie_status
     , vie_effective_dt
     , vie_acct_dt
     , accident_yr
     , underwriting_yr
     , feed_uuid
     , event_status
  from
       stn.cession