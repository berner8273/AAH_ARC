create or replace view fdr.fcv_combination_check_hopper (
  ci_input_id,
  ci_ruleset,
  ci_attribute_1,
  ci_attribute_2,
  ci_attribute_3,
  ci_attribute_4,
  ci_attribute_5,
  ci_attribute_6,
  ci_attribute_7,
  ci_attribute_8,
  ci_attribute_9,
  ci_attribute_10,
  ci_suspense_id,
  lpg_id)
as
select to_char(srae_raw_acc_event_id) as ci_input_id,
       srae_source_system as ci_ruleset,
       srae_dimension_1 as ci_attribute_1,
       srae_dimension_2 as ci_attribute_2,
       srae_dimension_3 as ci_attribute_3,
       srae_dimension_4 as ci_attribute_4,
       srae_dimension_5 as ci_attribute_5,
       srae_dimension_6 as ci_attribute_6,
       srae_dimension_7 as ci_attribute_7,
       srae_dimension_8 as ci_attribute_8,
       srae_dimension_9 as ci_attribute_9,
       srae_dimension_10 as ci_attribute_10,
       null as ci_suspense_id,
       lpg_id as lpg_id
  from fdr.fr_stan_raw_acc_event;
comment on table fdr.fcv_combination_check_hopper is 'Configurable View to map Hopper to Combination Check Attributes.';