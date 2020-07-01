select
       feed_uuid
     , srf_fr_fxrate_date
     , srf_fr_cu_currency_numer_code
     , srf_fr_fxrate_date_fwd
     , srf_fr_cu_currency_denom_code
     , srf_fr_si_sys_inst_code
     , srf_fr_fx_rate
     , srf_fr_pl_party_legal_code
     , srf_one
     , srf_fr_rty_rate_type_id
     , event_status
     , lpg_id
  from
       er_fr_stan_raw_fx_rate