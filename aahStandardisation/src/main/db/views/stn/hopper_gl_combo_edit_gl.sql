create or replace view stn.hopper_gl_combo_edit_gl
as
select
       fsrgl.srlk_lkt_lookup_type_code combo_rule_typ
     , fsrgl.srlk_match_key1           combo_rule_or_set
     , fsrgl.srlk_match_key2           combo_attr_or_rule
     , fsrgl.srlk_match_key3           combo_condition
     , fsrgl.srlk_match_key4           combo_condition_typ
     , fsrgl.srlk_match_key5           combo_set_cd 
     , fsrgl.srlk_lookup_value1        combo_action
     , fsrgl.srlk_effective_from       effective_from
     , fsrgl.srlk_effective_to         effective_to
     , fsrgl.srlk_active               combo_edit_sts
     , fsrgl.event_status              event_status
     , fsrgl.message_id                message_id
     , fsrgl.process_id                process_id
     , fsrgl.lpg_id                    lpg_id
  from
       fdr.fr_stan_raw_general_lookup fsrgl
 where
       fsrgl.srlk_lkt_lookup_type_code like 'COMBO%'
  with
       check option
     ;