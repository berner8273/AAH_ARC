create or replace view rdr.rrv_combination_check_app_rule (
  rule_set,
  rule,
  condition_id,
  attribute_name,
  condition,
  condition_type,
  from_value,
  to_value,
  action)
as
select gl1.lk_match_key1 as	rule_set,
       gl1.lk_match_key2 as	rule,
       gl2.lk_lookup_key_id as condition_id,
       gl2.lk_match_key2	as attribute_name,
       gl2.lk_match_key3	as condition,
       gl2.lk_match_key4	as condition_type,
       gl2.lk_match_key5	as from_value,
       gl2.lk_match_key6	as to_value,
       gl2.lk_lookup_value1 as action
  from fdr.fr_general_lookup gl1
  left join fdr.fr_general_lookup gl2 on gl1.lk_match_key2 = gl2.lk_match_key1
                                     and gl2.lk_lkt_lookup_type_code = 'COMBO_APPLICABLE'
 where gl1.lk_lkt_lookup_type_code = 'COMBO_RULESET';
comment on table rrv_combination_check_app_rule is 'This view displays all the combination checking applicable rules that are currently active within the system such that it can be reported on from the Reporting Data Repository.';