select
       ga_account_code
     , ga_account_name
     , ga_account_type
     , ga_account_adjustment_type
     , ga_active
     , ga_auth_status
     , ga_client_text2
     , ga_client_text3
     , ga_client_text4
     , ga_revaluation_ind
     , ga_account_type_flag
     , ga_position_flag
  from
       fdr.fr_gl_account
 where
       ga_input_by not in ( 'AG_SEED' ) and ga_account_code <> '1'