select
       ga.feed_uuid
     , fsrga.srga_ga_account_code
     , fsrga.srga_ga_account_name
     , fsrga.srga_ga_account_type
     , fsrga.srga_ga_account_adj_type
     , fsrga.event_status
     , fsrga.srga_ga_active
     , fsrga.srga_ga_client_text2
     , fsrga.srga_ga_client_text3
     , fsrga.srga_ga_client_text4
     , fsrga.lpg_id
     , fsrga.srga_ga_position_flag
     , fsrga.srga_ga_account_type_flag
  from
            fdr.fr_stan_raw_gl_account fsrga
       join stn.gl_account             ga    on trunc ( to_number ( fsrga.message_id ) ) = ga.row_sid