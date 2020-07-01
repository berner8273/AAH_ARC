(
 select
       gcep.feed_uuid                 feed_uuid
     , fsrgc.srgc_gct_code_type_id    combo_set_cd
     , fsrgc.srgc_client_code         combo_set_value
     , fsrgc.srgc_client_text1        combo_value_type
     , fsrgc.srgc_active              combo_edit_sts
     , fsrgc.event_status             event_status
  from
       fdr.fr_stan_raw_general_codes fsrgc
     , stn.gl_combo_edit_process     gcep
     , stn.gl_combo_edit_rule        gcer
 where
       trunc(fsrgc.message_id) = gcep.row_sid || gcer.row_sid
   and fsrgc.srgc_gct_code_type_id like 'COMBO%'
union all
 select
       gcep.feed_uuid                 feed_uuid
     , fsrgc.srgc_gct_code_type_id    combo_set_cd
     , fsrgc.srgc_client_code         combo_set_value
     , fsrgc.srgc_client_text1        combo_value_type
     , fsrgc.srgc_active              combo_edit_sts
     , fsrgc.event_status             event_status
  from
       fdr.fr_stan_raw_general_codes fsrgc
     , stn.gl_combo_edit_process     gcep
     , stn.gl_combo_edit_assignment  gcea
 where
       trunc(fsrgc.message_id) = gcep.row_sid || gcea.row_sid
   and fsrgc.srgc_gct_code_type_id like 'COMBO%'
)