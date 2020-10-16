create or replace view rdr.rrv_ag_posting_derivation
as
select
       fgl.lk_lookup_value4          event_category
     , fgl.lk_lookup_value3          event_class
     , fgl.lk_lookup_value2          event_group
     , fgl.lk_lookup_value1          event_subgroup
     , pm.event_typ                  event_type
     , decode ( pm.sub_event
       , 'NULL' , 'BOOK' 
       , 'MTM'  , 'BOOK TO DERIVATIVE ACCOUNTS'
       ,  pm.sub_event )             posting_type
     , 1                             vie_cd
     , null                          vie_cd_description
     , null                          vie_event_type
     , null                          vie_posting_type
     , null                          vie_amount_type
     , fpd.pd_posting_driver_id      posting_code_id
     , fpd.pd_posting_code           posting_code
     , fpd.pd_valid_from             posting_code_valid_from
     , fpd.pd_valid_to               posting_code_valid_to
     , fpd.pd_active                 posting_code_status
     , pm.premium_typ                premium_type
     , pm.is_mark_to_market          execution_type
     , pm.psmtm_basis_cd             posting_method_basis_cd
     , pm.psm_id                     posting_method_id
     , pm.psm_cd                     posting_method_cd
     , pm.psm_descr                  posting_method_description
     , pm.input_basis_cd             input_basis_cd
     , pm.output_basis_cd            output_basis_cd
     , pm.ledger_cd                  ledger_cd
     , fal.al_lookup_1               business_type
     , fal.al_lookup_3               business_unit
     , fal.al_lookup_4               vie_business_unit
     , fal.al_lookup_5               gl_account_cd
     , fpd.pd_amount_type            amount_type
     , fpd.pd_dr_or_cr               debit_credit
     , fpd.pd_transaction_no         transaction_no
     , fpd.pd_negate_flag1           negate_flag
     , fpd.pd_journal_type           journal_type
     , fal.al_account                sub_account
     , fga.ga_account_name           sub_account_name
     , fal.al_valid_from             sub_account_valid_from
     , fal.al_valid_to               sub_account_valid_to
     , fal.al_active                 sub_account_status
  from
       fdr.fr_posting_driver         fpd
  join fdr.fr_account_lookup         fal  on fpd.pd_posting_code = fal.al_posting_code
  left join fdr.fr_gl_account        fga  on fal.al_account      = fga.ga_account_code
  join (
        select
               event_typ
             , sub_event
             , premium_typ
             , is_mark_to_market
             , pabin.basis_cd     input_basis_cd
             , pabout.basis_cd    output_basis_cd
             , pabpm.basis_cd     psmtm_basis_cd
             , ledger_cd
             , pm2.psm_id
             , pm2.psm_cd
             , pm2.psm_descr
          from
               stn.posting_method_derivation_mtm     psmtm
          join stn.event_type                        et      on psmtm.event_typ_id  = et.event_typ_id
          join stn.posting_method_ledger             psl     on psmtm.psm_id        = psl.psm_id
          join stn.posting_ledger                    pl      on psl.ledger_id       = pl.ledger_id
          join stn.posting_method                    pm2     on psmtm.psm_id        = pm2.psm_id
          join stn.posting_accounting_basis          pabin   on psl.input_basis_id  = pabin.basis_id
          join stn.posting_accounting_basis          pabout  on psl.output_basis_id = pabout.basis_id
          join stn.posting_accounting_basis          pabpm   on psmtm.basis_id      = pabpm.basis_id
       )                             pm   on (
                                                  fpd.pd_posting_schema = pm.ledger_cd
                                              and fpd.pd_aet_event_type = pm.event_typ
                                              and fpd.pd_sub_event      = pm.sub_event
                                              and ( fal.al_lookup_2     = pm.is_mark_to_market
                                                 or fal.al_lookup_2     = 'ND~' )
                                             )
  left join fdr.fr_general_lookup    fgl  on pm.event_typ        = fgl.lk_match_key1
                                         and 'EVENT_HIERARCHY'   = fgl.lk_lkt_lookup_type_code
                                         and 'A'                 = fgl.lk_active
