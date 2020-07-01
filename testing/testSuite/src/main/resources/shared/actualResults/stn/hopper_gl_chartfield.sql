select
       gcf.feed_uuid               feed_uuid
     , fsrgc.srgc_client_text1     chartfield_typ
     , fsrgc.srgc_client_code      chartfield_cd
     , fsrgc.srgc_client_text2     chartfield_descr
     , fsrgc.srgc_valid_from       effective_dt
     , fsrgc.srgc_active           chartfield_sts
     , fsrgc.srgc_gct_code_type_id feed_typ
     , fsrgc.event_status          event_status
  from
            fdr.fr_stan_raw_general_codes fsrgc
       join stn.gl_chartfield             gcf    on to_number ( fsrgc.message_id ) = gcf.row_sid
 where
       fsrgc.srgc_gct_code_type_id = 'GL_CHARTFIELD'