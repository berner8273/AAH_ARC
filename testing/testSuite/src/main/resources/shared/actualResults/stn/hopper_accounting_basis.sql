  select
       abl.feed_uuid                    feed_uuid
     , fsrgl.srlk_lkt_lookup_type_code  feed_typ
     , fsrgl.srlk_match_key1            basis_cd_ledger_cd
     , fsrgl.srlk_lookup_value1         basis_cd
     , fsrgl.srlk_lookup_value2         ledger_cd
     , trunc(fsrgl.srlk_effective_from) effective_from
     , fsrgl.srlk_effective_to          effective_to
     , fsrgl.srlk_active                basis_ledger_sts
     , fsrgl.event_status               event_status
  from
       fdr.fr_stan_raw_general_lookup    fsrgl
       join stn.accounting_basis_ledger  abl     on to_number ( fsrgl.message_id ) = abl.row_sid
 where
       fsrgl.srlk_lkt_lookup_type_code = 'ACCOUNTING_BASIS_LEDGER'