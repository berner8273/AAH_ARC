select
       rty_rate_type_id
     , rty_rate_type_description
     , rty_active
     , rty_input_by
     , rty_auth_by
     , rty_auth_status
  from
       fdr.fr_rate_type
       where rty_active = 'A'