create or replace view fdr.fcv_combination_check_suspense (data_set, attribute, suspense_value) as
select gc_gct_code_type_id as data_set,
       gc_general_code_id as attribute,
       gc_client_text1 as suspense_value
  from fr_general_codes
 where gc_active = 'A';
comment on table fdr.fcv_combination_check_suspense is 'Configurable View to collect all combination check suspense data sets.';