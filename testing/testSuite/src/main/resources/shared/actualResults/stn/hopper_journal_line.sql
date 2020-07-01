select
       fsra.sra_ae_pbu_int_entity_code              le_id
     , fsra.sra_ae_gl_account_code                  acct_cd
     , fsra.sra_ae_posting_schema                   ledger_cd
     , fsra.sra_ae_gaap                             basis_cd
     , fsra.sra_ae_bo_book_clicode                  book_cd
     , fsra.sra_ae_dimension_4                      affiliate_le_id
     , fsra.sra_ae_dimension_5                      accident_yr
     , fsra.sra_ae_dimension_6                      underwriting_yr
     , fsra.sra_ae_dimension_7                      policy_id
     , fsra.sra_ae_dimension_8                      stream_id
     , fsra.sra_ae_dimension_9                      tax_jurisdiction_cd
     , fsra.sra_ae_dimension_10                     posting_schema
     , fsra.sra_ae_dimension_3                      counterparty_le_id
     , fsra.sra_ae_dimension_2                      dept_cd
     , fsra.sra_ae_dimension_1                      chartfield_1
     , fsra.sra_ae_dimension_11                     execution_typ
     , fsra.sra_ae_dimension_12                     business_typ
     , fsra.sra_ae_dimension_13                     owner_le_id
     , fsra.sra_ae_dimension_14                     premium_typ
     , fsra.sra_ae_dimension_15                     journal_descr
     , fsra.sra_ae_cu_currency_code                 transaction_ccy
     , fsra.sra_ae_amount                           transaction_amt
     , fsra.sra_ae_dr_cr                            sra_ae_dr_cr
     , fsra.sra_accevent_date                       accounting_dt
     , fsra.sra_ae_client_spare_id3                 ultimate_parent_le_id
     , fsra.sra_ae_client_spare_id4                 event_typ
     , fsra.sra_ae_client_spare_id5                 functional_ccy
     , to_number ( fsra.sra_ae_client_spare_id6 )   functional_amt
     , fsra.sra_ae_client_spare_id7                 reporting_ccy
     , to_number ( fsra.sra_ae_client_spare_id8 )   reporting_amt
     , fsra.sra_ae_client_spare_id11                business_event_typ
     , fsra.sra_ae_client_spare_id12                event_seq_id
     , fsra.sra_ae_source_system                    sra_ae_source_system
     , fsra.sra_ae_itsc_inst_typ_sclss_cd           sra_ae_itsc_inst_typ_sclss_cd
     , fsra.event_status                            event_status
     , fsra.sra_si_account_sys_inst_code
     , fsra.sra_si_instr_sys_inst_code
     , fsra.sra_si_party_sys_inst_code
     , fsra.sra_si_static_sys_inst_code
     , fsra.sra_ae_pbu_ext_party_code
     , fsra.sra_ae_ipe_int_entity_code
     , fsra.sra_ae_aet_acc_event_type_code
     , fsra.sra_ae_cu_local_currency_code
     , fsra.sra_ae_cu_base_currency_code
     , fsra.sra_ae_i_instrument_clicode
     , fsra.sra_ae_it_instr_type_code
     , fsra.sra_ae_itc_inst_typ_cls_code
     , fsra.sra_ae_pe_person_code
     , fsra.sra_ae_gl_instrument_id
     , fsra.lpg_id
     , fsra.sra_ae_posting_date
     , fsra.sra_ae_instr_type_map_code
  from
       fdr.fr_stan_raw_adjustment fsra