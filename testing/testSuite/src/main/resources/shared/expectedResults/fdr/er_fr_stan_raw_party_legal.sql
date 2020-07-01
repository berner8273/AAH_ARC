select
       feed_uuid
     , pt_party_type_name
     , srl_pl_full_legal_name
     , srl_pl_party_legal_clicode
     , srl_pl_int_ext_flag
     , srl_pl_client_text2         no_grace_days
     , srl_pl_client_text3         slr_lpg_id
     , srl_pl_client_text4         epg_id
     , srl_pl_client_text5         is_interco_elim_entity
     , srl_pl_client_text6         is_vie_consol_entity
     , srl_one
     , event_status
     , srl_pl_active
     , srl_pl_global_id
     , srl_pl_cu_base_currency_code
     , srl_pl_cu_local_currency_id
     , lpg_id
  from
       er_fr_stan_raw_party_legal