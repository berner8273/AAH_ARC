select
       le.feed_uuid
     , fsrie.srip_ipe_entity_report_name
     , fsrie.srip_ipe_pl_party_legal_code
     , fsrie.srip_ipe_entity_client_code
     , fipet.ipet_internal_proc_entity_code
     , fsrie.event_status
     , fsrie.lpg_id
     , fsrie.srip_internal_entity_id
     , fsrie.srip_ipe_cu_base_currency_id
  from
            fdr.fr_stan_raw_int_entity       fsrie
       join fdr.fr_internal_proc_entity_type fipet on fsrie.srip_ipe_entity_type_id  = fipet.ipet_internal_proc_ent_type_id
       join stn.legal_entity                 le    on to_number ( fsrie.message_id ) = le.row_sid