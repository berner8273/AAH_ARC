  select
       lel.feed_uuid                    feed_uuid
     , fsrgl.srlk_lkt_lookup_type_code  feed_typ
     , fsrgl.srlk_match_key1            ledger_cd_le_id
     , fsrgl.srlk_lookup_value1         ledger_cd
     , fsrgl.srlk_lookup_value2         le_id
     , trunc(fsrgl.srlk_effective_from) effective_from
     , fsrgl.srlk_effective_to          effective_to
     , fsrgl.srlk_active                legal_entity_ledger_sts
     , fsrgl.event_status               event_status
  from
       fdr.fr_stan_raw_general_lookup    fsrgl
       join stn.legal_entity_ledger      lel     on to_number ( fsrgl.message_id ) = lel.row_sid
 where
       fsrgl.srlk_lkt_lookup_type_code = 'LEGAL_ENTITY_LEDGER'