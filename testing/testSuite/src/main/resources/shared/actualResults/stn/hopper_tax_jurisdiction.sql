select
       tj.feed_uuid                 feed_uuid
     , fsrgc.srgc_client_code       tax_jurisdiction_cd
     , fsrgc.srgc_client_text2      tax_jurisdiction_descr
     , trunc(fsrgc.srgc_valid_from) effective_dt
     , fsrgc.srgc_active	    tax_jurisdiction_sts
     , fsrgc.srgc_gct_code_type_id  feed_typ
     , fsrgc.event_status           event_status
  from
     fdr.fr_stan_raw_general_codes fsrgc
	join stn.tax_jurisdiction tj on trunc(to_number(fsrgc.message_id)) = tj.row_sid
 where
       fsrgc.srgc_gct_code_type_id = 'TAX_JURISDICTION'