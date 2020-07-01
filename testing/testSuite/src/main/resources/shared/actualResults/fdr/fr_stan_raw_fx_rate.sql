(
   select
          fx.feed_uuid
        , fsrfr.srf_fr_fxrate_date
        , fsrfr.srf_fr_cu_currency_numer_code
        , fsrfr.srf_fr_fxrate_date_fwd
        , fsrfr.srf_fr_cu_currency_denom_code
        , fsrfr.srf_fr_si_sys_inst_code
        , fsrfr.srf_fr_fx_rate
        , fsrfr.srf_fr_pl_party_legal_code
        , fsrfr.srf_one
        , fsrfr.srf_fr_rty_rate_type_id
        , fsrfr.event_status
        , fsrfr.lpg_id
     from
               fdr.fr_stan_raw_fx_rate fsrfr
     left join stn.fx_rate             fx    on to_number ( fsrfr.message_id ) = fx.row_sid
    where fsrfr.SRF_FR_RTY_RATE_TYPE_ID not like '/POL/%'
union all
   select
          ipfxr.feed_uuid
        , fsrfr.srf_fr_fxrate_date
        , fsrfr.srf_fr_cu_currency_numer_code
        , fsrfr.srf_fr_fxrate_date_fwd
        , fsrfr.srf_fr_cu_currency_denom_code
        , fsrfr.srf_fr_si_sys_inst_code
        , fsrfr.srf_fr_fx_rate
        , fsrfr.srf_fr_pl_party_legal_code
        , fsrfr.srf_one
        , fsrfr.srf_fr_rty_rate_type_id
        , fsrfr.event_status
        , fsrfr.lpg_id
     from
               fdr.fr_stan_raw_fx_rate      fsrfr
          join stn.insurance_policy_fx_rate ipfxr on to_number ( fsrfr.message_id ) = ipfxr.row_sid
    where fsrfr.SRF_FR_RTY_RATE_TYPE_ID like '/POL/%'
)