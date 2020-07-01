select
       fpl.pl_party_legal_id
     , fpl.pl_full_legal_name
     , fpt.pt_party_type_name
     , fpl.pl_party_legal_clicode
     , fpl.pl_int_ext_flag
     , fpl.pl_active
     , fpl.pl_auth_status
     , fpl.pl_client_text1                 cldr_cd
     , fpl.pl_client_text2                 no_grace_days
     , fpl.pl_client_text3                 slr_lpg_id
     , fpl.pl_client_text4                 epg_id
     , fpl.pl_client_text5                 is_interco_elim_entity
     , fpl.pl_client_text6                 is_vie_consol_entity
     , fpl.pl_client_text7                 is_standalone
     , fpl.pl_global_id
     , fpl.pl_cu_local_currency_id
     , fpl.pl_cu_base_currency_id
  from
            fdr.fr_party_legal fpl
       join fdr.fr_party_type  fpt on fpl.pl_pt_party_type_id = fpt.pt_party_type_id
