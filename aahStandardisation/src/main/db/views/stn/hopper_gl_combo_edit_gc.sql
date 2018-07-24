create or replace view stn.hopper_gl_combo_edit_gc
as
select
       fsrgc.srgc_gct_code_type_id combo_set_cd
     , fsrgc.srgc_client_code      combo_set_value
     , fsrgc.srgc_client_text1     combo_value_type
     , fsrgc.srgc_valid_from       valid_from
     , fsrgc.srgc_valid_to         valid_to
     , fsrgc.srgc_active           combo_edit_sts
     , fsrgc.event_status          event_status
     , fsrgc.message_id            message_id
     , fsrgc.process_id            process_id
     , fsrgc.lpg_id                lpg_id
  from
       fdr.fr_stan_raw_general_codes fsrgc
 where
       fsrgc.srgc_gct_code_type_id like 'COMBO%'
  with
       check option
     ;