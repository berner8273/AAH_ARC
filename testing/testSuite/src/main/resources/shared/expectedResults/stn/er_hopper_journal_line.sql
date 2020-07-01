select
       le_id
     , acct_cd
     , ledger_cd
     , basis_cd
     , book_cd
     , affiliate_le_id
     , accident_yr
     , underwriting_yr
     , policy_id
     , stream_id
     , tax_jurisdiction_cd
     , posting_schema
     , counterparty_le_id
     , dept_cd
     , chartfield_1
     , execution_typ
     , business_typ
     , owner_le_id
     , premium_typ
     , journal_descr
     , transaction_ccy
     , transaction_amt
     , sra_ae_dr_cr
     , accounting_dt
     , ultimate_parent_le_id
     , event_typ
     , functional_ccy
     , functional_amt
     , reporting_ccy
     , reporting_amt
     , business_event_typ
     , event_seq_id
     , sra_ae_source_system
     , sra_ae_itsc_inst_typ_sclss_cd
     , event_status
     , sra_si_account_sys_inst_code
     , sra_si_instr_sys_inst_code
     , sra_si_party_sys_inst_code
     , sra_si_static_sys_inst_code
     , sra_ae_pbu_ext_party_code
     , sra_ae_ipe_int_entity_code
     , sra_ae_aet_acc_event_type_code
     , sra_ae_cu_local_currency_code
     , sra_ae_cu_base_currency_code
     , sra_ae_i_instrument_clicode
     , sra_ae_it_instr_type_code
     , sra_ae_itc_inst_typ_cls_code
     , sra_ae_pe_person_code
     , sra_ae_gl_instrument_id
     , lpg_id
     , sra_ae_posting_date
     , sra_ae_instr_type_map_code
  from
       er_hopper_journal_line


