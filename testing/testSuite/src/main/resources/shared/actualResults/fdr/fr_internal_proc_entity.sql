select
       ipe.ipe_internal_entity_id
     , ipe.ipe_entity_report_name
     , ipe.ipe_pl_party_legal_id
     , ipe.ipe_active
     , fipet.ipet_internal_proc_entity_code
     , ipe.ipe_entity_client_code
     , ipe.ipe_cu_base_currency_id
  from
            fdr.fr_internal_proc_entity      ipe
       join fdr.fr_internal_proc_entity_type fipet on ipe.ipe_ipet_entity_type_id = fipet.ipet_internal_proc_ent_type_id