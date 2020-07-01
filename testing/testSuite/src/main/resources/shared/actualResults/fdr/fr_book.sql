select
       b.bo_book_id
     , bs.bs_book_status_name
     , b.bo_ipe_internal_entity_id
     , b.bo_book_clicode
     , b.bo_book_name
     , b.bo_banking_or_trading
     , b.bo_active
     , b.bo_auth_status
     , b.bo_valid_from
     , b.bo_pl_ledger_entity_code
  from
            fdr.fr_book        b
       join fdr.fr_book_status bs on b.bo_bs_book_status_id = bs.bs_book_status_id