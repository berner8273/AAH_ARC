select
       le.feed_uuid
     , fpt.pt_party_type_name
     , fsrpl.srl_pl_full_legal_name
     , fsrpl.srl_pl_party_legal_clicode
     , fsrpl.srl_pl_int_ext_flag
     , fsrpl.srl_pl_client_text2         no_grace_days
     , fsrpl.srl_pl_client_text3         slr_lpg_id
     , fsrpl.srl_pl_client_text4         epg_id
     , fsrpl.srl_pl_client_text5         is_interco_elim_entity
     , fsrpl.srl_pl_client_text6         is_vie_consol_entity
     , fsrpl.srl_one
     , fsrpl.event_status
     , fsrpl.srl_pl_active
     , fsrpl.srl_pl_global_id
     , fsrpl.srl_pl_cu_base_currency_code
     , fsrpl.srl_pl_cu_local_currency_id
     , fsrpl.lpg_id
  from
            fdr.fr_stan_raw_party_legal fsrpl
       join stn.legal_entity            le    on to_number ( fsrpl.message_id ) = le.row_sid
       join fdr.fr_party_type           fpt   on fsrpl.srl_pl_pt_party_type_code = fpt.pt_party_type_id