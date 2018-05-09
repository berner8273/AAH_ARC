create or replace view fdr.fcv_combination_check_data (data_set, from_value, to_value) as
select gc_gct_code_type_id as data_set,
       gc_general_code_id as from_value,
       gc_client_text1 as to_value
  from fr_general_codes
 where gc_active = 'A';
comment on table fdr.fcv_combination_check_data is 'Configurable View to collect all combination check data sets.';