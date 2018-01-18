create or replace view rdr.rrv_ag_accounting_event_imp
as
select
       ae_gl_account                sub_acccount
     , ae_acc_event_id
     , ae_aet_acc_event_type_id
     , ae_in_repository_ind
     , ae_posting_date              effective_date
     , ae_accevent_date
     , ae_amount                    transactional_amt
     , ae_iso_currency_code         transactional_ccy
     , ae_ledger_period
     , ae_gl_account_alias
     , ae_gl_entity                 business_unit
     , ae_epg_id
     , ae_gl_book                   department
     , ae_gl_profit_centre
     , ae_input_time
     , ae_gl_instr_super_class
     , ae_ledger_rec_status
     , ae_value_date                posting_period
     , ae_gl_instrument_id
     , ae_gl_party_business_id
     , ae_gl_person_id
     , ae_client_spare_id1
     , ae_client_spare_id2
     , ae_client_spare_id3          ultimate_parent_stream_id
     , ae_client_spare_id4          event_type
     , ae_client_spare_id5          functionl_ccy
     , ae_client_spare_id6          functional_amt
     , ae_client_spare_id7          reporting_ccy
     , ae_client_spare_id8          reporting_amt
     , ae_client_spare_id9          is_mark_to_market
     , ae_client_spare_id10         vie_cd
     , ae_client_spare_id11         business_event_type
     , ae_client_spare_id12         event_seq_id
     , ae_client_spare_id13         policy_type
     , ae_client_spare_id14         correlation_uuid
     , ae_client_spare_id15         basis_cd
     , ae_source_tran_no
     , ae_gl_narrative
     , ae_ledger_rec_status2
     , ae_rep_schema_upd
     , ae_transaction_no
     , ae_rule_id
     , ae_rules_amount_ref_id
     , ae_sub_ledger_upd
     , ae_i_instrument_id
     , ae_fdr_tran_no
     , ae_il_instr_leg_id
     , ae_source_system
     , ae_journal_type
     , ae_gl_ledger_id
     , lpg_id
     , ae_source_jrnl_id
     , ae_sub_event_id
     , ae_posting_schema            ledger
     , ae_gaap                      accounting_basis
     , ae_posting_code
     , ae_reverse_date
     , ae_dr_cr
     , ae_dimension_1               chartfield_1
     , ae_dimension_2               dept_cd
     , ae_dimension_3               counterparty_le_cd
     , ae_dimension_4               affiliate_le_cd
     , ae_dimension_5               accident_yr
     , ae_dimension_6               underwriting_yr
     , ae_dimension_7               policy_id
     , ae_dimension_8               stream_id
     , ae_dimension_9               tax_jurisdiction_cd
     , ae_dimension_10              ledger_cd
     , ae_dimension_11              execution_type
     , ae_dimension_12              business_type
     , ae_dimension_13              owner_le_cd
     , ae_dimension_14              premium_type
     , ae_dimension_15              journal_descr
     , ae_gl_cost_centre
     , ae_ret_amort_flag
     , ae_gl_client1_org_unit_id
     , ae_gl_client2_org_unit_id
     , ae_gl_client3_org_unit_id
     , ae_gl_plant_id
     , ae_gl_ship_to_country_id
     , ae_gl_product_part_id
     , ae_client_date1
     , ae_gl_cash_flow_type
     , ae_gl_tax_code_id
     , ae_gl_contract_id
     , ae_gl_rights_categ_id
     , ae_gl_rights_subcateg_id
     , ae_translation_date
     , ae_ret_recog_type_id
     , ae_number_of_periods
     , ae_calc_period
     , ae_ret_agv_or_arrears
     , ae_ret_ca_calendar_name
     , ae_ret_post_period
     , ae_client_date2
     , ae_client_date3
     , ae_client_date4
     , ae_client_date5
  from
       fdr.fr_accounting_event_imp
     ;