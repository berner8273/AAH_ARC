select
       d.feed_uuid
     , fsrb.srb_bo_bs_book_status_code
     , fsrb.srb_bo_ipe_internal_entity_cde
     , fsrb.srb_bo_book_clicode
     , fsrb.srb_bo_book_name
     , fsrb.srb_bo_banking_or_trading
     , fsrb.srb_bo_valid_from
     , fsrb.srb_one
     , fsrb.event_status
     , fsrb.srb_bo_active
     , fsrb.lpg_id
     , fsrb.srb_si_source_system
  from
            fdr.fr_stan_raw_book fsrb
       join stn.department       d    on to_number ( fsrb.message_id ) = d.row_sid