create or replace view stn.hopper_legal_entity_ledger
as
select
       fsrgl.srlk_lkt_lookup_type_code feed_typ
     , fsrgl.srlk_match_key1           ledger_cd_le_id
     , fsrgl.srlk_lookup_value1        ledger_cd
     , fsrgl.srlk_lookup_value2        le_id
     , fsrgl.srlk_effective_from       effective_from
     , fsrgl.srlk_effective_to         effective_to
     , fsrgl.srlk_active               legal_entity_ledger_sts
     , fsrgl.event_status              event_status
     , fsrgl.message_id                message_id
     , fsrgl.process_id                process_id
     , fsrgl.lpg_id                    lpg_id
  from
       fdr.fr_stan_raw_general_lookup fsrgl
 where
       fsrgl.srlk_lkt_lookup_type_code = 'LEGAL_ENTITY_LEDGER'
  with
       check option
     ;