create or replace view stn.hopper_legal_entity_alias
as
select
       fsrgl.srlk_lkt_lookup_type_code le_alias_rule_typ
     , fsrgl.srlk_match_key1           le_id
     , fsrgl.srlk_lookup_value1        alias_le_cd
     , fsrgl.srlk_lookup_value2        alias_le_descr
     , fsrgl.srlk_effective_from       effective_from
     , fsrgl.srlk_effective_to         effective_to
     , fsrgl.srlk_active               le_alias_sts
     , fsrgl.event_status              event_status
     , fsrgl.message_id                message_id
     , fsrgl.process_id                process_id
     , fsrgl.lpg_id                    lpg_id
  from
       fdr.fr_stan_raw_general_lookup fsrgl
 where
       fsrgl.srlk_lkt_lookup_type_code = 'LEGAL_ENTITY_ALIAS'
  with
       check option
     ;