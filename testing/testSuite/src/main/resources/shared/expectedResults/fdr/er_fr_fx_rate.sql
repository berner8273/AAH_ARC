select
       fr_fxrate_date
     , fr_cu_currency_numer_id
     , fr_cu_currency_denom_id
     , fr_si_sys_inst_id
     , fr_fx_rate
     , fr_rty_rate_type_id
     , fr_pl_party_legal_id
     , fr_active
     , fr_fxrate_date_fwd
  from
       er_fr_fx_rate