union all
select
       fgl.lk_lookup_value4          event_category
     , fgl.lk_lookup_value3          event_class
     , fgl.lk_lookup_value2          event_group
     , fgl.lk_lookup_value1          event_subgroup
     , pm.event_typ                  event_type
     , 'All'                         posting_type
     , pm.vie_id                     vie_cd
     , pm.vie_cd_descr               vie_cd_description
     , pm.vie_event_typ              vie_event_type
     , pm.vie_sub_event              vie_posting_type
     , pm.vie_fin_calc_cd            vie_amount_type
     , fpd.pd_posting_driver_id      posting_code_id
     , fpd.pd_posting_code           posting_code
     , fpd.pd_valid_from             posting_code_valid_from
     , fpd.pd_valid_to               posting_code_valid_to
     , fpd.pd_active                 posting_code_status
     , 'All'                         premium_type
     , fal.al_lookup_2               execution_type
     , 'US_GAAP'                     posting_method_basis_cd
     , 0                             posting_method_id
     , 'VIE'                         posting_method_cd
     , 'VIE'                         posting_method_description
     , 'US_GAAP'                     input_basis_cd
     , 'US_GAAP'                     output_basis_cd
     , pm.vie_ledger_cd              ledger_cd
     , fal.al_lookup_1               business_type
     , fal.al_lookup_3               business_unit
     , fal.al_lookup_4               vie_business_unit
     , fal.al_lookup_5               gl_account_cd
     , fpd.pd_amount_type            amount_type
     , fpd.pd_dr_or_cr               debit_credit
     , fpd.pd_transaction_no         transaction_no
     , fpd.pd_negate_flag1           negate_flag
     , fpd.pd_journal_type           journal_type
     , fal.al_account                sub_account
     , fga.ga_account_name           sub_account_name
     , fal.al_valid_from             sub_account_valid_from
     , fal.al_valid_to               sub_account_valid_to
     , fal.al_active                 sub_account_status
  from
       fdr.fr_posting_driver         fpd
  join fdr.fr_account_lookup         fal      on fpd.pd_posting_code = fal.al_posting_code
  left join fdr.fr_gl_account        fga      on fal.al_account      = fga.ga_account_code
  join (
        select 
               et.event_typ     event_typ
             , vet2.event_typ   vie_event_typ
             , vpml.sub_event   vie_sub_event
             , vpl.ledger_cd    vie_ledger_cd
             , vcd.vie_cd       vie_id
             , vpfc.fin_calc_cd vie_fin_calc_cd
             , vcd.vie_cd_descr vie_cd_descr
          from
               stn.event_type                et
          join stn.vie_posting_method_ledger vpml on et.event_typ_id       = vpml.event_typ_id
          join stn.vie_event_type            vet  on vpml.vie_event_typ_id = vet.event_typ_id
          join stn.event_type                vet2 on vet.event_typ_id      = vet2.event_typ_id
          join stn.posting_ledger            vpl  on vpml.ledger_id        = vpl.ledger_id
          join stn.posting_financial_calc    vpfc on vpml.fin_calc_id      = vpfc.fin_calc_id
          join stn.vie_code                  vcd  on vpml.vie_id           = vcd.vie_id
       )                             pm       on (
                                                       fpd.pd_posting_schema = pm.vie_ledger_cd
                                                   and fpd.pd_aet_event_type = pm.vie_event_typ
                                                   and fpd.pd_sub_event      = pm.vie_sub_event
                                                  )
  left join fdr.fr_general_lookup    fgl      on pm.event_typ        = fgl.lk_match_key1
                                             and 'EVENT_HIERARCHY'   = fgl.lk_lkt_lookup_type_code
                                             and 'A'                 = fgl.lk_active
;