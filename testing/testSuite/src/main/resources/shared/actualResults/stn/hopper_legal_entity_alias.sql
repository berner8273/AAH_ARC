select
       le.feed_uuid                      feed_uuid
     , fsrgl.srlk_lkt_lookup_type_code   le_alias_rule_typ
     , fsrgl.srlk_match_key1             le_id
     , fsrgl.srlk_lookup_value1          alias_le_cd
     , fsrgl.srlk_lookup_value2          alias_le_descr
     , trunc(fsrgl.srlk_effective_from)  effective_from
     , fsrgl.srlk_effective_to           effective_to
     , fsrgl.srlk_active                 le_alias_sts
     , fsrgl.event_status                event_status
  from
            fdr.fr_stan_raw_general_lookup fsrgl
       join stn.legal_entity               le    on to_number ( fsrgl.message_id ) = le.row_sid
 where
       fsrgl.srlk_lkt_lookup_type_code = 'LEGAL_ENTITY_ALIAS'