create or replace view stn.hopper_gl_chartfield
as
select
       fsrgc.srgc_client_text1     chartfield_typ
     , fsrgc.srgc_client_code      chartfield_cd
     , fsrgc.srgc_client_text2     chartfield_descr
     , fsrgc.srgc_valid_from       effective_dt
     , fsrgc.srgc_active           chartfield_sts
     , fsrgc.srgc_gct_code_type_id feed_typ
     , fsrgc.event_status          event_status
     , fsrgc.message_id            message_id
     , fsrgc.process_id            process_id
     , fsrgc.lpg_id                lpg_id
  from
       fdr.fr_stan_raw_general_codes fsrgc
 where
       fsrgc.srgc_gct_code_type_id = 'GL_CHARTFIELD'
  with
       check option
     ;