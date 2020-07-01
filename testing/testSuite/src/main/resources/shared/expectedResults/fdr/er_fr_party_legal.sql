select
       pl_party_legal_id
     , pl_full_legal_name
     , pt_party_type_name
     , pl_party_legal_clicode
     , pl_int_ext_flag
     , pl_active
     , pl_auth_status
     , pl_client_text1                 cldr_cd
     , pl_client_text2                 no_grace_days
     , pl_client_text3                 slr_lpg_id
     , pl_client_text4                 epg_id
     , pl_client_text5                 is_interco_elim_entity
     , pl_client_text6                 is_vie_consol_entity
     , pl_client_text7                 is_standalone
     , pl_global_id
     , pl_cu_local_currency_id
     , pl_cu_base_currency_id
  from
       er_fr_party_legal
