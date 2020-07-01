 select
       ea.ea_entity_set
     , ea.ea_account
     , ea.ea_account_type
     , ea.ea_description
     , ea.ea_status
     , ea.ea_eff_from
     , ea.ea_eff_to
     , ea.ea_account_type_flag
     , ea.ea_revaluation_flag
     , ea.ea_position_flag
  from
       slr.slr_entity_accounts ea
 where
       not exists (
                      select
                             null
                        from
                             fdr.fr_gl_account fga
                       where
                             fga.ga_account_code = ea.ea_account
                         and fga.ga_input_by     = 'AG_SEED'
                  )